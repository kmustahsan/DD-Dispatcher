//
//  JoinGroupViewController.swift
//  DDDispatcher
//
//  Created by Kashif Mustahsan on 3/7/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import Firebase

class JoinGroupViewController: UIViewController {
    @IBOutlet weak var groupCodeTextField: UITextField!
    @IBOutlet weak var joinGroup: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        Style.setupTextField(textField: groupCodeTextField)

        // Do any additional setup after loading the view.
    }
    @IBAction func submitCode(_ sender: Any) {
        guard let groupCode = groupCodeTextField.text else { return }
        
        //Error 03.001: group code is not valid
        print("wait")
        if isValidGroupCode(testStr: groupCode) {
            print("checked")
            let alert = UIAlertController(title: "Error", message: "Please enter the group code without special character", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                (_)in
            })
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }else {
            DataService.sharedInstance.queryFirebaseGroup(gid: groupCode) { (groupFound) in
                if groupFound {
                    let ref = DataService.sharedInstance.groups.child(groupCode)
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists() {
                            var usersArray = (snapshot.value as? NSDictionary)?["users"] as! [String]
                            if !usersArray.contains((FIRAuth.auth()!.currentUser?.uid)!) {
                                usersArray.append( (FIRAuth.auth()!.currentUser?.uid)!)
                                ref.updateChildValues([
                                    "users": usersArray])
                                //CACHE: DONE update user/group
                                var dict = cache.sharedCache.getUserInfo();
                                let arrayGroups = dict["groups"]! as! NSArray
                                let newArray = arrayGroups.adding(groupCode) as Array
                                dict["groups"] = newArray;
                                cache.sharedCache.writeDictionaryCache(name: "user", dict: dict)
                            }
                        } //CREATE ERROR ALERT : show error to say user is already in the group
                    })
                
                    self.confirmationAlert()
                } else {
                    //Error 03.002: group not found
                    self.errorAlert()
                }
            }
        }
    }
    
    
    func confirmationAlert() {
        let alert = UIAlertController(title: "Confirmation", message: "You joined Group!", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (_)in
            self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
        })
        
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Error 03.002: group not found
    func errorAlert() {
        let alert = UIAlertController(title: "Error", message: "Group Not Found", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (_)in
        })
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
    
    func isValidGroupCode(testStr:String) -> Bool {
        
        if testStr.contains("~") || testStr.contains("!") || testStr.contains("@") || testStr.contains("#") || testStr.contains("$") || testStr.contains("%") || testStr.contains("^") || testStr.contains("&") || testStr.contains("*") || testStr.contains("(") || testStr.contains(")") || testStr.contains("{") || testStr.contains("}") || testStr.contains("[") || testStr.contains("]") {
            return true
        }else if testStr == "" {
            return true
        }
        return false
    }
    

}
