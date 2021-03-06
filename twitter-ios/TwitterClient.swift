//
//  TwitterClient.swift
//  twitter-ios
//
//  Created by YiHuang on 2/15/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "TbpAKfDkpjXUSUCa19hi5wo8i"
let twitterConsumerSecret = "bZTsOPglAQb6w6dl5YpBX59vNBhHwas4CxPMiiRlOTX6oTQ2bX"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    static var userDidLogoutNotification = "UserDidLogout"
    static var userDidPostTweet = "UserDidPostTweet"
    static var tweetMaxLength = 140
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func unretweet(tweetid: String, completion: (error: NSError?)->()) {
        TwitterClient.sharedInstance.POST("1.1/statuses/unretweet/\(tweetid).json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            completion(error: nil)
            
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                
            completion(error: error)
                
        })
    }
    
    func newTweet(content: String, replyId: String?, completion: ((error: NSError?)->())?) {
        var parameters = [String : AnyObject]()
        if let replyId = replyId {
            parameters["in_reply_to_status_id"] = replyId
        }
        
        
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json?status=\(content)", parameters: parameters, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
//            print("New Tweet Posted!")
            completion?(error: nil)
            
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                
//            print("Failed to post New Tweet!")
            completion?(error: error)
                
        })
    
    }
    
    
    func retweet(tweetid: String, completion: (error: NSError?)->()) {
        TwitterClient.sharedInstance.POST("1.1/statuses/retweet/\(tweetid).json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
//                print("Retweeted!")
                completion(error: nil)
            
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                
//                print("Retweet failed")
                completion(error: error)
                
        })
    }
    
    func unlike(tweetid: String, completion: (error: NSError?)->()) {
        TwitterClient.sharedInstance.POST("1.1/favorites/destroy.json?id=\(tweetid)", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            print("Un-Liked!")
            completion(error: nil)
            
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                
                print("Un-Liked failed")
                completion(error: error)
                
        })
    }
    
    func like(tweetid: String, completion: (error: NSError?)->()) {
        TwitterClient.sharedInstance.POST("1.1/favorites/create.json?id=\(tweetid)", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            print("Liked!")
            completion(error: nil)
            
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
            
           print("Liked failed")
           completion(error: error)
                
        })
    }
    
    func follow(userId: String, completion: (error: NSError?)->()) {
        var parameters = [String : AnyObject]()
        parameters["user_id"] = String(userId)

        TwitterClient.sharedInstance.POST("1.1/friendships/create.json", parameters: parameters, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            print("Followed!")
            completion(error: nil)
            
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                
            print("Failed in following!")
            completion(error: error)
                
        })
    
    }
    
    func unfollow(userId: String, completion: (error: NSError?)->()) {
        var parameters = [String : AnyObject]()
        parameters["user_id"] = String(userId)
        TwitterClient.sharedInstance.POST("1.1/friendships/destroy.json", parameters: parameters, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            print("Unfollowed!")
            completion(error: nil)
            
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                
                print("Failed in unfollowing!")
                completion(error: error)
                
        })
        
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (credential: BDBOAuth1Credential!) -> Void in
            print("Got the request token \(credential.token)")
            
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(credential.token)")
            
            UIApplication.sharedApplication().openURL(authURL!)
            
            }) { (error: NSError!) -> Void in
                print("Failed to get request token")
        }
    
    }

    func logout() {
        User.currentUser = nil
        deauthorize()
        NSNotificationCenter.defaultCenter().postNotificationName(TwitterClient.userDidLogoutNotification, object: nil)
    
    }
    
    func userHomeTimeline(userId: String?, count: Int?, olderThan: String?, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        var parameters = [String : AnyObject]()
        if let userId = userId {
            parameters["user_id"] = String(userId)
        }
        
        if let count = count {
            parameters["count"] = String(count)
        }
        
        if let olderThan = olderThan {
            parameters["max_id"] = olderThan
        }
        
        TwitterClient.sharedInstance.GET("1.1/statuses/user_timeline.json", parameters: parameters, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            success(tweets)
            
            
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
                
        })
        
        
    }
    
    func homeTimeline(count: Int?, olderThan: String?, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        var parameters = [String : AnyObject]()
        if let count = count {
            parameters["count"] = String(count)
        }
        
        if let olderThan = olderThan {
            parameters["max_id"] = olderThan
        }
        
        TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: parameters, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            success(tweets)


            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
                
        })
    
    
    }
    
    
    func currentAccount(callback: (user: User?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //                print("user:\(response)")
            let user = User(dictionary: response as! NSDictionary)
            User.currentUser = user
            callback(user: user, error: nil)
            
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
            callback(user: nil, error: error)
                
        })
    
    
    }
    
    
    func openURL(url: NSURL) {
        TwitterClient.sharedInstance.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            self.currentAccount({ (user, error) -> () in
                if let user = user {
                    self.loginCompletion?(user: user, error: nil)
                } else {
                    self.loginCompletion?(user: nil, error: error)
                }
                
            })
            
            
            }) { (error: NSError!) -> Void in
                print("Failed to receive access Token")
        }

    
    
    }
}
