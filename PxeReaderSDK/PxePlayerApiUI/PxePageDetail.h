//
//  PxePageDetail.h
//  PxeReader
//
//  Created by Tomack, Barry on 9/21/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeContext, PxePrintPage;

@interface PxePageDetail : NSManagedObject

@property (nonatomic, retain) NSNumber * isChildren;
@property (nonatomic, retain) NSNumber * isDownloaded;
@property (nonatomic, retain) NSString * pageId;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSString * pageTitle;
@property (nonatomic, retain) NSString * pageURL;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * urlTag;
@property (nonatomic, retain) NSString * assetId;
@property (nonatomic, retain) PxeContext *context;
@property (nonatomic, retain) NSSet *printPage;
@end

@interface PxePageDetail (CoreDataGeneratedAccessors)

- (void)addPrintPageObject:(PxePrintPage *)value;
- (void)removePrintPageObject:(PxePrintPage *)value;
- (void)addPrintPage:(NSSet *)values;
- (void)removePrintPage:(NSSet *)values;

@end
