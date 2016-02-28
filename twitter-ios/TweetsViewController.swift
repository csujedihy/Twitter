//
//  TweetsViewController.swift
//  twitter-ios
//
//  Created by YiHuang on 2/20/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    var tweets = [Tweet]()
    var pageOffset: String?
    var refreshControl: UIRefreshControl?
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func logoutOnTap(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
        
    }
    
    
    func replyOnTap(sender: AnyObject) {
        let button = sender as! UIButton
        let index = button.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetCell
        if let replyTweet = cell.tweet {
            performSegueWithIdentifier("newPostSegue", sender: replyTweet)
        }
    
    
    }

    func retweetOnTap(sender: AnyObject) {
        let button = sender as! UIButton
        let index = button.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetCell
        
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
    
    
    func likeOnTap(sender: AnyObject) {
        let button = sender as! UIButton
        let index = button.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetCell
        
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
    
    

    
    func fetchTweets(count: Int, since: String?) {
        TwitterClient.sharedInstance.homeTimeline(count, olderThan: since, success: { (tweets: [Tweet]) -> () in
            self.tweets += tweets
            self.pageOffset = tweets.last?.tweetId
            self.tableView.reloadData()
            self.isMoreDataLoading = false
            self.loadingMoreView?.stopAnimating()
            self.refreshControl?.endRefreshing()
            }) { (error: NSError) -> () in
                print(error.localizedDescription)
                
        }
    }
    
    func fetchTweets() {
        TwitterClient.sharedInstance.homeTimeline(20, olderThan: nil, success: { (tweets: [Tweet]) -> () in
            self.pageOffset = nil
            self.tweets = tweets
            self.pageOffset = tweets.last?.tweetId
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            }) { (error: NSError) -> () in
                print(error.localizedDescription)
                
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = 50 + scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                fetchTweets(20, since: pageOffset)
                
                // Code to load more results
//                loadMoreData()		
            }
        }
    }
    
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

        tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        
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

        
        // infinite scrolling
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchTweets()
    }
    
    //MARK: tableView configuration
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("detailSegue", sender: indexPath.row)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func profileTap (sender: AnyObject) {
        print("tapOnProfile")
        let position: CGPoint =  sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(position)!
        performSegueWithIdentifier("profileSegue", sender: indexPath.row)
        
    }
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        cell.selectionStyle = .None
        
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
        cell.replyButton.tag = indexPath.row
        
        //MARK: programmatically set button's action
//        cell.replyBut
        cell.replyButton.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        cell.replyButton.addTarget(self, action: "replyOnTap:", forControlEvents: .TouchUpInside)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileSegue" {
            let indexInCells = sender as! Int
            let tweet = tweets[indexInCells]
            let destVC = segue.destinationViewController as! ProfileViewController
            destVC.user = tweet.user
        
        } else if segue.identifier == "detailSegue" {
            let indexInCells = sender as! Int
            let tweet = tweets[indexInCells]
            let destVC = segue.destinationViewController as! DetailViewController
            destVC.detailTweet = tweet
        
        
        } else if segue.identifier == "newPostSegue" {
            if let sender = sender as? UIBarButtonItem {
                // Do nothing
            } else {
                let inReplyTweet = sender as! Tweet
                let destVC = segue.destinationViewController as! NewPostViewController
                destVC.inReplyToId = inReplyTweet.tweetId
                destVC.tweet = inReplyTweet
            }

        }
    }


}
