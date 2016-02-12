//
//  PxePlayerAddBookmark.h
//  PxePlayerApi
//
//  Created by Swamy Manju R on 02/08/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerBookmark.h"

/**
 A simple class derived from the PxePlayerBookmark to parse the add bookmark query into the model
 */
@interface PxePlayerAddBookmark : PxePlayerBookmark

/**
 A NSString variable to hold the identity id
 */
@property (nonatomic, strong) NSString  *identityID;

/**
 A NSString variable to hold the context id
 */
@property (nonatomic, strong) NSString  *contextID;

@end
