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
    
    var placeholderLabel: UILabel!
    var removedState = 0
    
    
    @IBAction func newTweetOnTap(sender: AnyObject) {
        if let content = tweetContent.text {
            let customAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}").invertedSet
            let escapedString = content.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
            TwitterClient.sharedInstance.newTweet(escapedString!) {
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

    override func becomeFirstResponder() -> Bool {
        self.toolBar.removeFromSuperview()
        return true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
