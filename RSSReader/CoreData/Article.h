//
//  Article.h
//  RSSReader
//
//  Created by The Hexagon on 04/03/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Article : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * sourceTitle;
@property (nonatomic, retain) NSNumber * starred;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedDate;

@end
