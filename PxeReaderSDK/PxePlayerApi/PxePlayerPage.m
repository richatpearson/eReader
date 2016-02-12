//
//  NTPage.m
//  NTApi
//
//  Created by Saro Bear on 04/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerPage.h"


@implementation PxePlayerPage

#pragma mark - Self methods

-(id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        self.pageId = [decoder decodeObjectForKey:@"pageId"];
        self.pageNumber = [decoder decodeObjectForKey:@"number"];
        self.pageUrl = [decoder decodeObjectForKey:@"pageUrl"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.contentFile = [decoder decodeObjectForKey:@"contentFile"];
        self.bookmarkId  = [decoder decodeObjectForKey:@"bookmarkId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.pageId forKey:@"pageId"];
    [encoder encodeObject:self.pageNumber forKey:@"number"];
    [encoder encodeObject:self.pageUrl forKey:@"pageUrl"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.contentFile forKey:@"contentFile"];
    [encoder encodeObject:self.bookmarkId forKey:@"bookmarkId"];
}

- (NSString*) description
{
    NSMutableString *pageDesc = [NSMutableString stringWithString:@"PxePlayerPage: \n"];
    [pageDesc appendFormat:@"   pageId: %@ \n", self.pageId];
    [pageDesc appendFormat:@"   pageNumber: %@ \n", self.pageNumber];
    [pageDesc appendFormat:@"   pageUrl: %@\n", self.pageUrl];
    [pageDesc appendFormat:@"   title: %@ \n", self.title];
    [pageDesc appendFormat:@"   contentFile: %@ \n", self.contentFile];
    [pageDesc appendFormat:@"   bookmarkId: %@ \n", self.bookmarkId];
    
    return pageDesc;
}

@end
