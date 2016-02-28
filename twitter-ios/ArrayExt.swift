//
//  ArrayExt.swift
//  twitter-ios
//
//  Created by YiHuang on 2/27/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import Foundation

import Foundation

extension Array {
    var last: Element? {
        if self.count > 0 {
            return self[self.endIndex - 1]
        } else {
            return nil
        }
    }
}