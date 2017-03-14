//
//  JoinGroupViewController.swift
//  DDDispatcher
//
//  Created by Kashif Mustahsan on 3/7/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import UIKit

class JoinGroupViewController: UIViewController {
    @IBOutlet weak var groupCodeTextField: UITextField!
    @IBOutlet weak var joinGroup: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        Style.setupTextField(textField: groupCodeTextField)

        // Do any additional setup after loading the view.
    }
    func checkCode(code: String) {
        // Firebase query
    }
    
    
    @IBAction func sendBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
    }
    
    @IBAction func submitCode(_ sender: Any) {
        let alert = UIAlertController(title: "Confirmation", message: "You joined Group!", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (_)in
            self.performSegue(withIdentifier: "unwindMenuSegue", sender: self)
        })
        
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    

}
