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
    

    var groups = [String : [String: Any]]()
    var keys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //change navigation bar style
        UINavigationBar.appearance().barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

 
        
        if Cache.sharedInstance.keyAlreadyExists(key: "Groups") {
            groups = Cache.sharedInstance.getValueForKey(key: "Groups") as! [String : [String: Any]]
            keys = Array(groups.keys)
        }
        
        groupInfoTabelView.delegate = self
        groupInfoTabelView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfGroups = groups.count
        return numberOfGroups;
    }
    
    //Woo- fix; the label isn't being palced correctly.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userGroups") as! GroupNameTableViewCell
        let currentGroupName = groups[keys[indexPath.row]]?["name"] as! String
        let avatarUrl = groups[keys[indexPath.row]]?["avatar"] as! String
        let url = NSURL(string: avatarUrl)
        let task = URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            if error != nil {
                print(error ?? "Session error")
                return
            }
            DispatchQueue.main.async {
                cell.groupImage.image = UIImage(data: data!)
                cell.groupImage.layer.cornerRadius = cell.groupImage.frame.size.width / 2;
                cell.groupImage.clipsToBounds = true;
            }
        })
        task.resume()

        cell.groupName.text = currentGroupName

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
            dvc.groupID = keys[row!] //pass groupID from the cell
        }
    }
    
    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
}

