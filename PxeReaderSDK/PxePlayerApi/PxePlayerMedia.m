//
//  PxePlayerMedia.m
//  PxePlayerApi
//
//  Created by Saro Bear on 17/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PxePlayerMedia.h"

@implementation PxePlayerMedia

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
    self.mediaId        = nil;
    self.mimeType       = nil;
    self.contentFile    = nil;
    self.pageNumber     = nil;
    self.pageTitle      = nil;
    self.breadCrumb     = nil;

}

@end
