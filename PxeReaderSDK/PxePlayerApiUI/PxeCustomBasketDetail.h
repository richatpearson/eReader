//
//  PxeCustomBasketDetail.h
//  PxeReader
//
//  Created by Tomack, Barry on 3/9/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeContext;

@interface PxeCustomBasketDetail : NSManagedObject

@property (nonatomic, retain) NSNumber * isChildren;
@property (nonatomic, retain) NSString * pageId;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSString * pageTitle;
@property (nonatomic, retain) NSString * pageURL;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * urlTag;
@property (nonatomic, retain) PxeContext *context;

@end
