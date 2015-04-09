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

    var article : String {
        get {
            return formatFromContent(titleToAppend + authorToAppend + configuredDate + articleContent)
        }
    }

   private var configuredDate : String {
        get {
            return "\(NSDateFormatter.localizedStringFromDate(articleDatePublished, dateStyle: .MediumStyle, timeStyle: .ShortStyle))<br />"
        }
    }
    
    private var authorToAppend : String {
        get {
            return "<i>by: \(articleAuthor)</i><br />"
        }
        
    }
  
    private var titleToAppend : String {
        get {
            return "<h2>\(articleTitle)</h2>"
        }
    }

    private func formatFromContent(content : String) -> String {
        let formattingHTML = "<body style=\"font-family:Helvetica;\" ><html style=\"-webkit-text-size-adjust: none;\" ><style type='text/css'>img { max-width: 100%; width: auto; height: auto; }</style>"
        var workingContent = String()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            workingContent = formattingHTML + content
        } else {
            let origString = "<iframe allowfullscreen=\"\" frameborder=\"0\" height=\"360\""
            let stringToReplace = "<iframe allowfullscreen=\"\" frameborder=\"0\" height=\"auto\""
            let secondOrigString = "width=\"640\"></iframe>"
            let secondStringToReplace = "width=\"100%\"></iframe>"
            let thirdOrigString = "<iframe allowfullscreen=\"\" frameborder=\"0\" height=\"315\""
            let thirdStringToReplace = "<iframe allowfullscreen=\"\" frameborder=\"0\" heigth=\"auto\""
            let fourthSecondOrigString = "width=\"560\"></iframe>"
            let fourthSecondStringToReplace = "width=\"100%\"></iframe>"
            workingContent = formattingHTML + content.stringByReplacingOccurrencesOfString(origString, withString: stringToReplace).stringByReplacingOccurrencesOfString(secondOrigString, withString: secondStringToReplace).stringByReplacingOccurrencesOfString(thirdOrigString, withString: thirdStringToReplace).stringByReplacingOccurrencesOfString(fourthSecondOrigString, withString: fourthSecondStringToReplace)
        }
        workingContent = workingContent.stringByReplacingOccurrencesOfString("<img", withString: "<br /><img").stringByReplacingOccurrencesOfString("/></a></div>", withString: "/></a></div><br />").stringByReplacingOccurrencesOfString("<iframe", withString: "<br /><iframe").stringByReplacingOccurrencesOfString("</iframe>", withString: "</iframe><br />")
        return workingContent
    }


}
