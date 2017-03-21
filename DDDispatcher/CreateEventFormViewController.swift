//
//  CreateEventFormViewController.swift
//  DDDispatcher
//
//  Created by Yoonju Lee on 3/20/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class CreateEventFormViewController: UIViewController {

    //set variables
    var groupNamePassed = ""
    var infoToPass = ["", "", ""] //[0] = group name, [1] = event name, [2] = event description
    var infoPassed = ["", "", ""]
    var doneSetting = 0
    var datePassed = ["", ""]
    var groupMembersToPass = ["Pikachu Raichu", "Yoonju Lee", "Woo Jin Kye"]
    
    //set outlets
    @IBOutlet var groupName: UITextField!
    @IBOutlet var eventName: UITextField!
    @IBOutlet var startDate: UITextField!
    @IBOutlet var endDate: UITextField!
    @IBOutlet var eventDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupName.text! = groupNamePassed
        
        print(doneSetting)
        
        if doneSetting == 1 {
            groupName.text! = infoPassed[0]
            eventName.text! = infoPassed[1]
            eventDescription.text! = infoPassed[2]
            startDate.text! = datePassed[0]
            endDate.text! = datePassed[1]
        }
        
    }

    
    /*
     ---------------------------------
     MARK: - Keyboard Handling Methods
     ---------------------------------
     */
    
    /*
    // This method is invoked when the user taps the Done key on the keyboard
    @IBAction func keyboardDone(_ sender: UITextField) {
        
        // Once the text field is no longer the first responder, the keyboard is removed
        sender.resignFirstResponder()
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
   
            // when user clicks outside of the textfield
            if eventName.isFirstResponder && (touch.view != eventName) {
                
                eventName.resignFirstResponder()
            }
            
            //when user clicks outside of the textview
            if eventDescription.isFirstResponder && (touch.view != eventDescription) {
                
                eventDescription.resignFirstResponder()
            }
        }
        super.touchesBegan(touches, with:event)
    }
    
    /*
     ---------------------------------
     MARK: - Prepare for Segue
     ---------------------------------
     */
    
    @IBAction func setDateAndTimeButtonClicked(_ sender: Any) {
       
        if doneSetting == 0 {
            infoToPass[0] = groupNamePassed
        } else {
            infoToPass[0] = groupName.text!
        }
        infoToPass[1] = eventName.text!
        infoToPass[2] = eventDescription.text!
       
        performSegue(withIdentifier: "SetDate", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SetDate" {
            
            // Obtain the object reference of the destination view controller
            let setDateAndTimeViewController: SetDateAndTimeViewController = segue.destination as! SetDateAndTimeViewController
            
            //Pass the data object to the destination view controller object
            setDateAndTimeViewController.infoPassed = infoToPass
        } else if segue.identifier == "selectDriver" {
            
            if eventName.text! == "" || startDate.text! == "" || endDate.text! == "" || startDate.text! == "Start Date:" || endDate.text! == "End Date" {
                let alertController = UIAlertController(title: "Warning",
                                                    message: "Please fill out the form completely",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
                present(alertController, animated: true, completion: nil)
            }
            
            let selectDriverTableViewController: SelectDriverTableViewController = segue.destination as! SelectDriverTableViewController
            
            selectDriverTableViewController.eventInformationPassed[0] = infoPassed[0]
            selectDriverTableViewController.eventInformationPassed[1] = infoPassed[1]
            selectDriverTableViewController.eventInformationPassed[2] = infoPassed[2]
            selectDriverTableViewController.eventInformationPassed[3] = datePassed[0]
            selectDriverTableViewController.eventInformationPassed[4] = datePassed[1]
            selectDriverTableViewController.groupMembersPassed = groupMembersToPass
        }
    }

}
