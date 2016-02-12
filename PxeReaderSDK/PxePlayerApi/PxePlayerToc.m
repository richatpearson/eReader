//
//  PxePlayerTOCItem.h
//  Sample
//
//  Created by Satyanarayana SVV on 10/28/13.
//  Copyright (c) 2013 Satyam. All rights reserved.
//
//
#import <Foundation/Foundation.h>

#import "PxePlayerToc.h"

@implementation PxePlayerToc

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
    if (self = [super init]) {
        self.tocEntries = [decoder decodeObjectForKey:@"tocEntries"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.tocEntries forKey:@"tocEntries"];
}

-(void)dealloc {
    self.tocEntries = nil;
}

@end
