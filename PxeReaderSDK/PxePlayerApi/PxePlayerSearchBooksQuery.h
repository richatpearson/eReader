//
//  PxePlayerBookSearchQuery.h
//  PxePlayerApi
//
//  Created by Saro Bear on 05/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerBaseQuery.h"

/**
 A simple class to parse the query for search books in bookshelf
 */
@interface PxePlayerSearchBooksQuery : PxePlayerBaseQuery

/**
 A NSInteger variable to hold the start index
 */
@property (nonatomic, assign) NSInteger     startIndex;

/**
 A NSInteger variable to hold the maximum results
 */
@property (nonatomic, assign) NSInteger     maxResults;

/**
 A NSString variable to hold the search term
 */
@property (nonatomic, strong) NSString      *searchTerm;

/**
 A NSString variable to hold the language information 
 */
@property (nonatomic, strong) NSString      *language;

@end
