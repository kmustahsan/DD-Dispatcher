//
//  RideConfirmationViewController.swift
//  DDDispatcher
//
//  Created by macbookair11 on 3/19/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class RideConfirmationViewController: UIViewController {
    var startingLocation: GMSPlace!
    var destinationLocation: GMSPlace!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(startingLocation)
        print(destinationLocation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
