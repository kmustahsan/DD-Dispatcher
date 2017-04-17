//
//  CreateEventFormViewController.swift
//  DDDispatcher
//
//  Created by Yoonju Lee on 3/20/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces

class CreateEventFormViewController: UIViewController, CLLocationManagerDelegate {

    //set variables
    var groupNamePassed = ""
    var gid = ""
    var infoToPass = ["", "", "", ""] //[0] = group name, [1] = event name, [2] = event description
    var infoPassed = ["", "", "", ""]
    var doneSetting = 0
    var datePassed = ["", ""]
    var groupMembersToPass = [String]()
    var groupMembersToPassID = [String]()
    var selectedMembers = [Int]()
    
    //set outlets
    @IBOutlet var groupName: UITextField!
    @IBOutlet var eventName: UITextField!
    @IBOutlet var startDate: UITextField!
    @IBOutlet var endDate: UITextField!
    @IBOutlet var eventDescription: UITextView!
    @IBOutlet weak var locationView: UIView!
    var startSearchController: UISearchController?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var placesClient: GMSPlacesClient!
    var currentPlace: GMSPlace!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupName.text! = groupNamePassed
        print(gid)
        print(doneSetting)
        
        if doneSetting == 1 {
            groupName.text! = infoPassed[0]
            eventName.text! = infoPassed[1]
            eventDescription.text! = infoPassed[2]
            gid = infoPassed[3]
            startDate.text! = datePassed[0]
            endDate.text! = datePassed[1]
        }
        generateDD(groupID: gid)
        
        findCurrentPlace()

        
        
    }
    
    func findCurrentPlace() {
        placesClient = GMSPlacesClient.shared()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let likelihood = placeLikelihoodList.likelihoods[0]
                let place = likelihood.place
                print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
                print("Current Place address \(place.formattedAddress)")
                print("Current Place attributions \(place.attributions)")
                print("Current PlaceID \(place.placeID)")
                self.currentPlace = place
                self.autocompleteClicked()
            }
        })
    }
    
    func autocompleteClicked() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        //filter
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.address
        
        let northEast = CLLocationCoordinate2DMake(currentPlace.coordinate.latitude + 0.15, currentPlace.coordinate.longitude + 0.15)
        let southWest = CLLocationCoordinate2DMake(currentPlace.coordinate.latitude - 0.15, currentPlace.coordinate.longitude - 0.15)
        let userBound = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        
        
        resultsViewController?.autocompleteFilter = filter
        resultsViewController?.autocompleteBounds = userBound
        
        startSearchController = UISearchController(searchResultsController: resultsViewController)
        
        startSearchController?.searchBar.text = currentPlace.name
        
        locationView.addSubview((startSearchController?.searchBar)!)
        
        definesPresentationContext = true
    }
    
    
    func generateDD(groupID: String) {
        if groupID == "" { return }
        
        DataService.sharedInstance.queryFirebaseGroup(gid: groupID) { (snapshot) in
            guard let userArray : [String] = (snapshot.value as? NSDictionary)?["users"] as? [String]  else { return }
            for index in 0..<userArray.count {
                self.groupMembersToPassID.append(userArray[index])
            }
            for index in 0..<self.groupMembersToPassID.count {
                DataService.sharedInstance.queryFirebaseUserByUID(uid: self.groupMembersToPassID[index], completion: { (snapshot) in
                    guard let name : String = (snapshot.value as? NSDictionary)?["name"] as! String else { return }
                    self.groupMembersToPass.append(name)
                })
            }
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
        infoToPass[3] = gid
       
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
    
    @IBAction func saveEvent(_ sender: Any) {
        guard let groupName = groupName.text        else { return }
        guard let eventName = eventName.text        else { return }
        guard let eventDesc = eventDescription.text else { return }
        guard let startDate = startDate.text        else { return }
        guard let endDate   = endDate.text          else { return }
        
        
        var selectedMembersID = [String]()
        for index in 0..<selectedMembers.count {
            selectedMembersID.append(groupMembersToPassID[selectedMembers[index]])
        }
        // This is being sent to cache and Firebase
        var eventToSave : [String : Any] = [
            "event"       : eventName,
            "group"       : groupName,
            "gid"         : gid,
            "description" : eventDesc,
            "start"       : startDate,
            "end"         : endDate,
            "drivers"     : selectedMembersID
        ]
        
        let key = DataService.sharedInstance.createFirebaseEvent(values: eventToSave)
    
        // cache key
        
        if (Cache.sharedInstance.keyAlreadyExists(key: "Events")) {
            var existingData = Cache.sharedInstance.getValueForKey(key: "Events") as! [String : [String: Any]]
            existingData[key] = eventToSave
            Cache.sharedInstance.saveValue(value: existingData as AnyObject, forKey: "Events")
        } else {
            Cache.sharedInstance.addNewItemWithKey(key: "Events", value: [key: eventToSave]  as AnyObject)
        }
        
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
        
    }
}

extension CreateEventFormViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        
        if startSearchController?.isActive == true {
            startSearchController?.searchBar.text = place.name
        }
        
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
