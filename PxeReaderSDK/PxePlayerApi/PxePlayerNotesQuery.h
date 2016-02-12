//
//  PxePlayerNotesQuery.h
//  PxePlayerApi
//
//  Created by Swamy Manju R on 18/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerNavigationsQuery.h"

/**
 A simple class to parse the notes query
 */
@interface PxePlayerNotesQuery : PxePlayerNavigationsQuery

/**
 A NSString variable to hold the content id
 */
@property (nonatomic, strong) NSString  *contentId;

/**
 A NSString variable to hold the page UUID
 */
@property (nonatomic, strong) NSString  *pageUUID;

@end
