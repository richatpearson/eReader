//
//  PxePlayerSearchBook.m
//  PxePlayerApi
//
//  Created by Saro Bear on 05/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerSearchPage.h"

@implementation PxePlayerSearchPage


#pragma mark - Self methods

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    
    return self;
}

-(void)dealloc
{
    self.title = nil;
    self.pageUrl = nil;
    self.textSnippet = nil;
}

- (NSString*) description
{
    NSString *desc = [NSString new];
    desc = [desc stringByAppendingFormat:@"_____PxePlayerSearchPage_____\n"];
    desc = [desc stringByAppendingFormat:@"title      : %@ \n", self.title];
    desc = [desc stringByAppendingFormat:@"pageURL    : %@ \n", self.pageUrl];
    desc = [desc stringByAppendingFormat:@"textSnippet: %@ \n", self.textSnippet];
    desc = [desc stringByAppendingFormat:@"wordHits   : %@ \n", self.wordHits];
    
    return desc;
}

@end
