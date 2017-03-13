//
//  CustomSideMenuController.swift
//  DDDispatcher
//
//  Created by macbookair11 on 3/13/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import SideMenuController

class CustomSideMenuController: SideMenuController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSegue(withIdentifier: "showCenterController1", sender: nil)
        performSegue(withIdentifier: "containSideMenu", sender: nil)
    }
}
