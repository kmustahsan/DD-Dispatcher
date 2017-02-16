//
//  ViewController.swift
//  DDDispatcher
//
//  Created by Kashif on 2/09/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFacebookButton()
        setupGoogleButton()
        setupTwitterButton()
    }
    
    // Facebook button setup
    fileprivate func setupFacebookButton() {
        let fbButton = UIButton(type: .system)
        fbButton.backgroundColor = .blue
        //This is temporary. Better to use constraints
        fbButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        fbButton.setTitle("Facebook Login", for: .normal)
        fbButton.setTitleColor(.white, for: .normal)
        view.addSubview(fbButton)
        fbButton.addTarget(self, action: #selector(handleFacebookLogin), for: .touchUpInside)
    }
    
    func handleFacebookLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if let err = error {
                print("Failed to login to Firebase with Facebook: ", err)
                return
            }
            
            self.showEmailAddress()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Successfully logged out of Facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let err = error {
            print(err)
            return
        }
        
        showEmailAddress()
    }
    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Something went wrong with our FB user: ", err )
                return
            }
            
            print("Successfully logged into Firebase with Facebook: ", user ?? "")
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            
            if let err = error {
                print("Failed to start graph request:", err)
                return
            }
            print(result ?? "")
        }
    }
    // End of Facebook button setup

    
    //Google button setup
    fileprivate func setupGoogleButton() {
        
        let googleButton = UIButton(type: .system)
        //This is temporary. Better to use constraints
        googleButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        googleButton.backgroundColor = .orange
        googleButton.setTitle("Google Login", for: .normal)
        googleButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        googleButton.setTitleColor(.white, for: .normal)
        view.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func handleGoogleLogin() {
        GIDSignIn.sharedInstance().signIn()
    }
    // End of Google button setup
    
    //Twitter button setup
    fileprivate func setupTwitterButton() {
        let twitterButton = UIButton(type: .system)
        //This is temporary. Better to use constraints
        twitterButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        twitterButton.backgroundColor = .cyan
        twitterButton.setTitle("Twitter Login", for: .normal)
        twitterButton.addTarget(self, action: #selector(handleTwitterLogin), for: .touchUpInside)
        twitterButton.setTitleColor(.white, for: .normal)
        view.addSubview(twitterButton)
    }
    func handleTwitterLogin() {
        Twitter.sharedInstance().logIn { (session, error) in
            if let err = error {
                print("Failed to login via Twitter: ", err)
                return
            }
            print("Successfully logged into Twitter")
            
            
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                
                if let err = error {
                    print("Failed to login to Firebase with Twitter: ", err)
                    return
                }
                
                print("Successfully logged into Firebase with Twitter: ", user?.uid ?? "")
                
            })
            
        }
    }
    //End of Twitter button setup
    
}

