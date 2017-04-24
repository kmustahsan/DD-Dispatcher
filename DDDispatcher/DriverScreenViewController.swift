//
//  DriverScreenViewController.swift
//  DDDispatcher
//
//  Created by Woo Jin Kye on 2017. 4. 23..
//  Copyright © 2017년 DD Dispatcher. All rights reserved.
//

import UIKit

class DriverScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //change navigation bar style
        UINavigationBar.appearance().barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Do any additional setup after loading the view.
    }

    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }

}
