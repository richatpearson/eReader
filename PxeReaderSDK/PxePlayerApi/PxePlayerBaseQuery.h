//
//  NTQuery.h
//  NTApi
//
//  Created by Saro Bear on 04/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the query into the model
 */
@interface PxePlayerBaseQuery : NSObject

/**
 A NSString variable to hold the user UUID
 */
@property (nonatomic, strong) NSString  *userUUID;

/**
 A NSString variable to hold the auth token
 */
@property (nonatomic, strong) NSString  *authToken;

@end
