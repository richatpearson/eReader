//
//  PxePlayerDeleteBookmarkQuery.h
//  PxeReader
//
//  Created by Satyanarayana SVV on 10/31/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerNavigationsQuery.h"

/**
 A simple class to parse the delete bookmark query 
 */
@interface PxePlayerDeleteBookmarkQuery : PxePlayerNavigationsQuery

/**
 A NSString variable to hold the content id
 */
@property (nonatomic, strong) NSString* contentID;

@end
