//
//  PxePlayerBookmark.m
//  PxePlayerApi
//
//  Created by Saro Bear on 16/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerBookmark.h"

@implementation PxePlayerBookmark

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(void)dealloc
{
    self.uri      = nil;
    self.bookmarkTitle  = nil;
}

- (NSString*) description
{
    NSMutableString *bookmarkDesc = [NSMutableString stringWithString:@"PxePlayerBookmark: \n"];
    [bookmarkDesc appendFormat:@"   bookmarkTitle: %@ \n", self.bookmarkTitle];
    [bookmarkDesc appendFormat:@"   bookmarkUri: %@ \n", self.uri];
    [bookmarkDesc appendFormat:@"   bookmarkContentId: %@ \n", self.contentID];
    [bookmarkDesc appendFormat:@"   bookmarkLabels: %@ \n", self.labels];
    [bookmarkDesc appendFormat:@"   createdTimestamp: %@ \n",self.createdTimestamp ];
    
    return bookmarkDesc;
}


@end
