//
//  PxePlayerSearchNCXQuery.m
//  PxeReader
//
//  Created by Saro Bear on 05/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerSearchNCXQuery.h"

@implementation PxePlayerSearchNCXQuery

- (NSString*) description
{
    NSMutableString *searchQuery = [NSMutableString stringWithString:@"SearchQuery: \n"];
    [searchQuery appendFormat:@"   indexContent: %@ \n", self.indexContent?@"YES":@"NO"];
    [searchQuery appendFormat:@"   urls: %@ \n", self.urls];
    [searchQuery appendFormat:@"   userUUID: %@ \n", self.userUUID];
    [searchQuery appendFormat:@"   authToken: %@ \n", self.authToken];
     
    return searchQuery;
}

@end
