//
//  NTBookShelf.m
//  NTApi
//
//  Created by Swamy Manju R on 02/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerBookShelf.h"

@implementation PxePlayerBookShelf

-(id)init
{
    self = [super init];
    if (self) {
        self.books = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init]) {
        self.books = [decoder decodeObjectForKey:@"books"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.books forKey:@"books"];
}


-(void)dealloc {
    self.books = nil;
}

@end
