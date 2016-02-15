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
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
}
