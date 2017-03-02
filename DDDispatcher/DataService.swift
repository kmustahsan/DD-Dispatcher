//
//  DataService.swift
//  DDDispatcher
//
//  Created by macbookair11 on 3/1/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DataService {
    
    static let dataService = DataService()
    private var _ref = FIRDatabase.database().reference()
    private var _users = FIRDatabase.database().reference().child("users")
    
    var ref: FIRDatabaseReference {
        return _ref
    }
    var users: FIRDatabaseReference {
        return _users
    }
    
    func createFirebaseUser(_ users: String, uid: String, user: Dictionary<String, String>) {
        ref.child("users").child(uid).setValue(user)
    }
}
