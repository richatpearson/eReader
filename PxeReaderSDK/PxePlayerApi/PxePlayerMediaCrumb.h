//
//  PxePlayerMediaCrumb.h
//  PxePlayerApi
//
//  Created by Saro Bear on 26/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the media crumb data
 */
@interface PxePlayerMediaCrumb : NSObject

/**
 A NSString variable to hold the crumb id
 */
@property (nonatomic, strong) NSString  *crumbId;

/**
 A NSString variable to hold the title
 */
@property (nonatomic, strong) NSString  *title;

/**
 A NSString variable to hold the page URL
 */
@property (nonatomic, strong) NSString  *pageUrl;

/**
 A NSString variable to hold the page id
 */
@property (nonatomic, strong) NSString  *pageId;

/**
 A NSString variable to hold the page title
 */
@property (nonatomic, strong) NSString  *pageTitle;

/**
 A NSString variable to hold the chapter id
 */
@property (nonatomic, strong) NSString  *chapterId;

/**
 A BOOL variable to check the bread crumb should be rendered or not
 */
@property (nonatomic, assign) BOOL      display;

@end
