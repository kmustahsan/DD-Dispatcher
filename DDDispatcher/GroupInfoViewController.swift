//
//  GroupInfoViewController.swift
//  DDDispatcher
//
//  Created by Neel A on 2/27/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import Firebase

class GroupInfoViewController: UIViewController {
    
    @IBOutlet var groupImage: UIImageView!
    @IBOutlet var groupName: UILabel!
    @IBOutlet var groupDesc: UILabel!
    @IBOutlet var leaveGroupButton: UIButton!
    @IBOutlet var groupCode: UILabel!
    
    var groupID = String()
    var groups = Cache.sharedInstance.getValueForKey(key: "Groups") as! [String : [String: Any]]
    var currentGroup = [String: Any]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if groupID == nil { return }
        currentGroup = groups[groupID]!
        let currentGroupName = groups[groupID]?["name"] as! String
        let avatarUrl = currentGroup["avatar"] as! String
        let url = NSURL(string: avatarUrl)
        let task = URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
            if error != nil {
                print(error ?? "Session error")
                return
            }
            DispatchQueue.main.async {
                self.groupImage.image = UIImage(data: data!)
            }
        })
        task.resume()
        
        self.title = currentGroup["name"] as! String
        groupName.text = currentGroup["name"] as! String
        groupDesc.text = currentGroup["description"] as! String
        groupCode.text = groupID
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leaveGroupButtonClicked(_ sender: UIButton) {
        
        
        DataService.sharedInstance.removeUserFromGroup(gid: groupID, uid: (FIRAuth.auth()?.currentUser?.uid)!)
//        groups.removeValue(forKey: groupID)
//        Cache.sharedInstance.saveValue(value: groups as AnyObject, forKey: "Groups")
//        var userInfo = Cache.sharedInstance.getValueForKey(key: "User") as! [String : [String: Any]]
//        var userGroups = userInfo["groups"]
//        userGroups?.removeValue(forKey: groupID)
//        userInfo["groups"] = userGroups
//        Cache.sharedInstance.saveValue(value: userInfo as AnyObject, forKey: "User")
    
        print("hi")
    }
    
    @IBAction func CopytotheClipboard(_ sender: Any) {
        
        UIPasteboard.general.string = groupCode.text
        
        let alertController = UIAlertController(title: "Message",
                                                message: "Copied text to the clipboard",
                                                preferredStyle: UIAlertControllerStyle.alert)
            
        // Create a UIAlertAction object
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
        
    }
    
}



