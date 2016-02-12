//
//  PxePlayerCheckBookmark.m
//  PxeReader
//
//  Created by Satyanarayana SVV on 11/6/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerCheckBookmark.h"

@implementation PxePlayerCheckBookmark

- (NSString*) description
{
    NSMutableString *bookmarkDesc = [NSMutableString stringWithString:@"PxePlayerCheckBookmark: \n"];
    [bookmarkDesc appendFormat:@"   isBookmarked: %@ \n", self.isBookmarked];
    [bookmarkDesc appendFormat:@"   forPageUrl: %@ \n", self.forPageUrl];
    
    return bookmarkDesc;
}

@end
