//
//  CreateGroupViewController.swift
//  DDDispatcher
//
//  Created by Kashif on 2/25/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//
/*
 TODOS: Create Logic for selecting a Group Avatar
 
 */

import UIKit
import Firebase
import FirebaseDatabase


class CreateGroupViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()

    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        groupImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectGroupImageView)))
        groupImageView.isUserInteractionEnabled = true

        
        
    }
  /*
    override func viewDidLayoutSubviews() {
        setupUI()
    }*/
    
    func setupUI() {
        setupTextView()
    }

    func setupTextView() {
        textView.delegate = self
        textView.text = "What does this group? Who is it for?"
        textView.textColor = UIColor.lightGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = "";
        textView.textColor = UIColor.black
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "What does this group? Who is it for?"
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func handleSelectGroupImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            groupImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }

    func createGroupOnFirebase(groupInformation: [String: Any]) {
        let key = DataService.sharedInstance.createFirebaseGroup(values: groupInformation)
        let userInfo = Cache.sharedInstance.getValueForKey(key: "User") as! [String: Any]
        guard let uid = userInfo["uid"] as? String else { return }
        
        DataService.sharedInstance.queryFirebaseUserByUID(uid: uid) { (snapshot) in
            var groupArray = (snapshot.value as? NSDictionary)?["groups"] as! [String]
            if !groupArray.contains(key) {
                if groupArray[0] == "null" {
                    groupArray[0] = key
                } else {
                    groupArray.append(key)
                }
                DataService.sharedInstance.users.child(uid).updateChildValues(["groups" : groupArray])
            }
        }
        
        if (Cache.sharedInstance.keyAlreadyExists(key: "Groups")) {
            var existingData = Cache.sharedInstance.getValueForKey(key: "Groups") as! [String : [String: Any]]
            existingData[key] = groupInformation
            Cache.sharedInstance.saveValue(value: existingData as AnyObject, forKey: "Groups")
        } else {
            Cache.sharedInstance.addNewItemWithKey(key: "Groups", value: [key: groupInformation]  as AnyObject)
        }

    }
    
    @IBAction func submitGroup(_ sender: Any) {
        //CACHE: DONE Ref user
        let userInfo = Cache.sharedInstance.getValueForKey(key: "User") as! [String: Any]
        guard let uid = userInfo["uid"] as? String else { return }
        //End
        guard let groupName = groupNameTextField.text else { return }
        guard let groupDesctiption = textView.text else { return }
        
        let groupImage = groupImageView.image
        let uploadData = UIImageJPEGRepresentation(groupImage!, 0.1)
        DataService.sharedInstance.addGroupImageToStorage(image: uploadData!) { (groupAvatarUrl) in
            
            let dictionary : [String: Any] = [
                "admin"       : uid,
                "name"        : groupName,
                "description" : groupDesctiption,
                "avatar"      : groupAvatarUrl,
                "users"       : [uid]
            ]
            
            self.createGroupOnFirebase(groupInformation: dictionary)
            
        }
        
        
//
//        //CACHE: New group was created
       
        //Error 04.001: When a user did not enter group name
        if groupName == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter your group name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        //Error 04.002: When a user did not enter group description
        else if groupDesctiption == "What does this group? Who is it for?" {
            let alert = UIAlertController(title: "Error", message: "Please enter your group description", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            //TODO: This needs to segue to the group info page
            let destinationStoryboard = UIStoryboard(name: "Hub", bundle: nil)
            if let destinationViewController = destinationStoryboard.instantiateInitialViewController() {
            self.present(destinationViewController, animated: true)
            
            }
        }
    }
    

    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
 
}

