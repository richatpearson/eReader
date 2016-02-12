//
//  PxePlayerBookmarkQuery.h
//  PxePlayerApi
//
//  Created by Saro Bear on 16/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerNavigationsQuery.h"

/**
 A simple class to parse the bookmark query into the model
 */
@interface PxePlayerBookmarkQuery : PxePlayerNavigationsQuery

/**
 A NSString variable to hold the uri
 */
@property (nonatomic, strong) NSString  *uri;

/**
 A NSString variable to hold the bookmark title
 */
@property (nonatomic, strong) NSString  *bookmarkTitle;

///**
// A NSString variable to hold the uri
// */
//@property (nonatomic, strong) NSString  *userName;

@property (nonatomic, strong) NSNumber *createdTimestamp;
/**
 *  Book ID (context)
 */
@property (nonatomic,strong) NSString *contextID;

@end
