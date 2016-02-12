//
//  PxePlayerBookmark.h
//  PxePlayerApi
//
//  Created by Saro Bear on 16/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the bookmark data downloaded from the server into the model
 */
@interface PxePlayerBookmark : NSObject

/**
 A NSString variable to hold the bookmark title
 */
@property (nonatomic, strong) NSString  *bookmarkTitle;

/**
 A NSString variable to hold the uri
 */
@property (nonatomic, strong) NSString  *uri;

/**
 A NSString variable to hold the content id
 */
@property (nonatomic, strong) NSString  *contentID;

/**
 A NSArray variable to hold the list of labels
 */
@property (nonatomic, strong) NSArray   *labels;
/**
 *  Bookmark time stamp placeholder
 */
@property (nonatomic, strong) NSNumber *createdTimestamp;
/**
 *  Used for determing if the device is offline and will be toggle when persisted
 */
@property BOOL queued;
/**
 *  Used for determing if offline this bookmark will be delted when its back online
 */
@property BOOL markedDelete;

/**
 Need to add online baseURL for the web offline support (as weird as that sounds)
 */
@property (nonatomic, strong) NSString *baseURL;

@end
