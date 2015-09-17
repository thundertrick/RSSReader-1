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
    var feedParser : MWFeedParser? = nil
    
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
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if self.urls.count > 0 {
            for url in self.urls {
           self.requestFromURL(url)
            }
       self.delegate?.updatedData()
            

        }
            
        }
        
    }
    
    
    
     func requestFromURL(url: String)  {
        let url = NSURL(string: url)
         feedParser = MWFeedParser(feedURL: url)
        feedParser!.delegate = self
        feedParser!.feedParseType = ParseTypeFull
        feedParser!.parse()
        feedParser = nil
    }
    
    
    // MARK: – FeedParser Delegate
    
     func feedParser(parser: MWFeedParser!, didFailWithError error: NSError!) {
        delegate?.updateDataFailedWithError()

        
    }

    
     func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        
        dispatch_async(dispatch_get_main_queue()) {

        if let date = item.date {
        let author = (item.author != nil) ? item.author : "(no author)"
        let title = (item.title != nil) ? item.title : "(no title)"
        var summary = (item.summary != nil) ? item.summary : ""
            summary = summary.stringByReplacingOccurrencesOfString("&nbsp;", withString: "")
        var content = (item.content != nil) ? item.content : summary
            content = content.stringByReplacingOccurrencesOfString("&nbsp;", withString: "")
        let updatedDate = (item.date != nil) ? item.updated : NSDate()
        let link = (item.link != nil) ? item.link : "\(parser.url())"
        let source = "\(parser.url())"
        let moc = self.coreDataHelper.managedObjectContext()
        let items = self.coreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: NSPredicate(format: "link == %@", source), managedObjectContext: moc) as! [Feed]
        let sourceTitle : String = items[0].name
    
        
        
    
        let p = NSPredicate(format: "title == %@", title)
        let p1 = NSPredicate(format: "author == %@", author)
        let p2 = NSPredicate(format: "source == %@", source)
        var p3 = NSPredicate()
        if let theDate = item.date {
            p3 = NSPredicate(format: "date == %@", theDate)
        } else {
            p3 = NSPredicate(format: "content == %@", content)
        }
        let predicateArray = [p, p1, p2, p3]
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        let articles : [Article] = self.coreDataHelper.fetchEntities(NSStringFromClass(Article), withPredicate: predicate, managedObjectContext: moc) as! [Article]
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

            let feedArticle : Article = self.coreDataHelper.insertManagedObject(NSStringFromClass(Article), managedObjectContext: moc) as! Article
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
         
            }
        self.coreDataHelper.saveManagedObjectContext(moc)
            
        } else {
            print("\(item)" + " didn't have date")
        }
            
        }
        
    }
    
     func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        
        dispatch_async(dispatch_get_main_queue()) {
        let moc = self.coreDataHelper.managedObjectContext()
        let predicate = NSPredicate(format: "link = %@", "\(parser.url())")
        let feeds = self.coreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: predicate, managedObjectContext: moc) as!  [Feed]
        for feedItem in feeds {
            let amoc = self.coreDataHelper.managedObjectContext()
            let feed = amoc.objectWithID(feedItem.objectID) as!Feed
            if feed.title != info.title {
                feed.title = info.title
            }
            if feed.summary != info.summary {
                feed.summary = info.summary
            }
            self.coreDataHelper.saveManagedObjectContext(moc)
        }
        
    }
    
}

       
    
}



