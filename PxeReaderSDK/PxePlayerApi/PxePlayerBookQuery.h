//
//  NTBookQuery.h
//  NTApi
//
//  Created by Saro Bear on 04/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerBaseQuery.h"

/**
 A simple class to parse the book query into the model
 */
@interface PxePlayerBookQuery : PxePlayerBaseQuery

/**
 A NSNumber variable to hold the scenario id
 */
@property (nonatomic, strong) NSNumber  *scenarioID;

@end
