//
//  SelectDriverTableViewController.swift
//  DDDispatcher
//
//  Created by Yoonju Lee on 3/20/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class SelectDriverTableViewController: UITableViewController {

    //set variables
    var groupMembersPassed = [""]
    var drivers = [Int]()
    var eventInformationPassed = ["", "", "", "", ""] //[0] group Name, [1] event name, [2] description, [3] start date, [4] end date
    
    //set outlet
    @IBOutlet var groupMembersTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Select Drivers"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groupMembersPassed.count
    }

    
    //-------------------------------------
    // Return a Table View Cell
    //-------------------------------------
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupMemeberCell", for: indexPath) as UITableViewCell
        
        let rowNumber = (indexPath as NSIndexPath).row
        
        // Set the cell title to be the city name
        cell.textLabel!.text = groupMembersPassed[rowNumber]
        
        return cell
    }
    
    /*
     -----------------------------------
     MARK: - Table View Delegate Methods
     -----------------------------------
     */
    
    // Tapping a row (group member's name)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rowNumber = (indexPath as NSIndexPath).row
        
        if let cell = tableView.cellForRow(at: indexPath) {
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                drivers.append(rowNumber)
                print(drivers)
                
            } else {
                cell.accessoryType = .none
                
                let memberToBeRemoved = rowNumber
                
                for i in stride(from: 0, to: drivers.count, by: 1) {
                    print(drivers[i])
                    if i == memberToBeRemoved {
                        drivers.remove(at: i)
                        break
                    }
                }
                print(drivers)
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let vc =  CreateEventFormViewController()
        vc.selectedMembers = drivers

    }
    
    /*
     ---------------------------------
     MARK: - Prepare for Segue
     ---------------------------------
     */
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        print("button tapped")

        //performSegue(withIdentifier: "unwindSegueToCreateEventForm", sender: self)

    }
    
  
}
