//
//  PxePlayerSearchURLsQuery.h
//  PxeReader
//
//  Created by Saro Bear on 05/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerSearchBookQuery.h"

/**
 A simple class to parse the search url query
 */
@interface PxePlayerSearchURLsQuery : PxePlayerSearchBookQuery

/**
 A NSArray variable to hold the list of content urls
 */
@property (nonatomic, strong) NSArray *contentURLs;

@end
