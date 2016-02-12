//
//  PxePlayerAddNoteQuery.h
//  PxePlayerApi
//
//  Created by Saro Bear on 30/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerNotesQuery.h"

/**
 A simple class derived from the PxePlayerNotesQuery to parse the add note query into the model
 */
@interface PxePlayerAddNoteQuery : PxePlayerNotesQuery

/**
 A NSString variable to hold the role type id
 */
@property (nonatomic, strong) NSNumber  *roleTypeId;

/**
 A NSNumber variable to hold the note start position
 */
@property (nonatomic, strong) NSNumber  *noteStartPos;

/**
 A NSNumber variable to hold the note end position
 */
@property (nonatomic, strong) NSNumber  *noteEndPos;

/**
 A NSString variable to hold the note text
 */
@property (nonatomic, strong) NSString  *note;

@end
