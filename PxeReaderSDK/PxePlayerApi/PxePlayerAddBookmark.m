//
//  PxePlayerAddBookmark.m
//  PxePlayerApi
//
//  Created by Swamy Manju R on 02/08/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerAddBookmark.h"

@implementation PxePlayerAddBookmark



- (NSString*) description
{
    NSMutableString *bookmarkDesc = [NSMutableString stringWithString:@"PxePlayerAddBookmark: \n"];
    [bookmarkDesc appendFormat:@"   bookmarkContextId: %@ \n", self.contextID];
    [bookmarkDesc appendFormat:@"   bookmarkTitle: %@ \n", self.bookmarkTitle];
    [bookmarkDesc appendFormat:@"   bookmarkUri: %@ \n", self.uri];
    [bookmarkDesc appendFormat:@"   bookmarkContentId: %@ \n", self.contentID];
    [bookmarkDesc appendFormat:@"   bookmarkIdentityId: %@ \n", self.identityID];
    [bookmarkDesc appendFormat:@"   bookmarkLabels: %@ \n", self.labels];
    [bookmarkDesc appendFormat:@"   createdTimestamp: %@ \n",self.createdTimestamp ];
    
    return bookmarkDesc;
}

@end
