//
//  PxePlayerNoteDeleteQuery.h
//  PxePlayerApi
//
//  Created by Saro Bear on 30/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerNotesQuery.h"

/**
 A simple class to parse the note delete query
 */
@interface PxePlayerNoteDeleteQuery : PxePlayerNotesQuery

/**
 A NSString variable to hold the annotation definition
 */
@property (nonatomic, strong) NSString  *annotationDttm;

@end
