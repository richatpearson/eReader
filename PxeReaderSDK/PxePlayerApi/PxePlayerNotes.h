//
//  PxePlayerNotes.h
//  PxePlayerApi
//
//  Created by Saro Bear on 30/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the notes
 */
@interface PxePlayerNotes : NSObject

/**
 A NSDictionary variable to hold the user notes data
 */
@property (nonatomic, strong) NSDictionary *userNotesDic;

/**
 A NSDictionary variable to hold the shared notes data 
 */
@property (nonatomic, strong) NSDictionary *sharedNotesDic;

@end
