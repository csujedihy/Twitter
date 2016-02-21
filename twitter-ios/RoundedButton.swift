//
//  RoundedButton.swift
//  twitter-ios
//
//  Created by YiHuang on 2/21/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    
    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor(red: 29/255, green: 142/255, blue: 238/255, alpha: 1.0).CGColor
        self.layer.borderWidth = 1.0
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
