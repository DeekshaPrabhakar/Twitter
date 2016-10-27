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
    var tagline: String?
    var dictionary:NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        tagline = dictionary["description"] as? String
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        }
    }
    
    static let userDidLogoutNotification = "UserDidLogout"
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if(_currentUser == nil){
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? NSData
                
                if let userData = userData{
                    let dataDictionary = try! JSONSerialization.jsonObject(with: userData as Data, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dataDictionary)
                }
            }
            return _currentUser
        }
        set(user){
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            }
            else{
                defaults.set(nil, forKey: "currentUserData")
            }
            
            defaults.synchronize()
            
        }
    }
    
}
