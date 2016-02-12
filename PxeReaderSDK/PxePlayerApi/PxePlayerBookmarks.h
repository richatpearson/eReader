//
//  PxePlayerBookmarks.h
//  PxePlayerApi
//
//  Created by Swamy Manju R on 22/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the bookmarks into the list of models
 */
@interface PxePlayerBookmarks : NSObject

/**
 A NSString variable to hold the context id
 */
@property (nonatomic, strong) NSString       *contextId;

/**
 A NSString variable to hold the identity id
 */
@property (nonatomic, strong) NSString       *identityId;

/**
 A NSMutableArray variable to hold the list of bookmarks model
 */
@property (nonatomic, strong) NSMutableArray *bookmarks;

@end
