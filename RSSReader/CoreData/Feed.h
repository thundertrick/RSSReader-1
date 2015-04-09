//
//  Feed.h
//  RSSReader
//
//  Created by The Hexagon on 04/03/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Feed : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * dateAdded;

@end
