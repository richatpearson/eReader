//
//  PxePlayerSearchPages.h
//  PxePlayerApi
//
//  Created by Saro Bear on 11/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to handle the searched pages content
 */
@interface PxePlayerSearchPages : NSObject

/**
 A NSInteger variable to hold the total pages count per download
 */
@property (nonatomic, assign) NSInteger         totalPages;

/**
 A NSInteger variable to hold the total results fetched
 */
@property (nonatomic, assign) NSInteger         totalResults;

/**
 A NSMutableArray variable to hold the string or model of searched items
 */
@property (nonatomic, strong) NSMutableArray    *searchedItems;

/**
 A NSArray variable to hold the highlights labels 
 */
@property (nonatomic, strong) NSArray          *labels;

@end
