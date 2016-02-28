//
//  DetailTweetCell.swift
//  twitter-ios
//
//  Created by Yi Huang on 16/2/27.
//  Copyright © 2016年 c2fun. All rights reserved.
//

import UIKit

class DetailTweetCell: UITableViewCell {

    @IBOutlet weak var userProfileImageView: RoundedImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var retweetNumberLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    weak var tweet: Tweet?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
