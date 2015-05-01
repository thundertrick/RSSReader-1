//
//  HTMLParser.swift
//  Blog Reader self
//
//  Created by The Hexagon on 27/02/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

import UIKit
class HTMLParser {
    
    var articleContent = String()
    var articleTitle  = String()
    var articleDatePublished = NSDate()
    var articleAuthor = String()
    var articleSource = String()

    var article : String {
        get {
            let output = formatFromContent(titleToAppend + authorToAppend + configuredDate + articleContent)
            println(output)
            return output
        }
    }

   private var configuredDate : String {
        get {
            return "<i>\(NSDateFormatter.localizedStringFromDate(articleDatePublished, dateStyle: .MediumStyle, timeStyle: .ShortStyle))</i><br />"
        }
    }
    
    private var authorToAppend : String {
        get {
            return "<span style=\"color: #EB6034; font-family:Avenir-Heavy;\">\(articleSource)</span> / \(articleAuthor)<br />"
        }
        
    }
  
    private var titleToAppend : String {
        get {
            return "<h2>\(articleTitle)</h2>"
        }
    }

    private func formatFromContent(content : String) -> String {
        let formattingHTML = "<body style=\"font-family:Avenir-Book;\" ><html style=\"-webkit-text-size-adjust: none;\" ><style type='text/css'>img { max-width: 100%; width: auto; height: auto; }</style><style type='text/css'>* a { color: #EB6034; text-decoration: underline; }</style>"
        var workingContent = String()
        workingContent = formattingHTML + content
        workingContent = workingContent.stringByReplacingOccurrencesOfString("<img", withString: "<br /><img").stringByReplacingOccurrencesOfString("<iframe", withString: "<br /><iframe").stringByReplacingOccurrencesOfString("</iframe>", withString: "</iframe><br />")
        
        return workingContent

    }
}
