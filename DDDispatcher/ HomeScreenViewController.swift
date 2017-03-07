//
//  LoginViewController.swift
//  DDDispatcher
//
//  Created by macbookair11 on 2/18/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class HomeScreenViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var mailView: UIView!
    
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeScreenViewController.dismissKeyboard))
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
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Something went wrong with our FB user: ", err )
                return
            }
            print("Successfully logged into Firebase with Facebook: ", user ?? "")
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "hubSegue", sender: self)
            })
           
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if let err = error {
                print("Failed to start graph request:", err)
                    return
            }
            //TODO:This is where we can store user's personal data from Facebook to Firebase
            print(result ?? "")
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
        /* We can store user information to Firebase here.. 
            user.profile.name
            user.profile.email
         
         */
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to log into Firebase with Google: ", err)
                return
            }
            
            guard let uid = user?.uid else { return }
            print("Successfully logged into Firebase with Google: ", uid)
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "hubSegue", sender: self)
            })
        })
    }
// End of Google button setup
    
    @IBAction func loginOnClick(_ sender: Any) {
        guard let inputEmail = emailTextField.text else { return }
        guard let inputPassword = passwordTextField.text else { return }
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
                                print("Created user")
                            })
                        default:
                            print("Create User Error: \(error!)")
                        }
                    }
                    return
                }
            })
            segueTo()
        }
        
    }
    
    func isValidPassword(inputPassword :String) -> Bool {
        return inputPassword.characters.count > 6
    }
    
    
    func segueTo () {
        //TODO: We must make a backendquery here. If the user is logging in for the first time and is using an email, or Twitter (check on this), then we need their name. Otherwise, continue on. 
        let newEmailUser = true
        
        if newEmailUser {
            performSegue(withIdentifier: "infoSegue", sender: self)
        } else {
            performSegue(withIdentifier: "hubSegue", sender: self)
        }
    }
    
    
    
}
