//
//  RideConfirmationViewController.swift
//  DDDispatcher
//
//  Created by kmustahsan on 3/19/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

class RideConfirmationViewController: UIViewController, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var submitRide: UIButton!
   
    var startingLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Style.pillButton(button: submitRide)
        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.isHidden = true
        setupMap()
        createPath()
    }

    
    func setupMap() {
        mapView.settings.consumesGesturesInView = false
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.mapView.bringSubview(toFront: submitRide)
    }
    
    
    func createPath() {
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
            "origin=\(startingLocation.latitude),\(startingLocation.longitude)&destination=\(destinationLocation.latitude),\(destinationLocation.longitude)&" +
        "key=AIzaSyBjG03DdY9T6r9E9Fr7qNHREIGrB69BnFs"
        

        Alamofire.request(directionURL).responseJSON
            { response in
                
                if let JSON = response.result.value {
                    
                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                    
                    let routesArray = (mapResponse["routes"] as? Array) ?? []
                    
                    let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
                    
                    let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                    let polypoints = (overviewPolyline["points"] as? String) ?? ""
                    let line  = polypoints
                    self.addPolyLine(encodedString: line)
                }
        }
        let camera = GMSCameraPosition.camera(withLatitude: (startingLocation.latitude), longitude:(startingLocation.longitude), zoom:14)
        mapView.animate(to: camera)
    }
    
    func addPolyLine(encodedString: String) {
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = .blue
        polyline.map = mapView
    }
    
    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
    
    
    @IBAction func submitRideClick(_ sender: Any) {
        let alertController = UIAlertController(title: "Error",
                                                message: "No Drivers are active at the moment",
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
