//
//  PxePlayerContentAnnotationsQuery.h
//  PxeReader
//
//  Created by Satyanarayana SVV on 11/6/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerNavigationsQuery.h"

/**
 A simple class to parse content annotations query
 */
@interface PxePlayerContentAnnotationsQuery : PxePlayerNavigationsQuery

/**
 A NSString variable to hold the content id 
 */
@property (nonatomic, strong) NSString* contentID;

@end
