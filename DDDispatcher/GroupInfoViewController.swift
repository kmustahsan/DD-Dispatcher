//
//  GroupInfoViewController.swift
//  DDDispatcher
//
//  Created by Neel A on 2/27/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class GroupInfoViewController: UIViewController {
    
    @IBOutlet var groupImage: UIImageView!
    @IBOutlet var groupName: UILabel!
    @IBOutlet var groupDesc: UILabel!
    @IBOutlet var leaveGroupButton: UIButton!
    
    var groupID : Int = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        //get the groupInfo from query or cache
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //set button to round
        leaveGroupButton.layer.cornerRadius = 0.5 * leaveGroupButton.bounds.size.width
        leaveGroupButton.clipsToBounds = true
        
        //size to fit DESC
        groupDesc.sizeToFit();
        
        //set image, name, decs
        
        //set navigation title to group name
        self.title = "Group Name"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leaveGroupButtonClicked(_ sender: UIButton) {
        //user leaves group, remove from group on backend
        //CACHE: remove user
        //DATA: Implement
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}



