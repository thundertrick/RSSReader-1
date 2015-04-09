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
    
    func successInDeleteFeedWithName(name: String) -> Bool {
        let moc = coreDataHelper.managedObjectContext()
        let items = coreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: NSPredicate(format: "name = %@", name), managedObjectContext: moc) as! [Feed]
        if items.count > 1 {
            for item in items {
                moc.deleteObject(item as NSManagedObject)
            }
            coreDataHelper.saveManagedObjectContext(moc)
            return true
        } else {
            return false
        }
        
    }
    
    
    func successInDeleteFeedAtIndex(index: Int) -> Bool {
        let moc = coreDataHelper.managedObjectContext()
        let items = coreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: nil, managedObjectContext: moc)
        if items.count >= index {
            let item = items.objectAtIndex(index) as! Feed
            moc.deleteObject(item)
            coreDataHelper.saveManagedObjectContext(moc)
            return true
            
        } else {
            return false
        }
        
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
        feedInfo.dateAdded = NSDate()
        coreDataHelper.saveManagedObjectContext(moc)
        delegate?.feedSaved(feedInfo)

    }
    
    
}

