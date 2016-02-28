//
//  Tweet.swift
//  twitter-ios
//
//  Created by YiHuang on 2/15/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var tweetId: String?
    var user: User?
    var whoRetweet: User?
    var inReplyTo: String?
    var text: String?
    var createAtString: String?
    var createAt: NSDate?
    var likeNumber: Int?
    var replyNumber: Int?
    var retweetNumber: Int?
    var retweeted: Bool?
    var liked: Bool?
    
    
    init (dictionary: NSDictionary) {
        tweetId = dictionary["id_str"] as? String
        print(tweetId)
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        if (dictionary["favorited"] as! Int) == 0 {
            liked = false
        } else {
            liked = true
        }

        if (dictionary["retweeted"] as! Int) == 0 {
            retweeted = false
        } else {
            retweeted = true
        }

        if let retweeted = dictionary["retweeted_status"] {
            whoRetweet = User(dictionary: retweeted["user"] as! NSDictionary)
        }
        
        if let inReplyToScreenName = dictionary["in_reply_to_screen_name"]{
            if let screenName =  inReplyToScreenName as? String {
                inReplyTo = screenName
            }
        }
        
        
        text = dictionary["text"] as? String
        createAtString = dictionary["created_at"] as? String
//        print(dictionary)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createAt = formatter.dateFromString(createAtString!)
        
        if let favCnt = dictionary["favorite_count"] {
            likeNumber = favCnt as! Int
            print("liked num \(likeNumber)")
        } else {
            likeNumber = 0
        }
        if let retCnt = dictionary["retweet_count"] {
            retweetNumber = retCnt as! Int
        } else {
            retweetNumber = 0
        }

    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }

}
