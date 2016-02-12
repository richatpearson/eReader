//
//  PxeCustomBasketDetail.m
//  PxeReader
//
//  Created by Tomack, Barry on 3/9/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxeCustomBasketDetail.h"
#import "PxeContext.h"


@implementation PxeCustomBasketDetail

@dynamic isChildren;
@dynamic pageId;
@dynamic pageNumber;
@dynamic pageTitle;
@dynamic pageURL;
@dynamic parentId;
@dynamic urlTag;
@dynamic context;

- (NSString*) description
{
    NSMutableString *pageDesc = [NSMutableString stringWithString:@"PxeCustomBasketDetail: \n"];
    [pageDesc appendFormat:@"   pageId: %@ \n", self.pageId];
    [pageDesc appendFormat:@"   pageNumber: %@ \n", self.pageNumber];
    [pageDesc appendFormat:@"   pageTitle: %@ \n", self.pageTitle];
    [pageDesc appendFormat:@"   pageUrl: %@\n", self.pageURL];
    [pageDesc appendFormat:@"   title: %@ \n", self.pageTitle];
    [pageDesc appendFormat:@"   context.contextId: %@ \n", self.context.context_id];
    
    return pageDesc;
}

@end
