//
//  RideConfirmationViewController.swift
//  DDDispatcher
//
//  Created by kmustahsan on 3/19/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.

import UIKit
import GoogleMaps
import GooglePlaces

class RideConfirmationViewController: UIViewController, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var submitRide: UIButton!
   
    var startingLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let camera = GMSCameraPosition.camera(withLatitude: (startingLocation.latitude), longitude:(startingLocation.longitude), zoom:15)
        mapView.animate(to: camera)
        
        let startingMarker = GMSMarker()
        startingMarker.position = CLLocationCoordinate2DMake(startingLocation.latitude, startingLocation.longitude)
        startingMarker.map = mapView
        
        let destinationMarker = GMSMarker()
        destinationMarker.position = CLLocationCoordinate2DMake(destinationLocation.latitude, destinationLocation.longitude)
        destinationMarker.map = mapView
        
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2DMake(startingLocation.latitude, startingLocation.longitude))
        path.add(CLLocationCoordinate2DMake(destinationLocation.latitude, destinationLocation.longitude))
        
        let rectangle = GMSPolyline(path: path)
        rectangle.strokeWidth = 2.0
        rectangle.map = mapView

    }
    
    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  



}
