//
//  TweetsViewController.swift
//  twitter-ios
//
//  Created by YiHuang on 2/20/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tweets = [Tweet]()
    var refreshControl: UIRefreshControl?
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func logoutOnTap(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
        
    }
    
    

    @IBAction func retweetOnTap(sender: AnyObject) {
        let button = sender as! UIButton
        let index = button.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetCellTableViewCell
        
        if let tweetId = cell.tweet?.tweetId {
            if cell.tweet!.retweeted == false {
                TwitterClient.sharedInstance.retweet(tweetId) {
                    (error: NSError?) -> () in
                    if error == nil {
                        cell.addOneToRetweetNum()
                    }
                }
            } else {
                TwitterClient.sharedInstance.unretweet(tweetId) {
                    (error: NSError?) -> () in
                    if error == nil {
                        cell.minusOneToRetweetNum()
                    }
                }
            
            
            }

        }

    }
    
    
    @IBAction func likeOnTap(sender: AnyObject) {
        let button = sender as! UIButton
        let index = button.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetCellTableViewCell
        
        if let tweetId = cell.tweet?.tweetId {
            if cell.tweet!.liked == false {
                TwitterClient.sharedInstance.like(tweetId) {
                    (error: NSError?) -> () in
                    if error == nil {
                        cell.addOneToLikeNum()
                    }
                }
            } else {
                TwitterClient.sharedInstance.unlike(tweetId) {
                    (error: NSError?) -> () in
                    if error == nil {
                        cell.minusOneToLikeNum()
                    }
                }
            }

        }
        
    }
    
    func fetchTweets() {
        TwitterClient.sharedInstance.homeTimeline({ (tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            }) { (error: NSError) -> () in
                print(error.localizedDescription)
                
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl!, atIndex: 0)
        fetchTweets()
        
        NSNotificationCenter.defaultCenter().addObserverForName(TwitterClient.userDidPostTweet, object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) -> Void in
            self.fetchTweets()
            self.tableView.reloadData()
        }

        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchTweets()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCellTableViewCell", forIndexPath: indexPath) as! TweetCellTableViewCell
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet
        if let user = tweet.user {
            cell.userProfileImageVIew.setImageWithURL(user.profileImageUrl!)

            
            cell.userNameLabel.text = "@\(user.screenName!)"
            cell.screenNameLabel.text = "\(user.name!)"
        }
        
        cell.retweetButton.tag = indexPath.row
        cell.likeButton.tag = indexPath.row
        
        
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
                print("text \(cell.tweetTextLabel?.text) set retweet grey image false")

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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
