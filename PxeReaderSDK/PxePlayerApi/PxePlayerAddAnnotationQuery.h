//
//  PxePlayerAddAnnotation.h
//  PxeReader
//
//  Created by Saro Bear on 07/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PxePlayerNavigationsQuery.h"

/**
 A simple class derived from the PxePlayerNavigationsQuery to parse the query into the model
 */
@interface PxePlayerAddAnnotationQuery : PxePlayerNavigationsQuery

/**
 A NSString variable to hold the content id
 */
@property (nonatomic, strong) NSString          *contentId;

/**
 A NSMutableArray variable to hold the list of annotations 
 */
@property (nonatomic, strong) NSMutableArray    *annotations;

@end
