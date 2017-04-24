//
//  RiderInfoViewController.swift
//  DDDispatcher
//
//  Created by Yoonju Lee on 3/21/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//


import UIKit
import CoreLocation
import MapKit

class RiderInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //when the button is clicked, a user is redirected to apple map
    @IBAction func GetDirectionButtonClicked(_ sender: Any) {
        
        //request the authorization
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        
        //latitude and longitude of destination
        let destLatitude:CLLocationDegrees! = 40.730610
        let destLongitude:CLLocationDegrees! = -73.935242
        
        let coordinate = CLLocationCoordinate2DMake(destLatitude, destLongitude)
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        
        //name of the destination
        mapItem.name = "New York, NY, United States" //destination
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }

}
