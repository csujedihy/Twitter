//
//  NewPostViewController.swift
//  twitter-ios
//
//  Created by YiHuang on 2/20/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetContent: UITextView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var avatarImageView: AvatarImageView!
    
    @IBOutlet weak var charCountLabel: UIBarButtonItem!
    @IBOutlet weak var inReplyToLabel: UILabel!
    @IBOutlet weak var inReplyIcon: UIButton!
    
    var inReplyToId: String?
    var tweet: Tweet?
    var placeholderLabel: UILabel!
    var removedState = 0
    var remainedLength = TwitterClient.tweetMaxLength
    
    
    @IBAction func newTweetOnTap(sender: AnyObject) {
        if let content = tweetContent.text {
            let escapedString = content.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            TwitterClient.sharedInstance.newTweet(escapedString!, replyId: inReplyToId) {
                (error: NSError?) -> () in
                self.dismissViewControllerAnimated(true) {
                    NSNotificationCenter.defaultCenter().postNotificationName(TwitterClient.userDidPostTweet, object: nil)
                }
            }
        }
    }
    
    
    
    @IBAction func closeOnTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        placeholderLabel.hidden = true

    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.hidden = false

        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if range.location >= TwitterClient.tweetMaxLength {
            
            return false
            
        }

        charCountLabel.title = String(TwitterClient.tweetMaxLength - (range.location + 1))
        return true
        
    }
    
    
    override func becomeFirstResponder() -> Bool {
        self.toolBar.removeFromSuperview()
        return true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        inReplyIcon.alpha = 0
        inReplyToLabel.alpha = 0
        if let inReplyToId = inReplyToId {
            print(inReplyToId)
            inReplyIcon.alpha = 1
            inReplyToLabel.alpha = 1
            if let tweet = tweet {
                inReplyToLabel.text = "In reply to \(tweet.user!.name!)"
                tweetContent.text = "@\(tweet.user!.screenName!) "
            }
            
        }
        
        if let me = User.currentUser {
            avatarImageView.setImageWithURL(me.profileImageUrl!)
            screenName.text = me.screenName
            nameLabel.text = me.name
        }
        
        tweetContent.inputAccessoryView = self.toolBar
        tweetContent.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "What's happening?"
        placeholderLabel.sizeToFit()
        tweetContent.addSubview(placeholderLabel)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !tweetContent.text.isEmpty
//        tweetContent.becomeFirstResponder()

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
