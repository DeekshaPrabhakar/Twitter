//
//  User.swift
//  Twitter
//
//  Created by Deeksha Prabhakar on 10/26/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name:String?
    var screenname:String?
    var profileUrl:URL?
    var profileUrlString:String?
    var tagline: String?
    var location: String?
    var dictionary:NSDictionary?
    var backgroundImageUrl:URL?
    var bannerImageUrl:URL?
    var followersCount = 0
    var followingCount = 0
    var userID:Int64!
    
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        tagline = dictionary["description"] as? String
        location = dictionary["location"] as? String
        let uID = dictionary["id"]!
        userID = (uID as! NSNumber).int64Value
        
        let profileUrlStr = dictionary["profile_image_url"] as? String
        if let profileUrlStr = profileUrlStr {
            profileUrlString = profileUrlStr.replacingOccurrences(of: "normal", with: "200x200")
            profileUrl = URL(string: profileUrlString!)
        }
        
        let backgroundImageUrlString = dictionary["profile_background_image_url"] as? String
        if let backgroundImageUrlString = backgroundImageUrlString {
            backgroundImageUrl = URL(string: backgroundImageUrlString)
        }
        
        let bannerImageUrlString = dictionary["profile_banner_url"] as? String
        if let bannerImageUrlString = bannerImageUrlString {
            bannerImageUrl = URL(string: bannerImageUrlString)
        }
        
        followersCount = (dictionary["followers_count"] as? Int) ?? 0
        followingCount = (dictionary["friends_count"] as? Int) ?? 0
        
    }
    
    static let userDidLogoutNotification = "UserDidLogout"
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if(_currentUser == nil){
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? NSData
                
                if let userData = userData{
                    do{
                        if let dataDictionary = try? JSONSerialization.jsonObject(with: userData as Data, options: []) as?NSDictionary{
                            _currentUser = User(dictionary: dataDictionary!)
                        }
                    }
                    catch let error as NSError{
                        print(error)
                    }
                }
            }
            return _currentUser
        }
        set(user){
            User.setCurrentUser(user: user)
           /* _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            }
            else{
                defaults.set(nil, forKey: "currentUserData")
            }
            
            defaults.synchronize()
            */
        }
    }
    
    class func setCurrentUser(user: User?) {
        
        let defaults = UserDefaults.standard
        
         if let user = user {
            
            let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
            defaults.set(data, forKey: "currentUserData")
            
            
            // add to list of users if it doesn't already exist
            let accountData = defaults.object(forKey: "accountData") as? NSData
            var accountDictionary = NSMutableDictionary.init()
            if let accountData = accountData{
                do{
                    if let dataDictionary = try? JSONSerialization.jsonObject(with: accountData as Data, options: []) as? NSDictionary{
                        
                        accountDictionary = dataDictionary?.mutableCopy() as! NSMutableDictionary
                    }
                }
                catch let error as NSError{
                    print(error)
                }
            }
            accountDictionary.setValue(user.dictionary, forKey: (user.screenname)!)
            
          
            let newAccountData = try! JSONSerialization.data(withJSONObject: accountDictionary, options: [])
            defaults.set(newAccountData, forKey: "accountData")
        }
        else{
            removeUser(user: _currentUser!)
        }
        _currentUser = user;
        
        defaults.synchronize()
    }
    
    class func removeUser(user:User){
        let defaults = UserDefaults.standard
        
        defaults.set(nil, forKey: "currentUserData")
        let accountData = defaults.object(forKey: "accountData") as? NSData
        var accountDictionary = NSMutableDictionary.init()
        if let accountData = accountData{
            do{
                if let dataDictionary = try? JSONSerialization.jsonObject(with: accountData as Data, options: []) as? NSDictionary{
                   
                    accountDictionary = dataDictionary?.mutableCopy() as! NSMutableDictionary
                }
            }
            catch let error as NSError{
                print(error)
            }
        }
        
        accountDictionary.setValue(nil, forKey: user.screenname!)
        let newAccountData = try! JSONSerialization.data(withJSONObject: accountDictionary, options: [])
        defaults.set(newAccountData, forKey: "accountData")
        defaults.synchronize()
    }
    
    class func accounts() -> NSArray {
        let storedAccounts =  User.getStoredAccounts()
        var useraccounts = NSMutableArray()
        let accountsRaw = storedAccounts.allValues
        
        for rawAccnt in accountsRaw{
            useraccounts.add(User(dictionary: rawAccnt as! NSDictionary))
        }
        return useraccounts;
    }
    
    func addToStoredAccounts(){
        
    }
    
    class func getStoredAccounts() -> NSDictionary {
        let defaults = UserDefaults.standard
        var data:NSDictionary = NSDictionary.init()
        
        let accountData = defaults.object(forKey: "accountData") as? NSData
        
        if let accountData = accountData{
            do{
                if let dataDictionary = try? JSONSerialization.jsonObject(with: accountData as Data, options: []) as? NSDictionary{
                    data = dataDictionary!
                }
            }
            catch let error as NSError{
                print(error)
            }
        }
        return data;
    }
    
}
