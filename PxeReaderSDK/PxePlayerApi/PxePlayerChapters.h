//
//  PxePlayerChapters.h
//  PxePlayerApi
//
//  Created by Saro Bear on 17/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the chapters data into the model
 */
@interface PxePlayerChapters : NSObject <NSCoding>

/**
 A NSMutableArray variable to hold the list of chapter models 
 */
@property (nonatomic, strong) NSMutableArray *chapters;

@end
