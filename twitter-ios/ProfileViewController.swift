//
//  ProfileViewController.swift
//  twitter-ios
//
//  Created by YiHuang on 2/27/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label


class ProfileViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var user: User!
    var tweets = [Tweet]()
    var pageOffset: String?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var followButton: TwitterButton!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var avatarImage: AvatarImageView!
    
    @IBOutlet weak var header: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var followingNumber: UILabel!
    
    @IBOutlet weak var followerNumber: UILabel!
    
    @IBOutlet var headerImageView:UIImageView!
    @IBOutlet var headerBlurImageView:UIImageView!
    var blurredHeaderImageView:UIImageView?
    var backgroundImageView: UIImageView!
    
    
    @IBAction func followButtonOnTap(sender: AnyObject) {
        if let followState = user.following {
            if followState == 1 {
                TwitterClient.sharedInstance.unfollow(user.userId!) {
                    (error: NSError?) -> () in
                    if error == nil {
                        self.followButton.setTitle("Unfollow", forState: .Normal)
                        self.followButton.backgroundColor = UIColor.whiteColor()
                        self.followButton.setTitleColor(UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0), forState: .Normal)

                        self.user.following = 0
                    }
                
                }

            } else {
                
                TwitterClient.sharedInstance.follow(user.userId!) {
                    (error: NSError?) -> () in
                    if error == nil {
                        self.followButton.backgroundColor = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0)
                        self.followButton.setTitle("Following", forState: .Normal)
                        self.followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                        self.user.following = 1
                        
                    }
                    
                }
            }
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
    
    
    
    func fetchTweets() {
        TwitterClient.sharedInstance.userHomeTimeline(user.userId, count: 20, olderThan: nil, success: { (tweets: [Tweet]) -> () in
            self.pageOffset = nil
            self.tweets = tweets
            self.pageOffset = tweets.last?.tweetId
            self.tableView.reloadData()
//            self.refreshControl?.endRefreshing()
            }) { (error: NSError) -> () in
                print(error.localizedDescription)
                
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        //TODO: default background image
        backgroundImageView = UIImageView(frame: header.bounds)
        if let bgImageURL = user.profileBackgroundImageUrl {
            backgroundImageView.setImageWithURL(bgImageURL)
        } else {
            backgroundImageView.image = UIImage(named: "default-background")
        }
        
        headerLabel.text = user.name
        screenNameLabel.text = user.name
        nameLabel.text = "@\(user.screenName!)"
        avatarImage.setImageWithURL(user.profileImageUrl!)
        followerNumber.text = String(user.followerCount!)
        followingNumber.text = String(user.followingCount!)
        if let followState = user.following {
            if followState == 1 {
                followButton.backgroundColor = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0)
                followButton.setTitle("Following", forState: .Normal)
                followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            } else {
                followButton.setTitle("Unfollow", forState: .Normal)
            }
        }
        fetchTweets()
        
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // Header - Image
        
        headerImageView = UIImageView(frame: header.bounds)
        headerImageView?.image = backgroundImageView.image
        headerImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        
        headerBlurImageView = UIImageView(frame: header.bounds)
        headerBlurImageView?.image = backgroundImageView.image?.blurredImageWithRadius(10, iterations: 20, tintColor: UIColor.clearColor())
        headerBlurImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBlurImageView?.alpha = 0.0
        header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        header.clipsToBounds = true
    }
    
    //MARK: tableView configuration
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let offset = scrollView.contentOffset.y
            var avatarTransform = CATransform3DIdentity
            var headerTransform = CATransform3DIdentity
            print("scrollView \(offset)")
            // PULL DOWN -----------------
            
            if offset < 0 {
                
                let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
                let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
                headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
                headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
                //  ------------ Blur
                
                headerBlurImageView?.alpha = min (1.0, (-offset/40))
                
                header.layer.transform = headerTransform
            }
                
                // SCROLL UP/DOWN ------------
                
            else {
                
                // Header -----------
                
                headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
                
                //  ------------ Label
                
                let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
                headerLabel.layer.transform = labelTransform
                
                //  ------------ Blur
                
                headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
                
                // Avatar -----------
                
                let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
                let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
                avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
                avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
                
                if offset <= offset_HeaderStop {
                    
                    if avatarImage.layer.zPosition < header.layer.zPosition{
                        header.layer.zPosition = 0
                    }
                    
                }else {
                    if avatarImage.layer.zPosition >= header.layer.zPosition{
                        header.layer.zPosition = 2
                    }
                }
            }
            
            // Apply Transformations
            
            header.layer.transform = headerTransform
            avatarImage.layer.transform = avatarTransform
        
        
        } else {
            if tableView.contentOffset.y <= CGFloat(200) {
                self.scrollView.contentOffset = tableView.contentOffset
            }
        }
        
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
