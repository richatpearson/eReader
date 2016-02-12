//
//  PxePlayerSearchBookQuery.h
//  PxePlayerApi
//
//  Created by Saro Bear on 05/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//



#import "PxePlayerSearchBooksQuery.h"

/**
 A simple class to parse the book search query
 */
@interface PxePlayerSearchBookQuery : PxePlayerSearchBooksQuery

/**
 A NSString variable to hold the index id
 */
@property (nonatomic, strong) NSString      *indexId;

/**
 A NSString variable to hold the book id
 */
@property (nonatomic, strong) NSString      *bookId;

/**
 A NSString variable to hold the content id
 */
@property (nonatomic, strong) NSString      *contentId;

/**
 A NSInteger variable to hold the page number 
 */
@property (nonatomic, assign) NSInteger     pageNumber;

@end
