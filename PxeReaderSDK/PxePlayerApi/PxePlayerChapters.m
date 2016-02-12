//
//  PxePlayerChapters.m
//  PxePlayerApi
//
//  Created by Saro Bear on 17/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerChapters.h"

@implementation PxePlayerChapters

#pragma mark - Self methods

-(id)init
{
    self = [super init];
    if (self) {
        self.chapters = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.chapters = [decoder decodeObjectForKey:@"chapters"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.chapters forKey:@"chapters"];
}

-(void)dealloc {
    self.chapters = nil;
}

@end
