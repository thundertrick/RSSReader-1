//
//  UpdateDataManager.swift
//  RSSReader
//
//  Created by The Hexagon on 03/03/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

import UIKit
import Alamofire

protocol UpdateDataManagerDelegate {
    func updateDataFailedWithError()
    func updatedData()
}

class UpdateDataManager: NSObject, MWFeedParserDelegate {
    var coreDataHelper = CoreDataHelper()
    
    
    var delegate : UpdateDataManagerDelegate?
     var urls : [String] {
        let items = retrieveFeeds()
        var workingURLs : [String] = []
        if items.count > 0 {
            for item in items {
                let moc = coreDataHelper.managedObjectContext()
                let realItem = moc.objectWithID(item.objectID) as! Feed
                workingURLs.append(realItem.link)
                
            }
        }
        return workingURLs
    }
    
     func retrieveFeeds() -> [Feed] {
        let moc = coreDataHelper.managedObjectContext()
        let items = coreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: nil, managedObjectContext: moc) as! [Feed]
        return items
    }
    
    func update() {
        if urls.count > 0 {
            for url in urls {
                requestFromURL(url)
            }
            delegate?.updatedData()

        }
        
    }
    
    
    
     func requestFromURL(url: String)  {
        let url = NSURL(string: url)
        let feedParser = MWFeedParser(feedURL: url)
        feedParser.delegate = self
        feedParser.feedParseType = ParseTypeFull
        feedParser.parse()
    }
    
    
    // MARK: – FeedParser Delegate
    
     func feedParser(parser: MWFeedParser!, didFailWithError error: NSError!) {
        delegate?.updateDataFailedWithError()

        
    }

    
     func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {

        if let date = item.date {
        let author = (item.author != nil) ? item.author : "(no author)"
        let title = (item.title != nil) ? item.title : "(no title)"
        let summary = (item.summary != nil) ? item.summary : ""
        let content = (item.content != nil) ? item.content : summary
        let updatedDate = (item.date != nil) ? item.updated : NSDate()
        let link = (item.link != nil) ? item.link : "\(parser.url())"
        let source = "\(parser.url())"
        let moc = coreDataHelper.managedObjectContext()
        let items = coreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: NSPredicate(format: "link == %@", source), managedObjectContext: moc) as! [Feed]
        let sourceTitle : String = items[0].name
    
        
        
    
        let p = NSPredicate(format: "title == %@", title)
        let p1 = NSPredicate(format: "author == %@", author)
        let p2 = NSPredicate(format: "source == %@", source)
        var p3 = NSPredicate()
        if let theDate = item.date {
            p3 = NSPredicate(format: "date == %@", item.date)
        } else {
            p3 = NSPredicate(format: "content == %@", content)
        }
        let predicateArray = [p, p1, p2, p3]
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        let articles : [Article] = coreDataHelper.fetchEntities(NSStringFromClass(Article), withPredicate: predicate, managedObjectContext: moc) as! [Article]
        if articles.count > 0 {
            for article in articles {
                if article.content != content {
                    article.content = content
                }
                
                if article.title != title {
                    article.title = title
                }
                
                if article.sourceTitle != sourceTitle {
                    article.sourceTitle = sourceTitle
                }
                if article.updatedDate != updatedDate {
                    article.updatedDate = updatedDate
                }
                
       
            }
            
            } else {

            let feedArticle : Article = coreDataHelper.insertManagedObject(NSStringFromClass(Article), managedObjectContext: moc) as! Article
            feedArticle.author =  author
            feedArticle.content = summary
            feedArticle.date = date
            feedArticle.link = link
            feedArticle.source = source
            feedArticle.summary = summary
            feedArticle.sourceTitle = sourceTitle
            feedArticle.title = title
            feedArticle.updatedDate = updatedDate
            feedArticle.read = false
            feedArticle.starred = false
            var imageSource = ""
            if feedArticle.content != nil {
                
                let htmlContent = feedArticle.content as NSString
                
                let rangeOfString = NSMakeRange(0, htmlContent.length)
                let regex = NSRegularExpression(pattern: "(<img.*?src=\")(.*?)(\".*?>)", options: nil, error: nil)
                
                if htmlContent.length > 0 {
                    var match = regex?.matchesInString(htmlContent as String, options: nil, range: rangeOfString)
                    
                    if (match != nil) && (match?.count > 0) {
                        for (index, value) in enumerate(match!) {
                            
                            let imageURL = htmlContent.substringWithRange(value.rangeAtIndex(2)) as NSString
                            
                            if (NSString(string: imageURL.lowercaseString).rangeOfString("feedburner").location == NSNotFound) && (NSString(string: imageURL.lowercaseString).rangeOfString("feedsportal").location == NSNotFound) && (imageURL.substringToIndex(4) == "http") {
                                
                                
                                imageSource = imageURL as String
                                break
                            }
                            
                        }
                    }
                }
                
                if imageSource != "" {
                    Alamofire.request(.GET, imageSource)
                        .response { (request, response, data, error) in
                            if error == nil {
                                
                                var documentsDirectory:String? = nil
                                var paths : [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                                if paths.count > 0 {
                                    documentsDirectory = paths[0] as? String
                                    var savePath : String = documentsDirectory! + title + author + source
                                    NSFileManager.defaultManager().createFileAtPath(savePath, contents: data as? NSData, attributes: nil)
                                }
                                
                            } else {
                                println("image downloading error")
                            }
                    }
                }
            }
         
       }
        coreDataHelper.saveManagedObjectContext(moc)
            
        } else {
            println("\(item)" + " didn't have date")
        }
        
    }
    
     func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        let moc = coreDataHelper.managedObjectContext()
        let predicate = NSPredicate(format: "link = %@", "\(parser.url())")
        let feeds = coreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: predicate, managedObjectContext: moc) as!  [Feed]
        for feedItem in feeds {
            let amoc = coreDataHelper.managedObjectContext()
            let feed = amoc.objectWithID(feedItem.objectID) as!Feed
            if feed.title != info.title {
                feed.title = info.title
            }
            if feed.summary != info.summary {
                feed.summary = info.summary
            }
            coreDataHelper.saveManagedObjectContext(moc)
        }
        
    }
    
       
    
}



