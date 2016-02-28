//
//  ViewController.swift
//  twitter-ios
//
//  Created by YiHuang on 2/15/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    @IBAction func loginOnTap(sender: AnyObject) {
        let client = TwitterClient.sharedInstance
        client.loginWithCompletion { (user: User?, error: NSError?) -> () in
            
            // do something
            
            
            if let user = user {
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            
            } else {
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

