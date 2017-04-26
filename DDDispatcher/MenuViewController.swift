//
//  MenuViewController.swift
//  DDDispatcher
//
//  Created by Woo Jin Kye on 2017. 2. 27..
//  Copyright © 2017년 DD Dispatcher. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    
    let options = ["nil", "Groups", "Create Group", "Create Event", "Join Group"]
    let numberOfRowsAtSection: [Int] = [0, 5]
    private var previousIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        if section < numberOfRowsAtSection.count {
            rows = numberOfRowsAtSection[section]
        }
        
        return rows
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 150
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell")!
            return cell
        }
        else {
            let optionsValue = options[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")!
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            cell.textLabel?.text = optionsValue
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)  {
        if let index = previousIndex {
            tableView.deselectRow(at: index as IndexPath, animated: true)
        }
        if indexPath.row == 1 {
            segueToStoryboard(storyboard: "GroupListAndInfo")
        }
        if indexPath.row == 2 {
            segueToStoryboard(storyboard: "CreateGroup")
        }
        else if indexPath.row == 3 {
            segueToStoryboard(storyboard: "CreateEvent")
        }
        else if indexPath.row == 4 {
            segueToStoryboard(storyboard: "JoinGroup")
        }
        previousIndex = indexPath as NSIndexPath?
    }
    
    func segueToStoryboard(storyboard: String) {
        let destinationStoryboard = UIStoryboard(name: storyboard, bundle: nil)
        if let destinationViewController = destinationStoryboard.instantiateInitialViewController() {
            self.present(destinationViewController, animated: true)

        }
    }
    
}
