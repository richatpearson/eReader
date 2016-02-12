//
//  PxePlayerMediaCrumb.m
//  PxePlayerApi
//
//  Created by Saro Bear on 26/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PxePlayerMediaCrumb.h"

@implementation PxePlayerMediaCrumb


#pragma mark - Self methods

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(void)dealloc
{
    self.crumbId = nil;
    self.title = nil;
    self.pageUrl = nil;
    self.pageId = nil;
    self.pageTitle = nil;
    self.chapterId = nil;

}

@end
