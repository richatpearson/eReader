//
//  PxeListPage.h
//  PxeReader
//
//  Created by Tomack, Barry on 3/9/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PxeListPage : NSManagedObject

@property (nonatomic, retain) NSNumber * pageIndex;
@property (nonatomic, retain) NSString * pageURL;
@property (nonatomic, retain) NSString * urlTag;

@end
