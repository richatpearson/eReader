//
//  PxePrintPage.h
//  PxeReader
//
//  Created by Tomack, Barry on 7/6/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxePageDetail;

@interface PxePrintPage : NSManagedObject

@property (nonatomic, retain) NSString * pageNumber;
@property (nonatomic, retain) NSString * pageURL;
@property (nonatomic, retain) NSString * urlTag;
@property (nonatomic, retain) PxePageDetail *page;

@end
