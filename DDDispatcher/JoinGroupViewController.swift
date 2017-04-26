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

        //Keyboard
 
        // Do any additional setup after loading the view.
    }
    func isValidGroupCode(testStr:String) -> Bool {
        
        if testStr.contains("~") || testStr.contains("!") || testStr.contains("@") || testStr.contains("#") || testStr.contains("$") || testStr.contains("%") || testStr.contains("^") || testStr.contains("&") || testStr.contains("*") || testStr.contains("(") || testStr.contains(")") || testStr.contains("{") || testStr.contains("}") || testStr.contains("[") || testStr.contains("]") {
            return true
        }else if testStr == "" {
            return true
        }
        return false
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
        } else {
            var userInfo = Cache.sharedInstance.getValueForKey(key: "User") as!  [String: Any]
            DataService.sharedInstance.queryFirebaseGroup(gid: groupCode) { (snapshot) in
                    var data = (snapshot.value as? NSDictionary)
                    var usersArray = data?["users"] as! [String]
                    if !usersArray.contains((FIRAuth.auth()!.currentUser?.uid)!) {
                        usersArray.append( (FIRAuth.auth()!.currentUser?.uid)!)
                        DataService.sharedInstance.groups.child(groupCode).updateChildValues([
                            "users": usersArray])
                        let currentUser = DataService.sharedInstance.users.child((FIRAuth.auth()?.currentUser?.uid)!)
                    }
                    var newGroupInfo: [String: Any] = [
                        "admin"       : data!["admin"],
                        "name"        : data!["name"],
                        "description" : data!["description"],
                        "avatar"      : data!["avatar"],
                        "users"       : usersArray
                    ]
                    var existingData = [String : [String: Any]]()
                    if (Cache.sharedInstance.keyAlreadyExists(key: "Groups")) {
                        existingData = Cache.sharedInstance.getValueForKey(key: "Groups") as! [String : [String: Any]]
                        existingData[groupCode] = newGroupInfo
                        Cache.sharedInstance.saveValue(value: existingData as AnyObject, forKey: "Groups")
                    } else {
                        Cache.sharedInstance.addNewItemWithKey(key: "Groups", value: [groupCode: newGroupInfo]  as AnyObject)
                    }
            }
            DataService.sharedInstance.queryFirebaseUserByUID(uid: (FIRAuth.auth()?.currentUser?.uid)!, completion: { (snapshot) in
                var data = (snapshot.value as? NSDictionary)
                var groupArray = data?["groups"] as! [String]
                if (!groupArray.contains(groupCode)) {
                    groupArray.append(groupCode)
                    if let index = groupArray.index(of: "null") {
                        groupArray.remove(at: index)
                    }
                    DataService.sharedInstance.users.child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["groups": groupArray])
                }
                //CACHE: DONE update user/group
                var usersGroup = userInfo["groups"] as! [String]
                if (!usersGroup.contains(groupCode)) {
                    usersGroup.append(groupCode)
                    userInfo["groups"] = usersGroup
                    Cache.sharedInstance.saveValue(value: userInfo as AnyObject, forKey: "User")
                }
                
            })
        }
        self.confirmationAlert()
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
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
    

    
    //*******************************************
    //MARK: Keyboard
    //*******************************************
    func keyboardWillShow(notification: NSNotification) {
     
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= 130
        }
    
    }
    
    func keyboardWillHide(notification: NSNotification) {
 
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 130
            }
    
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        Style.activeTextField(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == groupCodeTextField {
            groupCodeTextField.resignFirstResponder()
        }
        Style.inactiveTextField(textField: textField)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

}
