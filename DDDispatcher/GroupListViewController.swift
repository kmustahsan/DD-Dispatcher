//
//  GroupListViewController.swift
//  DDDispatcher
//
//  Created by Neel A on 2/27/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class GroupListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var groupInfoTabelView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //set table view delegate, and dataSource
        groupInfoTabelView.delegate = self
        groupInfoTabelView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - TableViewDataSource
     // Methods
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfGroups: Int = 0 //userGroupsArray.length
        
        return numberOfGroups;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userGroups") as! GroupNameTableViewCell
        //set Image and Name of cell
        
        //cell.groupImage =
        cell.groupName.text = "Testing Group"
         //CACHE: retrieve info
        
        
        return cell;
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetailedGroup")
        {
            let sender = sender as! GroupNameTableViewCell
            let index = groupInfoTabelView.indexPath(for: sender)
            let row = index?.row;
            //use row to get groupID in the dataSource...
            
            let dvc = segue.destination as! GroupInfoViewController
            //pass on some of the group info if needed... or its cached and can just pass on the id;
            dvc.groupID = 2 //pass groupID from the cell
        }
    }
    
    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
    
    
    
}

