//
//  PxePlayerBookSearchQuery.m
//  PxePlayerApi
//
//  Created by Saro Bear on 05/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerSearchBooksQuery.h"

@implementation PxePlayerSearchBooksQuery

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(void)dealloc
{
    self.searchTerm = nil;
    self.language   = nil;
}

@end
