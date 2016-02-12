//
//  PxePlayerSearchPages.m
//  PxePlayerApi
//
//  Created by Saro Bear on 11/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerSearchPages.h"
#import "PxePlayerSearchPage.h"

@implementation PxePlayerSearchPages

#pragma mark - Self methods

-(id)init
{
    self = [super init];
    if(self) {
        self.searchedItems = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

-(void)dealloc {
    self.searchedItems = nil;
    self.labels = nil;
}

- (NSString*) description
{
    NSString *desc = [NSString new];
    desc = [desc stringByAppendingFormat:@"__________PxePlayerSearchPages__________\n"];
    desc = [desc stringByAppendingFormat:@"totalPages: %ld\n", (long)self.totalPages];
    desc = [desc stringByAppendingFormat:@"totalResults: %ld\n", (long)self.totalResults];
    for (PxePlayerSearchPage *searchPage in self.searchedItems)
    {
        desc = [desc stringByAppendingFormat: @"%@", searchPage];
    }
    for (NSString *label in self.labels)
    {
        desc = [desc stringByAppendingFormat:@"wordHit: %@", label];
    }
    
    return desc;
}

@end
