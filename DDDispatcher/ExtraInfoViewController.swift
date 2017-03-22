//
//  ExtraInfoViewController.swift
//  DDDispatcher
//
//  Created by kmustahsan on 2/18/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ExtraInfoViewController: UIViewController, UITextFieldDelegate  {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        Style.setupTextField(textField: nameTextField)
        nameTextField.becomeFirstResponder()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        Style.activeTextField(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            nameTextField.resignFirstResponder()
        }
        Style.inactiveTextField(textField: textField)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func segueToHubScreen(_ sender: Any) {
        guard let nameString = nameTextField.text else { return }
        let uid = FIRAuth.auth()?.currentUser?.uid
        let userString = "users/" + uid!
        let ref = FIRDatabase.database().reference().child(userString)
        ref.updateChildValues([
            "name": nameString])
         //CACHE: DONE update
        var dict = cache.sharedCache.getUserInfo()
        dict["name"] = nameString
        cache.sharedCache.writeDictionaryCache(name: "user", dict: dict)
        let destinationStoryboard = UIStoryboard(name: "Hub", bundle: nil)
        if let destinationViewController = destinationStoryboard.instantiateInitialViewController() {
            self.present(destinationViewController, animated: true)
        }

    }
    
   
    
}
