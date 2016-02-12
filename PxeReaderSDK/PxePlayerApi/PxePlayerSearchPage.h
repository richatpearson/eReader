//
//  PxePlayerSearchBook.h
//  PxePlayerApi
//
//  Created by Saro Bear on 05/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the search page data
 */
@interface PxePlayerSearchPage : NSObject

/**
 A NSString variable to hold the title of the page
 */
@property (nonatomic, strong) NSString *title;

/**
 A NSString variable to hold the page URL
 */
@property (nonatomic, strong) NSString *pageUrl;

/**
 A NSString variable to hold the text snippet
 */
@property (nonatomic, strong) NSString *textSnippet;

/**
 A NSArray variable to hold the word hits
 */
@property (nonatomic, strong) NSArray* wordHits;

@end
