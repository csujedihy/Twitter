//
//  DetailViewController.swift
//  twitter-ios
//
//  Created by Yi Huang on 16/2/27.
//  Copyright © 2016年 c2fun. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var detailTweet: Tweet?
    @IBOutlet weak var tableView: UITableView!
    var tweets = [Tweet]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "DetailTweetCell", bundle: nil), forCellReuseIdentifier: "DetailTweetCell")
        tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func retweetOnTap(sender: AnyObject) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTweetCell
        
        if let tweetId = cell.tweet?.tweetId {
            if cell.tweet!.retweeted == false {
                TwitterClient.sharedInstance.retweet(tweetId) {
                    (error: NSError?) -> () in
                    if error == nil {
                        let imageRetweeted = UIImage(named: "retweet-green")
                        cell.retweetButton.setImage(imageRetweeted, forState: .Normal)
                    }
                }
            } else {
                TwitterClient.sharedInstance.unretweet(tweetId) {
                    (error: NSError?) -> () in
                    if error == nil {
                        let imageRetweeted = UIImage(named: "retweet-action")
                        cell.retweetButton.setImage(imageRetweeted, forState: .Normal)
                    }
                }
                
                
            }
            
        }
        
    }
    
    
    func likeOnTap(sender: AnyObject) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailTweetCell
        if let tweetId = cell.tweet?.tweetId {
            if cell.tweet!.liked == false {
                TwitterClient.sharedInstance.like(tweetId) {
                    (error: NSError?) -> () in
                    if error == nil {
                        let imageLiked = UIImage(named: "like-action-red")
                        cell.likeButton.setImage(imageLiked, forState: .Normal)
                    }
                }
            } else {
                TwitterClient.sharedInstance.unlike(tweetId) {
                    (error: NSError?) -> () in
                    if error == nil {
                        let imageLiked = UIImage(named: "like-action")
                        cell.likeButton.setImage(imageLiked, forState: .Normal)
                    }
                }
            }
            
        }
        
    }
    
    
    func profileTap (sender: AnyObject) {
        performSegueWithIdentifier("profileSegueFromDetail", sender: nil)
        
    }
    
    func replyOnTap(sender: AnyObject) {
        performSegueWithIdentifier("newPostSegueFromDetail", sender: detailTweet)
        
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailTweetCell", forIndexPath: indexPath) as! DetailTweetCell
            cell.selectionStyle = .None
            if let user = detailTweet?.user {
                cell.userProfileImageView.setImageWithURL(user.profileImageUrl!)
                
                
                cell.nameLabel.text = "\(user.name!)"
                cell.screenNameLabel.text = "@\(user.screenName!)"
            }
            cell.createdAtLabel.text = detailTweet?.createAtString
            cell.tweet = detailTweet
            if cell.userProfileImageView.userInteractionEnabled == false {
                cell.userProfileImageView.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: "profileTap:")
                cell.userProfileImageView.addGestureRecognizer(tapGesture)
            }
            
            cell.replyButton.removeTarget(self, action: nil, forControlEvents: .AllEvents)
            cell.replyButton.addTarget(self, action: "replyOnTap:", forControlEvents: .TouchUpInside)
            cell.retweetButton.removeTarget(self, action: nil, forControlEvents: .AllEvents)
            cell.retweetButton.addTarget(self, action: "retweetOnTap:", forControlEvents: .TouchUpInside)
            cell.likeButton.removeTarget(self, action: nil, forControlEvents: .AllEvents)
            cell.likeButton.addTarget(self, action: "likeOnTap:", forControlEvents: .TouchUpInside)
            
            if let liked = cell.tweet?.liked {
                if liked == true {
                    let imageLiked = UIImage(named: "like-action-red")
                    cell.likeButton.setImage(imageLiked, forState: .Normal)
                } else {
                    let imageLiked = UIImage(named: "like-action")
                    cell.likeButton.setImage(imageLiked, forState: .Normal)
                }
            }
            
            if let retweeted = cell.tweet?.retweeted {
                if retweeted == true {
                    let imageRetweeted = UIImage(named: "retweet-green")
                    cell.retweetButton.setImage(imageRetweeted, forState: .Normal)
                } else {
                    // retweet-action
                    
                    let imageRetweeted = UIImage(named: "retweet-action")
                    cell.retweetButton.setImage(imageRetweeted, forState: .Normal)
                    //                print("text \(cell.tweetTextLabel?.text) set retweet grey image false")
                    
                }
            }
            
            
            
            cell.tweetTextLabel.text = detailTweet?.text
            if let likeNum = detailTweet?.likeNumber {
                cell.likeNumberLabel.text = String(likeNum)
            }
            
            if let retNum = detailTweet?.retweetNumber {
                cell.retweetNumberLabel.text = String(retNum)
                
            }
            return cell

        
        } else {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
            
            
            let tweet = tweets[indexPath.row]
            cell.tweet = tweet
            
            if cell.userProfileImageVIew.userInteractionEnabled == false {
                cell.userProfileImageVIew.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: "profileTap:")
                cell.userProfileImageVIew.addGestureRecognizer(tapGesture)
            }
            
            if let user = tweet.user {
                cell.userProfileImageVIew.setImageWithURL(user.profileImageUrl!)
                
                
                cell.userNameLabel.text = "@\(user.screenName!)"
                cell.screenNameLabel.text = "\(user.name!)"
            }
            
            cell.retweetButton.tag = indexPath.row
            cell.likeButton.tag = indexPath.row
            
            //MARK: programmatically set button's action
            
            cell.retweetButton.removeTarget(self, action: nil, forControlEvents: .AllEvents)
            cell.retweetButton.addTarget(self, action: "retweetOnTap:", forControlEvents: .TouchUpInside)
            cell.likeButton.removeTarget(self, action: nil, forControlEvents: .AllEvents)
            cell.likeButton.addTarget(self, action: "likeOnTap:", forControlEvents: .TouchUpInside)
            
            
            cell.userProfileImageVIew.tag = indexPath.row
            
            if let liked = cell.tweet?.liked {
                if liked == true {
                    let imageLiked = UIImage(named: "like-action-red")
                    cell.likeButton.setImage(imageLiked, forState: .Normal)
                } else {
                    let imageLiked = UIImage(named: "like-action")
                    cell.likeButton.setImage(imageLiked, forState: .Normal)
                }
            }
            
            if let retweeted = cell.tweet?.retweeted {
                if retweeted == true {
                    let imageRetweeted = UIImage(named: "retweet-green")
                    cell.retweetButton.setImage(imageRetweeted, forState: .Normal)
                } else {
                    // retweet-action
                    
                    let imageRetweeted = UIImage(named: "retweet-action")
                    cell.retweetButton.setImage(imageRetweeted, forState: .Normal)
                    //                print("text \(cell.tweetTextLabel?.text) set retweet grey image false")
                    
                }
            }
            
            // see if it's a replied msg
            if let inReplyTo = tweet.inReplyTo {
                let imageRetweet = UIImage(named: "reply-action")
                cell.retweetedButton.setImage(imageRetweet, forState: .Normal)
                cell.retweetedUserLabel.text = "In reply to \(inReplyTo)"
                cell.retweetedUserLabelHeight.constant = 16
                cell.retweetedIconHeight.constant = 15
            } else if let retweetedUser = tweet.whoRetweet {
                let imageRetweet = UIImage(named: "retweet-green")
                cell.retweetedButton.setImage(imageRetweet, forState: .Normal)
                cell.retweetedUserLabel.text = "\(retweetedUser.name!) Retweeted"
                cell.retweetedUserLabelHeight.constant = 16
                cell.retweetedIconHeight.constant = 15
            } else {
                cell.retweetedUserLabelHeight.constant = 0
                cell.retweetedIconHeight.constant = 0
                
            }
            
            // see if it's retweeted msg
            
            cell.tweetTextLabel.text = tweet.text
            if let likeNum = tweet.likeNumber {
                cell.likedNumberLabel.text = String(likeNum)
            }
            
            if let retNum = tweet.retweetNumber {
                cell.retweetedNumberLabel.text = String(retNum)
                
            }

            return cell

        }
        
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "profileSegueFromDetail" {
            let destVC = segue.destinationViewController as! ProfileViewController
            destVC.user = detailTweet?.user
            
        } else if segue.identifier == "newPostSegueFromDetail" {
            let destVC = segue.destinationViewController as! NewPostViewController
            destVC.inReplyToId = detailTweet?.tweetId
            destVC.tweet = detailTweet
        }
    }


}
