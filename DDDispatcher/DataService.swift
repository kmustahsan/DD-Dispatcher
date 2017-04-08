//
//  DataService.swift
//  DDDispatcher
//
//  Created by kmustahsan on 3/1/17.
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let sharedInstance = DataService()
    private var _ref = FIRDatabase.database().reference()
    private var _users = FIRDatabase.database().reference().child("users")
    private var _groups = FIRDatabase.database().reference().child("groups")
    private var _groupUsers = FIRDatabase.database().reference().child("groups").child("users")
    private var _events = FIRDatabase.database().reference().child("events")
    
    var ref: FIRDatabaseReference {
        return _ref
    }
    
    var users: FIRDatabaseReference {
        return _users
    }
    
    var groups: FIRDatabaseReference {
        return _groups
    }
    
    var queryUserRef : FIRDatabaseReference {
        return _users
    }
    
    var queryGroupRef : FIRDatabaseReference {
        return _groups
    }
    
    var groupUsers : FIRDatabaseReference {
        return _groupUsers
    }
    
    var events : FIRDatabaseReference {
        return _events
    }
    //Creation
    func createFirebaseUser(uid: String, user: Dictionary<String, Any>) {
        users.child(uid).setValue(user)
    }
    
    func createFirebaseGroup(values: Dictionary<String, Any>) -> String {
        let autoId = groups.childByAutoId()
        autoId.setValue(values)
        let key = autoId.key
        return key
    }
    
    func createFirebaseEvent(values: Dictionary<String, Any>) -> String {
        let autoId = events.childByAutoId()
        autoId.setValue(values)
        let key = autoId.key
        return key
    }
    
    //Queries
    func queryFirebaseUserByUID(uid: String, completion: @escaping (FIRDataSnapshot) -> Void) {
        queryUserRef.child(uid).observe(.value, with: { (snapshot) -> Void in
            if !snapshot.exists() { return }
            completion(snapshot)
        })
    }
    
    func queryFirebaseGroup(gid: String, completion: @escaping (FIRDataSnapshot) -> Void) {
        queryGroupRef.child(gid).observe(.value, with: { (snapshot) -> Void in
            if !snapshot.exists() { return }
            completion(snapshot)
        })
    }
    
}






