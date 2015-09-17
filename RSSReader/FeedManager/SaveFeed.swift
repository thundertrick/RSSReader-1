//
//  SaveFeed.swift
//  RSSReader
//
//  Created by The Hexagon on 03/03/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

import UIKit

protocol SaveFeedDelegate {
    func savedFeedFailedWithError()
    func feedSaved(feedItem: Feed)
}

class SaveFeedManager: NSObject, MWFeedParserDelegate {
    let coreDataHelper = CoreDataHelper()
    
    var delegate : SaveFeedDelegate?
    
    
    private var givenFeedName = ""
    private var givenFeedURL = ""
    
    
    func deleteFeed(object: Feed, moc: NSManagedObjectContext) {
          print("and and and here")
        let link = object.link
        moc.deleteObject(object)
        coreDataHelper.saveManagedObjectContext(moc)
              print("and and and and here")
        let managedOC = coreDataHelper.managedObjectContext()
        let p = NSPredicate(format: "source == %@", link)
        
        let items = coreDataHelper.fetchEntities(NSStringFromClass(Article), withPredicate: p, managedObjectContext: managedOC) as! [Article]
        for item in items {
            managedOC.deleteObject(item)
          }

        
        coreDataHelper.saveManagedObjectContext(managedOC)
        
    }
    
    func saveFeedWithURL(url: String, withName name: String) {
        if let feedURL = NSURL(string: url){
                givenFeedURL = url
                givenFeedName = name
                let feedParser = MWFeedParser(feedURL: feedURL)
                feedParser.delegate = self
                feedParser.feedParseType = ParseTypeInfoOnly
                feedParser.parse()
                } else {
            delegate?.savedFeedFailedWithError()
         
        }
        
    }
    
    func retrieveNumber() -> Double {
        if let object = NSUserDefaults.standardUserDefaults().objectForKey("numberForFeed") as? Double {
            let newNumber = object + 1.0
            NSUserDefaults.standardUserDefaults().setObject(newNumber, forKey: "numberForFeed")
            NSUserDefaults.standardUserDefaults().synchronize()
            return newNumber
            
        } else {
            let number = 0.0
            NSUserDefaults.standardUserDefaults().setObject(number, forKey: "numberForFeed")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSUserDefaults.standardUserDefaults().synchronize()
            return number
        }
    }
    // MARK: – FeedParser Delegate
    
     func feedParser(parser: MWFeedParser!, didFailWithError error: NSError!) {
        delegate?.savedFeedFailedWithError()
      
    }
    
     func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        let moc = coreDataHelper.managedObjectContext()
        let feedInfo : Feed = coreDataHelper.insertManagedObject(NSStringFromClass(Feed), managedObjectContext: moc) as! Feed
        feedInfo.link = givenFeedURL
        feedInfo.title = info.title
        feedInfo.summary = (info.summary != nil) ? info.summary : ""
        feedInfo.name = (givenFeedName != "") ? givenFeedName : info.title
        feedInfo.orderValue = retrieveNumber()
        coreDataHelper.saveManagedObjectContext(moc)
        delegate?.feedSaved(feedInfo)

    }
    
    
}

