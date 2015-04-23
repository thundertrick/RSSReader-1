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
    
    
    func deleteFeedAtIndexPath(indexPath: NSIndexPath) {
        let newIndexPath = NSIndexPath(forRow: indexPath.row - 4, inSection: 0)
        let moc = coreDataHelper.managedObjectContext()
        let objects = coreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: nil, managedObjectContext: moc) as! [Feed]
        let object = objects[newIndexPath.row] as Feed
        let link = object.link
        moc.deleteObject(object)
        coreDataHelper.saveManagedObjectContext(moc)
        
        
        let p = NSPredicate(format: "source == %@", link)
        
        let items = coreDataHelper.fetchEntities(NSStringFromClass(Article), withPredicate: p, managedObjectContext: moc) as! [Article]
        var documentsDirectory:String? = nil
        var paths : [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if paths.count > 0 {
            documentsDirectory = paths[0] as? String
        }
        for item in items {
            moc.deleteObject(item)
            var path = documentsDirectory! + item.title + item.author + item.source
            if path != "" && NSFileManager.defaultManager().fileExistsAtPath(path) {
                NSFileManager.defaultManager().removeItemAtPath(path, error: NSErrorPointer())
                }

        }
        
        coreDataHelper.saveManagedObjectContext(moc)
        
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

