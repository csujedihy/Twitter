//
//  TwitterButton.swift
//  twitter-ios
//
//  Created by YiHuang on 2/27/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class TwitterButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0).CGColor
        
    }
}
