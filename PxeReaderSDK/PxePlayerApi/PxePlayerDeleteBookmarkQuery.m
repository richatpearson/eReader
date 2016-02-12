//
//  PxePlayerDeleteBookmarkQuery.m
//  PxeReader
//
//  Created by Satyanarayana SVV on 10/31/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerDeleteBookmarkQuery.h"

@implementation PxePlayerDeleteBookmarkQuery

#pragma mark - Self methods

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(void)dealloc {
    self.contentID = nil;
}

@end
