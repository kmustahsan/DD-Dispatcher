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
        let queue = ridesqueue.child(eventId);
        
        if queue.isEqual(nil) {
            let queueArr : NSArray = [];
            queue.setValue(queueArr.adding(rideId));
        } else {
            queue.observe(.value, with: { (snapshot) -> Void in
                let rideQueue = snapshot.children.allObjects as NSArray;
                queue.setValue(rideQueue.adding(rideId));
            })
        }
    }
    
    func addDriverRide(rideId: String, driverId: String) {
        // update driver to ride
        
        let driver = ["/rides/\(rideId)/driveId": driverId]
        rides.updateChildValues(driver)
    }
    
    func addDriverLocation(rideId: String, locValues: Dictionary<String, Any>) {
        let driverLoc = ["/rides/\(rideId)/driverLocation": locValues]
        rides.updateChildValues(driverLoc)
    }
    func getFirstRideQueue(eventId: String) -> NSObject {
        // get first in queue
        // My top posts by number of stars
        let rideQueue = (rides.child(eventId).queryOrderedByKey().queryLimited(toFirst: 1));
        return rideQueue;
    }
    
    func getLastRideNum(eventId: String) -> NSObject {
        // get last num in queue
        let rideQueue = (rides.child(eventId).queryOrderedByKey().queryLimited(toLast: 1));
        return rideQueue;
    }
    
    func getTotalRides(eventId: String) {
        // get TotalRides
    }
    
    func getRideQueue(eventId: String) -> NSObject {
        return getFirstRideQueue(eventId: eventId);
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
    
    func addDriverEvent(eventId: String, userId: String) {
        let drivers = rides.child(eventId).child("drivers");
        
        if drivers.isEqual(nil) {
            let queueArr : NSArray = [];
            drivers.setValue(queueArr.adding(userId));
        } else {
            drivers.observe(.value, with: { (snapshot) -> Void in
                for child in snapshot.children {
                    if (child as! String) != userId {
                        let driversArr = snapshot.children.allObjects as NSArray;
                        drivers.setValue(driversArr.adding(userId));
                    }
                }
            })
        }
    }
    
    func addUserEvent(eventId: String, userId: String) {
        // add user to an event
        // null or array
        let usersEvent = events.child(eventId);
        let users = usersEvent.value(forKey: "users");
        
        if users as! String == "null" {
            let usersArr: NSArray = [];
            
            let userAdded = ["/events/\(eventId)/users": usersArr.adding(userId)];
            events.updateChildValues(userAdded);
        } else {
            let newUsersArr = ["/events/\(eventId)/users": (users as! NSArray).adding(userId)];
            events.updateChildValues(newUsersArr);
        }
    }
    
    func getEvent(eventId: String) -> NSObject {
        return events.child(eventId);
    }
    
    func getGroup(groupId: String) -> NSObject {
        return groups.child(groupId);
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
}
