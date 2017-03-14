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

class CreateGroupViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var groupNameTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        setupButton()
        setupTextView()
    }
    
    func setupButton() {
        createGroupButton.layer.cornerRadius = 15
        avatarButton.layer.borderWidth = 1
        avatarButton.layer.masksToBounds = false
        avatarButton.layer.backgroundColor = UIColor.white.cgColor
        avatarButton.layer.borderColor = UIColor.white.cgColor
        avatarButton.layer.cornerRadius = avatarButton.frame.height/2
        avatarButton.clipsToBounds = true
    }
    
    func setupTextView() {
        textView.delegate = self
        textView.text = "What does this group? Who is it for?"
        textView.textColor = UIColor.lightGray
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
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
    
    
    @IBAction func submitGroup(_ sender: Any) {
        //CACHE: Ref user
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        //End
        guard let groupName = groupNameTextField.text else { return }
        guard let groupDesctiption = textView.text else { return }
        let dictionary : [String: Any] = [
            "admin"       : uid,
            "name"        : groupName,
            "description" : groupDesctiption,
            "users"       : [uid]
        ]
        DataService.sharedInstance.createFirebaseGroup(values: dictionary)
        
        //CACHE: New group was created
        
        //TODO: This needs to segue to the group info page
        let destinationStoryboard = UIStoryboard(name: "Hub", bundle: nil)
        if let destinationViewController = destinationStoryboard.instantiateInitialViewController() {
            self.present(destinationViewController, animated: true)
            
        }
    }
    
    @IBAction func selectAvatar(_ sender: Any) {
        //Ask the user to select a picture
        //CACHE: store user info here
        
    }
    

    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
    
    
    
    
    
    
}

