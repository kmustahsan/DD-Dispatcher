//
//  cache.swift
//  DDDispatcher
//
//
//  Copyright © 2017 DD Dispatcher. All rights reserved.
//

import Foundation
import Firebase

let plistFileName:String = "Cache"

struct Plist {
    
    enum PlistError: Error {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name:String
    
    var sourcePath:String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return .none }
        return path
    }
    
    var destPath:String? {
        guard sourcePath != .none else { return .none }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {
        
        self.name = name
        
        let fileManager = FileManager.default
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExists(atPath: source) else { return nil }
        
        if !fileManager.fileExists(atPath: destination) {
            
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                print("[Cache] Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func addValuesToPlistFile(dictionary:NSDictionary) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !dictionary.write(toFile: destPath!, atomically: false) {
                print("[Cache] File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
}

class Cache {
    static let sharedInstance = Cache()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    func startCache() {
        if let _ = Plist(name: plistFileName) {
            print("[Cache] Cache started")
        }
    }
    
    func addNewItemWithKey(key:String, value:AnyObject) {
        print("[Cache] Starting to add item for key '\(key), with value '\(value)' . . .")
        if !keyAlreadyExists(key: key) {
            if let plist = Plist(name: plistFileName) {
                
                let dict = plist.getMutablePlistFile()!
                dict[key] = value
                
                do {
                    try plist.addValuesToPlistFile(dictionary: dict)
                } catch {
                    print(error)
                }
                print("[Cache] An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
                print("[Cache] \(plist.getValuesInPlistFile())")
            } else {
                print("[Cache] Unable to get Plist")
            }
        } else {
            print("[Cache] Item for key '\(key)' already exists. Not saving Item. Not overwriting value.")
        }
        
        
    }
    
    func removeItemForKey(key:String) {
        print("[Cache] Starting to remove item for key '\(key) . . .")
        if keyAlreadyExists(key: key) {
            if let plist = Plist(name: plistFileName) {
                
                let dict = plist.getMutablePlistFile()!
                dict.removeObject(forKey: key)
                
                do {
                    try plist.addValuesToPlistFile(dictionary: dict)
                } catch {
                    print(error)
                }
                print("[Cache] An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
                print("[Cache] \(plist.getValuesInPlistFile())")
            } else {
                print("[Cache] Unable to get Plist")
            }
        } else {
            print("[Cache] Item for key '\(key)' does not exists. Remove canceled.")
        }
        
    }
    
    func removeAllItemsFromPlist() {
        
        if let plist = Plist(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            let keys = Array(dict.allKeys)
            
            if keys.count != 0 {
                dict.removeAllObjects()
            } else {
                print("[Cache] Plist is already empty. Removal of all items canceled.")
            }
            
            do {
                try plist.addValuesToPlistFile(dictionary: dict)
            } catch {
                print(error)
            }
            print("[Cache] An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
            print("[Cache] \(plist.getValuesInPlistFile())")
        } else {
            print("[Cache] Unable to get Plist")
        }
    }
    
    func saveValue(value:AnyObject, forKey:String) {
        
        if let plist = Plist(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            if let dictValue = dict[forKey] {
                
                if type(of: value) != type(of: dictValue) {
                    print("[Cache] WARNING: You are saving a \(type(of: value)) typed value into a \(type(of: dictValue)) typed value. Best practice is to save Int values to Int fields, String values to String fields etc. (For example: '_NSContiguousString' to '__NSCFString' is ok too; they are both String types) If you believe that this mismatch in the types of the values is ok and will not break your code than disregard this message.")
                }
                
                dict[forKey] = value
                
            }
            
            do {
                try plist.addValuesToPlistFile(dictionary: dict)
            } catch {
                print(error)
            }
            print("[Cache] An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
            print("[Cache] \(plist.getValuesInPlistFile())")
        } else {
            print("[Cache] Unable to get Plist")
        }
    }
    
    func getValueForKey(key:String) -> AnyObject? {
        var value:AnyObject?
        
        
        if let plist = Plist(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            let keys = Array(dict.allKeys)
            //print("[Cache] Keys are: \(keys)")
            
            if keys.count != 0 {
                
                for (_,element) in keys.enumerated() {
                    //print("[Cache] Key Index - \(index) = \(element)")
                    if element as! String == key {
                        print("[Cache] Found the Item that we were looking for for key: [\(key)]")
                        value = dict[key]! as AnyObject
                    } else {
                        //print("[Cache] This is Item with key '\(element)' and not the Item that we are looking for with key: \(key)")
                    }
                }
                
                if value != nil {
                    //print("[Cache] The Element that we were looking for exists: [\(key)]: \(value)")
                    return value!
                } else {
                    print("[Cache] WARNING: The Item for key '\(key)' does not exist! Please, check your spelling.")
                    return .none
                }
                
            } else {
                print("[Cache] No Plist Item Found when searching for item with key: \(key). The Plist is Empty!")
                return .none
            }
            
        } else {
            print("[Cache] Unable to get Plist")
            return .none
        }
        
    }
    
    func keyAlreadyExists(key:String) -> Bool {
        var keyExists = false
        
        if let plist = Plist(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            let keys = Array(dict.allKeys)
            //print("[Cache] Keys are: \(keys)")
            
            if keys.count != 0 {
                
                for (_,element) in keys.enumerated() {
                    
                    //print("[Cache] Key Index - \(index) = \(element)")
                    if element as! String == key {
                        print("[Cache] Checked if item exists and found it for key: [\(key)]")
                        keyExists = true
                    } else {
                        //print("[Cache] This is Element with key '\(element)' and not the Element that we are looking for with Key: \(key)")
                    }
                }
                
            } else {
                //print("[Cache] No Plist Element Found with Key: \(key). The Plist is Empty!")
                keyExists =  false
            }
            
        } else {
            //print("[Cache] Unable to get Plist")
            keyExists = false
        }
        
        return keyExists
    }
    
}


