//
//  PxePlayerBookmarks.m
//  PxePlayerApi
//
//  Created by Swamy Manju R on 22/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PxePlayerBookmarks.h"

@implementation PxePlayerBookmarks

#pragma mark - Self methods
-(id)init
{
    self = [super init];
    if (self) {
        self.bookmarks = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
    
}

-(void)dealloc
{
    self.bookmarks = nil;
}

@end
