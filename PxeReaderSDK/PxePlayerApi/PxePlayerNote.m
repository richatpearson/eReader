//
//  PxePlayerNote.m
//  PxePlayerApi
//
//  Created by Saro Bear on 08/08/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PxePlayerNote.h"

@implementation PxePlayerNote

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
    self.roleTypeId = nil;
    self.pageNumber = nil;
    self.pageId     = nil;
    self.noteId     = nil;
    self.note       = nil;
}

@end
