//
//  PxePlayerNavigationsQuery.h
//  PxePlayerApi
//
//  Created by Saro Bear on 16/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PxePlayerBaseQuery.h"

/**
 A simple class to parse the navigation query
 */
@interface PxePlayerNavigationsQuery : PxePlayerBaseQuery

/**
 A NSString variable to hold the book UUID 
 */
@property (nonatomic, strong) NSString  *bookUUID;

/**
 Need to add online baseURL for the web offline support (as weird as that sounds)
 */
@property (nonatomic, strong) NSString *baseURL;

@end
