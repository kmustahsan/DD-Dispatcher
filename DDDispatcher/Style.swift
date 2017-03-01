//
//  Style.swift
//  DDDispatcher
//
//  Created by macbookair11 on 3/1/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import Foundation
import UIKit

struct Style {
    
    static var baseColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1) //black
    static var secondaryColor = UIColor(red: 126/255, green: 127/255, blue: 137/255, alpha: 1)
//TextField
    static func setupTextField(textField: UITextField) {
        textField.borderStyle = .none
        textField.layer.backgroundColor = UIColor.white.cgColor
        textField.layer.masksToBounds = false
        textField.layer.shadowColor = Style.baseColor.cgColor
        textField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        textField.layer.shadowOpacity = 1.0
        textField.layer.shadowRadius = 0.0
    }
    
    static func activeTextField(textField: UITextField) {
        textField.textColor = baseColor
        textField.layer.shadowColor = baseColor.cgColor
    }
    static func inactiveTextField(textField: UITextField) {
        textField.textColor = UIColor.lightGray
        textField.layer.borderColor = secondaryColor.cgColor
    }
//End TextField
    static func pillButton(button: UIButton) {
        button.layer.cornerRadius = 15
    }
}
