//
//  UIFont+Custom.swift
//  RSSReader
//
//  Created by The Hexagon on 25/04/15.
//  Copyright (c) 2015 The Hexaong. All rights reserved.
//

import UIKit


extension UIFont {
    
    class func fontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir-Book", size: size)!
    }
    
    class func boldFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir-Heavy", size: size)!
        
    }
    
    class func italicFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir-BookOblique", size: size)!
        
    }
}