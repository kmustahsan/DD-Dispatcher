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

    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
  /*
    override func viewDidLayoutSubviews() {
        setupUI()
    }*/
    
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
        avatarButton.contentMode = .scaleAspectFit
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
    
    
    @IBAction func submitGroup(_ sender: Any) {
        //CACHE: DONE Ref user
        let dict = cache.sharedCache.getUserInfo()
        guard let uid = dict["uid"] as? String else {return}
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
        //NEED GROUP ID in Dict if possible
        //cache.sharedCache.writeDictionaryCache(name: "groups", dict: dictionary)
        
        
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
    
    //**********************************
    //MARK: Upload Image
    //**********************************
    
    @IBAction func selectAvatar(_ sender: Any) {
        print("selectAvatar\n")
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated:true, completion:nil)
    }

    //get out of the library
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("dismiss image picker\n")
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       // avatarButton.contentMode = .scaleAspectFit
        self.dismiss(animated: true, completion: nil)

        
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
           // avatarButton.setImage(selectedImage, for: UIControlState.normal)
            avatarButton.imageView?.image = selectedImage

print("111")
        }else if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //avatarButton.setImage(selectedImage, for: UIControlState.normal)
            avatarButton.imageView?.image = selectedImage
print("222")
        }else {
            print("somethings wrong")
        }

       // self.dismiss(animated: true, completion: nil)
    }
}

