//
//  PxePlayerCheckBookmark.h
//  PxeReader
//
//  Created by Satyanarayana SVV on 11/6/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple class to parse the check bookmark
 */
@interface PxePlayerCheckBookmark : NSObject

/**
 A NSNumber variable to check the page has bookmarked
 */
@property(nonatomic, strong) NSNumber   *isBookmarked;

/**
 A NSString variable to hold the page URL 
 */
@property(nonatomic, strong) NSString   *forPageUrl;

@end
