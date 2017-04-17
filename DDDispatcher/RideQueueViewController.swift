//
//  RideQueueViewController.swift
//  DDDispatcher
//
//  Created by Woo Jin Kye on 2017. 4. 16..
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit


class RideQueueViewController: UIViewController {
    var popup: UILabel!
    // Optain the actual posision later.
    var posision: String = "5"
    
    override func viewDidLoad() {
        showAlert()
    }
    
    func showAlert() {
        // Initializing popup label
        popup = UILabel(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.maxX, height: 50))
        popup.backgroundColor = UIColor.lightGray
        popup.text = "Your position in queue is " + posision
        popup.textColor = UIColor.red
        popup.textAlignment = .center
        
        // Add to screen
        self.view.addSubview(popup)
        
        // Set the timer
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }
    
    func dismissAlert() {
        if popup != nil { // Dismiss the view from here
            popup.removeFromSuperview()
        }
    }
}
