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

class CreateGroupViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
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
        //We need to store this information in the DB
        performSegue(withIdentifier: "codeSegue", sender: self)
    }
    
    @IBAction func selectAvatar(_ sender: Any) {
        //Ask the user to select a picture
        
    }
    

    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
    
    
    
    
    
    
}

