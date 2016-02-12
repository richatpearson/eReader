//
//  PxePlayerMediaQuery.h
//  PxePlayerApi
//
//  Created by Saro Bear on 17/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerNavigationsQuery.h"

/**
 A simple class to parse the media query
 */
@interface PxePlayerMediaQuery : PxePlayerNavigationsQuery

/**
 A NSString variable to hold the media type
 */
@property (nonatomic, strong) NSString  *mediaType;

/**
 A NSString variable to hold the index id
 */
@property (nonatomic, strong) NSString  *indexId;

/**
 A NSInteger variable to hold the start index
 */
@property (nonatomic, assign) NSInteger startIndex;

/**
 A NSInteger variable to hold the total result 
 */
@property (nonatomic, assign) NSInteger totalResult;

@end
