//
//  PxePageDetail.m
//  PxeReader
//
//  Created by Tomack, Barry on 9/21/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePageDetail.h"
#import "PxeContext.h"
#import "PxePrintPage.h"


@implementation PxePageDetail

@dynamic isChildren;
@dynamic isDownloaded;
@dynamic pageId;
@dynamic pageNumber;
@dynamic pageTitle;
@dynamic pageURL;
@dynamic parentId;
@dynamic urlTag;
@dynamic assetId;
@dynamic context;
@dynamic printPage;

- (NSString*) description
{
    NSMutableString *pageDesc = [NSMutableString stringWithString:@"PxePageDetail: \n"];
    [pageDesc appendFormat:@"   pageId: %@ \n", self.pageId];
    [pageDesc appendFormat:@"   pageNumber: %@ \n", self.pageNumber];
    [pageDesc appendFormat:@"   pageUrl: %@\n", self.pageURL];
    [pageDesc appendFormat:@"   title: %@ \n", self.pageTitle];
    [pageDesc appendFormat:@"   isDownloaded: %@ \n", self.isDownloaded?@"YES":@"NO"];
    
    return pageDesc;
}

@end
