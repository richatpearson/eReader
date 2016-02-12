//
//  NTUser.h
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class for handling user data downloaded from the server
 */
@interface PxePlayerUser : NSObject

/**
 A NSString variable to hold the user ID
 */
@property(nonatomic, strong) NSString   *identityId;

/**
 A NSString variable to hold the user auth token
 */
@property(nonatomic, strong) NSString   *authToken;

@end
