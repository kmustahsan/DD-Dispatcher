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
    var currentGroupName = ""
    var gid = ""
    var keys = [String]()
    var groups = [String : [String: Any]]()
    
    //set outletsc
    @IBOutlet var groupsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //change navigation bar style
        UINavigationBar.appearance().barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
     
        
        
        // need to check if event exists first
        if (Cache.sharedInstance.keyAlreadyExists(key: "Groups")) {
            groups = Cache.sharedInstance.getValueForKey(key: "Groups") as! [String : [String: Any]]
            keys = Array(groups.keys)
            for index in 0..<groups.count {
                groupNames.append(groups[keys[index]]?["name"] as! String)
            }
            print(groupNames)
            dict_adminGroups = groupNames
        }
    }
    
    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupNameAndImage") as! GroupNameTableViewCell
        
        currentGroupName = groupNames[rowNumber]
        gid = keys[rowNumber]
        
        //add the name of groups
        cell.groupName.text = currentGroupName
        
        // Add the group logo
        let avatarUrl = groups[keys[indexPath.row]]?["avatar"] as! String
        let url = NSURL(string: avatarUrl)
        let task = URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
            if error != nil {
                print(error ?? "Session error")
                return
            }
            DispatchQueue.main.async {
                cell.groupImage.image = UIImage(data: data!)
                cell.groupImage.layer.cornerRadius = cell.groupImage!.frame.size.width / 2;
                cell.groupImage.clipsToBounds = true;
            }
        })
        task.resume()
        
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
        
        currentGroupName = groupNames[rowNumber]
        gid = keys[rowNumber]
        
        
        performSegue(withIdentifier: "FormView", sender: self)
        
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    /*
    @IBAction func NotaGroupEventButtonClicked(_ sender: Any) {
        
        groupName = "Not a Group Event"
        performSegue(withIdentifier: "FormView", sender: self)
        
 
    }*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FormView" {
            
            // Obtain the object reference of the destination view controller
            let createEventFormViewController: CreateEventFormViewController = segue.destination as! CreateEventFormViewController
            
            //Pass the data object to the destination view controller object
            createEventFormViewController.groupNamePassed = currentGroupName
            createEventFormViewController.gid = gid
            
        } 
    }
    
}
