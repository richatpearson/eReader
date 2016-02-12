//
//  NTChapter.m
//  NTApi
//
//  Created by Saro Bear on 04/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerChapter.h"

@implementation PxePlayerChapter

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
        self.chapterUUID = [decoder decodeObjectForKey:@"chapterUUID"];
        self.pageUUIDS = [decoder decodeObjectForKey:@"pageUUIDS"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.backMatter = [decoder decodeObjectForKey:@"backMatter"];
        self.frontMatter = [decoder decodeObjectForKey:@"frontMatter"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.chapterUUID forKey:@"chapterUUID"];
    [encoder encodeObject:self.pageUUIDS forKey:@"pageUUIDS"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.backMatter forKey:@"backMatter"];
    [encoder encodeObject:self.frontMatter forKey:@"frontMatter"];
}

-(void)dealloc
{
    self.chapterUUID    = nil;
    self.pageUUIDS      = nil;
    self.title          = nil;
    self.backMatter     = nil;
    self.frontMatter    = nil;

}

@end
