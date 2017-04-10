//
//  CreateEventViewController.swift
//  DDDispatcher
//
//  Created by Yoonju Lee on 3/20/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // Dictionary containing groups that the user is admin in
    var dict_adminGroups = [String]()
    
    // store group names (keys of dictionary)
    //let dict = cache.sharedCache.getUserInfo()
    var groupNames = [String]()
    var groupName = ""
    var gid = ""
    var keys = [String]()
    
    //value of dict_adminGroups
    var groupLogos = ["logo.png", "logo.png", "logo.png"]
    
    //set outletsc
    @IBOutlet var groupsTableView: UITableView!
    
    
    // value of dict_adminGroups
    // [0] = group name, [1] = event title, [2] = description, [3]=start date, [4] = end date
    //var eventInformation = ["group.png", "ABC event", "bring your own bear", "Dec 20 20:00", "Dec 20 22:00"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // need to check if event exists first
        if (Cache.sharedInstance.keyAlreadyExists(key: "Groups")) {
            let groupInformation = Cache.sharedInstance.getValueForKey(key: "Groups") as! [String : [String: Any]]
            keys = Array(groupInformation.keys)
            for index in 0..<groupInformation.count {
                groupNames.append(groupInformation[keys[index]]?["name"] as! String)
            }
            print(groupNames)
            dict_adminGroups = groupNames
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     --------------------------------------
     MARK: - Table View Data Source Methods
     --------------------------------------
     */
    // Asks the data source to return the number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(dict_adminGroups.count)
        return dict_adminGroups.count
    }
    
    // Asks the data source to return a cell to insert in a particular table view location
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Identify the row number
        let rowNumber = (indexPath as NSIndexPath).row
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "GroupNameAndImage") as UITableViewCell!
        
        groupName = groupNames[rowNumber]
        gid = keys[rowNumber]
        
        //add the name of groups
        cell.textLabel!.text = groupName
        
        // Add the group logo
        cell.imageView!.image = UIImage(named: groupLogos[rowNumber])
        
        return cell
    }
    
    /*
     ----------------------------------
     MARK: - Table View Delegate Method
     ----------------------------------
     */
    
    // This method is invoked when the user taps a table view row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Identify the row number
        let rowNumber = (indexPath as NSIndexPath).row
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        groupName = groupNames[rowNumber]
        gid = keys[rowNumber]
        
        
        performSegue(withIdentifier: "FormView", sender: self)
        
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    
    @IBAction func NotaGroupEventButtonClicked(_ sender: Any) {
        
        groupName = "Not a Group Event"
        performSegue(withIdentifier: "FormView", sender: self)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FormView" {
            
            // Obtain the object reference of the destination view controller
            let createEventFormViewController: CreateEventFormViewController = segue.destination as! CreateEventFormViewController
            
            //Pass the data object to the destination view controller object
            createEventFormViewController.groupNamePassed = groupName
            createEventFormViewController.gid = gid
            
        } 
    }
    
    
    
}
