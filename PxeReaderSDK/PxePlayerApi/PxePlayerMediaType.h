//
//  PxePlayerMediaType.h
//  PxePlayerApi
//
//  Created by Saro Bear on 17/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


/**
 A simple class to parse the media type
 */
@interface PxePlayerMediaType : NSObject

/**
 A NSString variable to hold the type of the media
 */
@property (nonatomic, strong) NSString  *type;

/**
 A NSString variable to hold the type label
 */
@property (nonatomic, strong) NSString  *typeLabel;

@end
