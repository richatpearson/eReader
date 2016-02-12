//
//  NTPage.h
//  NTApi
//
//  Created by Saro Bear on 04/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the page data
 */
@interface PxePlayerPage : NSObject

/**
 A NSString variable to hold the page id
 */
@property (nonatomic, strong) NSString  *pageId;

/**
 A NSString variable to hold the page number
 */
@property (nonatomic, strong) NSString  *pageNumber;

/**
 A NSString variable to hold the title
 */
@property (nonatomic, strong) NSString  *title;

/**
 A NSString to hold the page url
 */
@property (nonatomic, strong) NSString *pageUrl;

/**
 A NSString variable to hold the content file
 */
@property (nonatomic, strong) NSString  *contentFile;

/**
 A NSString variable to hold the bookmark id 
 */
@property (nonatomic, strong) NSString  *bookmarkId;


@end
