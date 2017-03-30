//
//  DataService.swift
//  DDDispatcher
//
//  Created by kmustahsan on 3/1/17.
//  Updated by lv23
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DataService {
    
    static let sharedInstance = DataService()
    private var _ref = FIRDatabase.database().reference()
    private var _users = FIRDatabase.database().reference().child("users")
    private var _groups = FIRDatabase.database().reference().child("groups")
    private var _groupUsers = FIRDatabase.database().reference().child("groups").child("users")
    
    // rides and queues
    private var _rides = FIRDatabase.database().reference().child("rides")
    private var _queues = FIRDatabase.database().reference().child("queues")
    
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
    
    // RIDES
    var rides: FIRDatabaseReference {
        return _rides
    }
    // QUEUES
    var queues: FIRDatabaseReference {
        return _queues
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, Any>) {
        users.child(uid).setValue(user)
    }
    
    func createFirebaseGroup(values: Dictionary<String, Any>) {
        groups.childByAutoId().setValue(values)
    }
    
    func queryFirebaseUserByUID(uid: String) {
        queryUserRef.child(uid).observe(.value, with: { (snapshot) -> Void in
            if !snapshot.exists() { return }
            print(snapshot)
        })
    }
    
    func queryFirebaseGroup(gid: String, completion: @escaping (Bool) -> Void) {
        queryGroupRef.child(gid).observe(.value, with: { (snapshot) -> Void in
            completion(snapshot.exists())
        })
    }
    
    // Assign a user to be a driver or not
    func userIsDriver(uid: String, value: Bool) {
        let user = ["/users/\(uid)/driver": value]
        ref.updateChildValues(user)
    }
    
    /*
     Rides are created when a driver accepts a rider.
     
     rides {
        ride.id {
            driver: uid,
            group: uid,
            rider: uid,
            status: "onhold"/"started"/"picked"/"dropped"/"cancelled",
            location: { x: integer, y: integer }
        }
     }
    */
    func createRide(values: Dictionary<String, Any>) {
        let riderId = values["rider"] as! String
        
        let rideRef = rides.childByAutoId()
        rideRef.setValue(values) { (err, ref) -> Void in
            if ((err) != nil) {
                print("ERROR")
            }
            
            let rideKey = rideRef.key
            self.users.child(riderId).setValue(["ride": rideKey])
        }
    }
    
    /*
     A queue starts when the first rider in group requests a ride. 
     After the first rider, we just update the specific
     queue with a new rider (user.id : true)
     
     queues {
        group.id {
            user.id : true/false
        }
     }
     
     True or False depends on user's car request is active or not
    */
    func createQueue(gid: String, values: Dictionary<String, Any>) {
        queues.child(gid).setValue(values)
    }
    
    /*
        RideEvents: ["onhold", "started", "picked", "dropped", "cancelled"]
            - "onhold" and "started" can go straight to "cancelled"
            - Once on "picked" or "dropped" you can't cancel
    */
    func updateRide(uid: String, rideEvent: String) {
        let rideId = users.child(uid).value(forKey: "ride")
        rides.child("/\(rideId)/status").setValue(rideEvent)
    }
    
    /*
     - Update the status of the rider in a queue
     - Rider is only True when rider requests a ride on RideEvent ("onhold")
     any other event is False
     */
    func updateRider(gid: String, uid: String, value: Bool) {
        let riderUpdate = ["/queues/\(gid)/\(uid)/": value]
        ref.updateChildValues(riderUpdate)
    }
    
    func getRider(gid: String) {
        queues.child(gid).observe(.value, with: { (snapshot) -> Void in
            for child in snapshot.children {
                // need to work this I want to get the whole list of a queue
                
                // first child's value with true value then return
                // else just continue until you find a first True value for a child.key of userId
                print(child)
                
                // once found then we want to turn the value of the rider to FALSE
                // and then we create a Ride (create ride logic should be in the controller (business logic)
                // thus we just update the queue here and return
            }
        })
    }
}






