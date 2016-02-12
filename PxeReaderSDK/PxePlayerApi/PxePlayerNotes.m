//
//  PxePlayerNotes.m
//  PxePlayerApi
//
//  Created by Saro Bear on 30/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerNotes.h"

@implementation PxePlayerNotes

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(void)dealloc
{
    self.userNotesDic = nil;
    self.sharedNotesDic = nil;
}

- (NSString*) description
{
    NSMutableString *notesDesc = [NSMutableString stringWithString:@"\nPxePlayerNotes: \n"];
    [notesDesc appendFormat:@"   userNotesDic: %@ \n", self.userNotesDic];
    [notesDesc appendFormat:@"   sharedNotesDic: %@ \n", self.sharedNotesDic];
    
    return notesDesc;
}

@end
