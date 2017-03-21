//
//  SetDateAndTimeViewController.swift
//  DDDispatcher
//
//  Created by Yoonju Lee on 3/20/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class SetDateAndTimeViewController: UIViewController {

    //set variables
    var infoPassed = ["", "", ""]
    var dateToPass = ["", ""] //[0] = start date, [1] end date
    var endDateChanged = 0
    
    //set outlet
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //set start date
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.string(from: startDatePicker.date)
        
        dateToPass[0] = dateFormatter.string(from: startDatePicker.date)
        
        
        startDatePicker.addTarget(self, action: #selector(SetDateAndTimeViewController.startDatePickerChanged), for: UIControlEvents.valueChanged)
        endDatePicker.addTarget(self, action: #selector(SetDateAndTimeViewController.endDatePickerChanged), for: UIControlEvents.valueChanged)
        
        
    }
    
    /*
     ---------------------------------
     MARK: - Date Picker Method
     ---------------------------------
     */
    func startDatePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.string(from: datePicker.date)
        
        dateToPass[0] = dateFormatter.string(from: datePicker.date)
    }
    
    func endDatePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.string(from: datePicker.date)
        
        dateToPass[1] = dateFormatter.string(from: datePicker.date)
        endDateChanged = 1
    }
    
    /*
     ---------------------------------
     MARK: - Prepare for Segue
     ---------------------------------
     */
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        
        let currentDate = Date()
        
        if startDatePicker.date >= endDatePicker.date {
            let alertController = UIAlertController(title: "Warning",
                                                message: "End date and time cannot be before or same as the start date and time",
                                                preferredStyle: UIAlertControllerStyle.alert)
        
            // Create a UIAlertAction object
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
            // Present the alert controller
            present(alertController, animated: true, completion: nil)
            
        }else if currentDate > startDatePicker.date {
            let alertController = UIAlertController(title: "Warning",
                                                    message: "Start Date and time cannot be in the past",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            
        } else if endDateChanged == 0 {
            let alertController = UIAlertController(title: "Warning",
                                                    message: "Change end date and time",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            
        }else {
            performSegue(withIdentifier: "SettingDone", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SettingDone" {
            
            // Obtain the object reference of the destination view controller
            let createEventFormViewController: CreateEventFormViewController = segue.destination as! CreateEventFormViewController
            
            //Pass the data object to the destination view controller object
            createEventFormViewController.infoPassed = infoPassed
            createEventFormViewController.doneSetting = 1
            createEventFormViewController.datePassed = dateToPass
        } else if segue.identifier == "selectDriver" {
            
            
        }
    }
    
}
