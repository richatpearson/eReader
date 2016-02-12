//
//  NTTocQuery.h
//  NTApi
//
//  Created by Saro Bear on 02/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerNavigationsQuery.h"

/**
 A simple class to parse the table of contents query
 */
@interface PxePlayerTocQuery : PxePlayerNavigationsQuery

/**
 A NSArray variable to hold the list of table of content urls
 */
@property (nonatomic, strong) NSArray *tocUrl;

@end
