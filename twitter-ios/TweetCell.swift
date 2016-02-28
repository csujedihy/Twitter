//
//  TweetCell.swift
//  twitter-ios
//
//  Created by YiHuang on 2/27/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    
    @IBOutlet weak var retweetedButton: UIButton!
    
    @IBOutlet weak var retweetedUserLabel: UILabel!
    
    
    @IBOutlet weak var userProfileImageVIew: RoundedImage!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!
    
    @IBOutlet weak var retweetedNumberLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likedNumberLabel: UILabel!
    
    @IBOutlet weak var repliedNumberLabel: UILabel!
    
    
    @IBOutlet weak var retweetedIconHeight: NSLayoutConstraint!
    
    @IBOutlet weak var retweetedUserLabelHeight: NSLayoutConstraint!
    
    
    
    weak var tweet: Tweet?
    
    func addOneToRetweetNum() {
        if let tweet = tweet {
            tweet.retweetNumber = tweet.retweetNumber! + 1
            tweet.retweeted = true
            retweetedNumberLabel.text = String(tweet.retweetNumber!)
            let imageRetweeted = UIImage(named: "retweet-green")
            retweetButton.setImage(imageRetweeted, forState: .Normal)
            
        }
        
    }
    
    func minusOneToRetweetNum() {
        if let tweet = tweet {
            tweet.retweetNumber = tweet.retweetNumber! - 1
            tweet.retweeted = false
            retweetedNumberLabel.text = String(tweet.retweetNumber!)
            let imageRetweeted = UIImage(named: "retweet-action")
            retweetButton.setImage(imageRetweeted, forState: .Normal)
            
        }
        
    }
    
    func minusOneToLikeNum() {
        if let tweet = tweet {
            tweet.likeNumber = tweet.likeNumber! - 1
            tweet.liked = false
            likedNumberLabel.text = String(tweet.likeNumber!)
            let imageLiked = UIImage(named: "like-action")
            likeButton.setImage(imageLiked, forState: .Normal)
        }
    }
    
    
    func addOneToLikeNum() {
        if let tweet = tweet {
            tweet.likeNumber = tweet.likeNumber! + 1
            tweet.liked = true
            likedNumberLabel.text = String(tweet.likeNumber!)
            let imageLiked = UIImage(named: "like-action-red")
            likeButton.setImage(imageLiked, forState: .Normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
