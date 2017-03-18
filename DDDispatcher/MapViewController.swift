//
//  MapViewController.swift
//  DDDispatcher
//
//  Created by kmustahsan on 3/17/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation


class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var destinationView: UIView!
    
     var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSUISettings.init().consumesGesturesInView = false
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.mapView.bringSubview(toFront: destinationView)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(segueTo))
        self.destinationView.addGestureRecognizer(gesture)
    }
    
    func segueTo() {
        performSegue(withIdentifier: "rideSegue", sender: self)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:15)
        mapView.animate(to: camera)
        
        self.locationManager.stopUpdatingLocation()
        
    }
}




