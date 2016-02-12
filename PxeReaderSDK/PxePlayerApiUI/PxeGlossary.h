//
//  PxeGlossary.h
//  PxeReader
//
//  Created by Tomack, Barry on 3/9/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeContext;

@interface PxeGlossary : NSManagedObject

@property (nonatomic, retain) NSString * definition;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) PxeContext *context;

@end
