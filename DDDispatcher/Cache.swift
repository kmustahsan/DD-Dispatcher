//
//  cache.swift
//  DDDispatcher
//
//
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import Foundation
import Firebase

class cache {
    //plist
    var path = Bundle.main.path(forResource: "cache", ofType: "plist")
    //holds root pList
    //key : user -> Dictionary of user props, listed in design doc
    //key : groups -> Dictionary holds group(s) information for user
    var initDict : [String : Any?]?
    
    
    
    //singletion class usage: cache.sharedCache
    static let sharedCache = cache()
    private init(){
        //private init doesnt allow anyone to init the class in any other space
        //open plist file and read
        let fileMan = FileManager.default
        if fileMan.fileExists(atPath: path!)
        {
            self.initDict = NSDictionary(contentsOfFile: path!) as? [String : Any?]
        }
        else
        {
            self.initDict = nil
        }
        //setting up the caching for active listening
        var ref: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference()
        let groupRef = ref.child("groups")
        groupRef.observe(.childAdded, with: { (snapshotD) in
            let snapshot = snapshotD.value as? NSDictionary
            let admin = snapshot!["admin"] as! String
            let description = snapshot!["description"] as! String
            let name = snapshot!["name"] as! String
            let users = snapshot!["users"] as! [String]
            
            let groupDict = ["admin": admin, "description": description, "name": name, "users": users] as [String : Any]
            var masterDict = self.getGroupsInfo();
            masterDict[snapshotD.key] = groupDict
            self.writeDictionaryCache(name: "groups", dict: masterDict)
        })
        
        
    }
    
    func getUserInfo()->Dictionary<String, Any?>{
        let fileMan = FileManager.default
        var initDictLocal : [String: Any?]?
        if fileMan.fileExists(atPath: path!)
        {
            initDictLocal = NSDictionary(contentsOfFile: path!) as? [String : Any?]
        }
        else
        {
            initDictLocal = nil
        }
        let user : Dictionary<String, Any?> = initDictLocal!["user"] as! Dictionary<String, Any?>
        
        return user
        
    }
    
    func getGroupsInfo()->Dictionary<String, Any?>{
        let fileMan = FileManager.default
        var initDictLocal : [String: Any?]?
        if fileMan.fileExists(atPath: path!)
        {
            initDictLocal = NSDictionary(contentsOfFile: path!) as? [String : Any?]
        }
        else
        {
            initDictLocal = nil
        }
        let groups : Dictionary<String, Any?> = initDictLocal!["groups"] as! Dictionary<String, Any?>
        
        return groups
    }
    
    
    /// getGroupbyname
    ///
    /// - Parameter id: group id
    /// - Returns: optional dictornary of group ["admin": admin, "description": description, "name": name, "users": users]
    
    func getGroupByName(id : String) ->Dictionary<String, Any?>?
    {
        let dict = getGroupsInfo();
        return dict[id] as! Dictionary<String, Any?>?
    }
    
    
    //["-KgzYCrI3YQiP9zxMOic": Optional(["description": "Yellow testing", "name": "need", "users": ["WcrSNIP7N5cy4U4Pwh8L5rxSU9i2"], "admin": "WcrSNIP7N5cy4U4Pwh8L5rxSU9i2"])]
    
    
    func writeDictionaryCache(name : String, dict : Dictionary<String, Any?>){
        if(initDict == nil)
        {
            //throw error or console log
            print("error with cache file, writing")
            return
        }
        print("user dict", dict)
        switch name {
        case "user":
            initDict!["user"] = dict
        case "groups":
            initDict!["groups"] = dict
        default:
            return
        }
        
        //write to plist
        let fileMan = FileManager.default
        if fileMan.fileExists(atPath: path!)
        {
            let writeDict = initDict! as NSDictionary
            writeDict.write(toFile: path!, atomically: false)
            print("wrote to cache")
        }
        
    }
    
    
}
