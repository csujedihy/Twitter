//
//  User.swift
//  twitter-ios
//
//  Created by YiHuang on 2/15/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class User: NSObject {
    var userId: String?
    var name: String?
    var screenName: String?
    var profileImageUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary?
    var profileBackgroundImageUrl: NSURL?
    var followerCount: Int?
    var followingCount: Int?
    var following: Int?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        userId = dictionary["id_str"] as? String
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let url = dictionary["profile_image_url"] {
            profileImageUrl = NSURL(string: url as! String)

        }
        if let url = dictionary["profile_banner_url"] {
            profileBackgroundImageUrl = NSURL(string: url as! String)
        }
        
        tagline = dictionary["description"] as? String
        
        if let count = dictionary["followers_count"] {
            if let followerCount = count as? Int {
                self.followerCount = followerCount
            } else {
                self.followerCount = 0
            }
        
        }
        
        if let count = dictionary["friends_count"] {
            if let followingCount = count as? Int {
                self.followingCount = followingCount
            } else {
                self.followingCount = 0
            }
            
        }
        
        if let following = dictionary["following"] {

            if let followingStr = following as? Int {
                if followingStr == 1 {
                    self.following = 1
                } else {
                    self.following = 0
                }
            }
        }
    
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
