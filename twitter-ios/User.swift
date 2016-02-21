//
//  User.swift
//  twitter-ios
//
//  Created by YiHuang on 2/15/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileImageUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let url = dictionary["profile_image_url"] {
            profileImageUrl = NSURL(string: url as! String)

        }
        tagline = dictionary["descripption"] as? String
    
    }
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
        
            if _currentUser == nil {
            
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUserData") as? NSData
                
                
                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                
                }
                
            }
        
            return _currentUser

        }
        
        set(user) {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(data, forKey: "currentUserData")
            } else {
                defaults.setObject(nil, forKey: "currentUserData")
            }
            defaults.synchronize()
            
        }
    
    }
    
    
} 
