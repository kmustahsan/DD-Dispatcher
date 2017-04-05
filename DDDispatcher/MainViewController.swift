//
//  LoginViewController.swift
//  DDDispatcher
//
//  Created by kmustahsan on 2/18/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import FirebaseDatabase

class MainViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var mailView: UIView!
    var newEmailUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
//================== UI Setup =================================
    
    func setupUI() {
        Style.setupTextField(textField: emailTextField)
        emailTextField.keyboardType = .emailAddress
        Style.setupTextField(textField: passwordTextField)
        Style.pillButton(button: loginButton)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        Style.activeTextField(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        Style.inactiveTextField(textField: textField)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
//================== End of UI Setup ===========================
//================== OAuth Setup ===============================
    
    // Facebook button setup
    @IBAction func handleFacebookLogin(_ sender: Any) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if let err = error {
                print("Failed to login to Firebase with Facebook: ", err)
                return
            }
            self.connectFacebookToFirebase()
        }
    }
    
    func connectFacebookToFirebase() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if let err = error {
                print("Failed to start graph request:", err)
                return
            }
            guard let data = result as? [String:Any] else  { return }
            let name = 	data["name"]
            let email = data["email"]
            

          
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if let err = error {
                    print("Something went wrong with our FB user: ", err )
                    return
                }
                print("Successfully logged into Firebase with Facebook: ", user ?? "")
                guard let uid = user?.uid else { return }
                let dictionary : [String: Any] = [
                    "name"       : name as! String,
                    "email"      : email as! String,
                    "groups"     : ["Group1", "Group2"],
                    "provider"   : "Facebook",
                    "uid"        : uid
                ]
                DataService.sharedInstance.createFirebaseUser(uid: uid, user: dictionary)
                //CACHE: DONE store user info here
                cache.sharedCache.writeDictionaryCache(name: "user", dict: dictionary);
                DispatchQueue.main.async(execute: {
                    self.segue()
                })
                
            })
        }
    }
    // End of Facebook button setup
    
    //Google button setup
    @IBAction func handleGoogleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("Failed to login via Google: ", err)
            return
        }
        print("Successfully logged into Google", user)
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (firUser, error) in
            if let err = error {
                print("Failed to log into Firebase with Google: ", err)
                return
            }
            guard let uid = firUser?.uid else { return }
            let dictionary : [String: Any] = [
                "name"       : user.profile.name,
                "email"      : user.profile.email,
                "groups"     : ["Group1", "Group2"],
                "provider"   : "Google",
                "uid"        : uid
            ]
            DataService.sharedInstance.createFirebaseUser(uid: uid, user: dictionary)
            //CACHE: DONE store user info here
            print("stored in cache")
            cache.sharedCache.writeDictionaryCache(name: "user", dict: dictionary)
            DispatchQueue.main.async(execute: {
                self.segue()
            })
        })
    }
// End of Google button setup
    
    @IBAction func loginOnClick(_ sender: Any) {
        guard let inputEmail = emailTextField.text else { return }
        guard let inputPassword = passwordTextField.text else { return }
        
        //Error 01.001: If a user does not fill out email text field and password text field.
        if emailTextField.text == "" && passwordTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter your email & password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        //Error 01.002: If a user does not fill out the email text field
        else if emailTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter your email", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        //Error 01.003: If a user does not fill out the password text field
        else if passwordTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter your password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        //Error 01.004: When a user put an invalid email
        else if !isValidEmail(testStr: emailTextField.text!) {
            let alert = UIAlertController(title: "Error", message: "Email you enter is not valid", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        if isValidPassword(inputPassword: inputPassword) {
            FIRAuth.auth()!.signIn(withEmail: inputEmail, password: inputPassword, completion: { (user, error) in
                if error != nil  {
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            print("invalid email")
                        case .errorCodeEmailAlreadyInUse:
                            print("in use")
                        case .errorCodeUserNotFound:
                            FIRAuth.auth()!.createUser(withEmail: inputEmail, password: inputPassword, completion: { (user, error) in
                                if let err = error {
                                    print("Error with email user", err)
                                }
                                guard let uid = user?.uid else { return }
                                let dictionary : [String: Any] = [
                                    "name"       : "nil",
                                    "email"      : inputEmail,
                                    "groups"     : ["Group1", "Group2"],
                                    "provider"   : "Email",
                                    "uid"        : uid
                                ]
                                DataService.sharedInstance.createFirebaseUser(uid: uid, user: dictionary)
                                //CACHE: DONE store user info here
                                cache.sharedCache.writeDictionaryCache(name: "user", dict: dictionary);
                            })
                            DispatchQueue.main.async(execute: {
                                self.newEmailUser = true
                                self.segue()
                            })
                        default:
                            print("Create User Error: \(error!)")
                        }
                    }
                    return
                }
            })
        }
        //Error 01.005: When a user put an invalid email
        else {
            let alert = UIAlertController(title: "Error", message: "Password you enter is not valid", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func isValidPassword(inputPassword :String) -> Bool {
        return inputPassword.characters.count > 6
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func segue() {
        if newEmailUser {
            performSegue(withIdentifier: "infoSegue", sender: self)
        } else {
            let destinationStoryboard = UIStoryboard(name: "Hub", bundle: nil)
            if let destinationViewController = destinationStoryboard.instantiateInitialViewController() {
                self.present(destinationViewController, animated: true)
            }
        }
    }

}
