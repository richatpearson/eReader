//
//  PxePlayerMedia.h
//  PxePlayerApi
//
//  Created by Saro Bear on 17/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 A simple class to parse the media data
 */
@interface PxePlayerMedia : NSObject

/**
 A NSString variable to hold the media id
 */
@property (nonatomic, strong) NSString  *mediaId;

/**
 A NSString variable to hold the mimde type
 */
@property (nonatomic, strong) NSString  *mimeType;

/**
 A NSString variable to hold the content file
 */
@property (nonatomic, strong) NSString  *contentFile;

/**
 A NSString variable to hold the page number
 */
@property (nonatomic, strong) NSString  *pageNumber;

/**
 A NSString variable to hold the page title
 */
@property (nonatomic, strong) NSString  *pageTitle;

/**
 A NSString variable to hold the page URL
 */
@property (nonatomic, strong) NSString  *pageURL;

/**
 A NSArray variable to hold the list of bread crumb data
 */
@property (nonatomic, strong) NSArray   *breadCrumb;

@end
