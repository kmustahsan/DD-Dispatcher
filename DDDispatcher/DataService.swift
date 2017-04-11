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
    private var _ridesqueue = FIRDatabase.database().reference().child("ridesqueue")
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
    
    // RIDES
    var rides: FIRDatabaseReference {
        return _rides
    }
    // QUEUES
    var ridesqueue: FIRDatabaseReference {
        return _ridesqueue
    }
    
    // EVENTS
    var events: FIRDatabaseReference {
        return _events
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
     Rides are created when user requests a ride.
     
     rides {
        ride.id {
            driver: "null",
            driver_location: "null",
            rider: uid,
            status: "onhold"/"ongoing"/dropped"/"cancelled",
            location: { 
                start: { x: integer, y: integer },
                end: { x: integer, y: integer }
        }
     }
    */
    func createRide(eventId: String, values: Dictionary<String, Any>) {
        // Create ride id
        let rideId = rides.childByAutoId()
        rideId.setValue(values)
        
        // Update user's ride id
        users.child(values["rider"] as! String).setValue(rideId.key)
        pushRideQueue(eventId: eventId, rideId: values["rider"] as! String);
    }
    
    /*
        event.id {
            N: ride.id
        }
    */
    func pushRideQueue(eventId: String, rideId: String) {
        let num = 0 as Int;
        ridesqueue.child(eventId).child(String(num)).setValue(rideId);
    }
    
    func addDriverRide(rideId: String, driverId: String) {
        // update driver to ride
        
        let driver = ["/rides/\(rideId)/driveId": driverId]
        rides.updateChildValues(driver)
    }
    
    func getFirstRide(eventId: String) {
        // get first in queue
    }
    
    func getLastRideNum(eventId: String) {
        // get last num in queue
    }
    
    func getTotalRides(eventId: String) {
        // get TotalRides
    }
    
    func getRideQueue(rideId: String) {
        ridesqueue.child(rideId).observe(.value, with: { (snapshot) -> Void in
            print(snapshot)
        });
    }
    
    /*
        event.id {
            description: string,
            group.id: string,
            name: string,
            drivers: "null" | users,
            location: { x: integer, y: integer },
            users: "null" | users,
            start_time: integer,
            end_time: integer
        }
    */
    func createEvent(values: Dictionary<String, Any>) {
        events.childByAutoId().setValue(values);
    }
    
    func addDriverEvent(eventId: String, driverId: String) {
        // add a driver to an event
        var eventDrivers: NSDictionary? = nil;
        
        events.child(eventId).observe(.value, with: { (snapshot) -> Void in
            eventDrivers = snapshot.children.value(forKey: "drivers") as? NSDictionary
        });
        
        print(eventDrivers as Any);
        // Convert it to array to add a new driver
        // var driverArr = eventDrivers.
    }
    
    func addUserEvent(eventId: String, userId: String) {
        // add user to an event
    }
    
    func getEvent(eventId: String) {
            // get event
        events.child(eventId).observe(.value, with: { (snapshot) -> Void in
            print(snapshot)
        });
    }
    
    func getGroup(groupId: String) {
        // get group
        events.child(groupId).observe(.value, with: { (snapshot) -> Void in
            print(snapshot)
        });
    }
    
    /*
        RideEvents: ["onhold", "started", "picked", "dropped", "cancelled"]
            - "onhold" and "started" can go straight to "cancelled"
            - Once on "picked" or "dropped" you can't cancel
    */
    func updateRide(uid: String, rideEvent: String) {
        let rideId = users.child(uid).value(forKey: "ride") as! String
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
}
