//
//  PxeBookMark.h
//  PxeReader
//
//  Created by Mason, Darren J on 3/6/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeContext;

@interface PxeBookMark : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * markedDelete;
@property (nonatomic, retain) NSNumber * queued;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) PxeContext *context;

@end
