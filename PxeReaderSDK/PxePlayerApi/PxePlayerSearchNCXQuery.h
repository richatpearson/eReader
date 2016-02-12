//
//  PxePlayerSearchNCXQuery.h
//  PxeReader
//
//  Created by Saro Bear on 05/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerSearchBookQuery.h"

/**
 A simple class to parse the search ncx data query
 */
@interface PxePlayerSearchNCXQuery : PxePlayerSearchBookQuery

/**
 A BOOL variable to check the index content
 */
@property (nonatomic, assign) BOOL      indexContent;

/**
 A NSArray variable to hold the list of urls 
 */
@property (nonatomic, strong) NSArray   *urls;

@end
