//
//  cache.swift
//  DDDispatcher
//
//
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import Foundation

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
    }
    
    func getUserInfo()->Dictionary<String, Any?>{
        let user : Dictionary<String, Any?> = initDict!["user"] as! Dictionary<String, Any?>
        
        return user
        
    }
    
    func getGroupsInfo()->Dictionary<String, Any?>{
        let groups : Dictionary<String, Any?> = initDict!["groups"] as! Dictionary<String, Any?>
        
        return groups
    }
    
    //Use firebase call to get groups ID's / data then store in a dictionary and write to cache
    private func retriveGroupInfo()
    {
        
    }
    
    //use firebase call to retrive user info and write to cache
    private func retriveUserInfo()
    {
        
    }
    
    
    private func writeDictionaryCache(name : String, dict : Dictionary<String, Any?>){
        if(initDict == nil)
        {
            //throw error or console log
            return
        }
        
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
        }
        
    }
    
    
}
