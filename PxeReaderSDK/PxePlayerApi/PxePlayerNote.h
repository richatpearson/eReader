//
//  PxePlayerNote.h
//  PxePlayerApi
//
//  Created by Saro Bear on 08/08/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the note
 */
@interface PxePlayerNote : NSObject

/**
 A NSNumber variable to hold the role type id
 */
@property (nonatomic, strong) NSNumber  *roleTypeId;

/**
 A NSNumber variable to hold the page number
 */
@property (nonatomic, strong) NSNumber  *pageNumber;

/**
 A NSString variable to hold the page id
 */
@property (nonatomic, strong) NSString  *pageId;

/**
 A NSString variable to hold the note id
 */
@property (nonatomic, strong) NSString  *noteId;

/**
 A NSString variable to hold the note text 
 */
@property (nonatomic, strong) NSString  *note;

@end
