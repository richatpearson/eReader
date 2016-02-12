//
//  NTBookShelf.h
//  NTApi
//
//  Created by Swamy Manju R on 02/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the book shelf data into the model
 */
@interface PxePlayerBookShelf : NSObject

/**
 A NSMutableArray variable to hold the list of book model
 */
@property(nonatomic,strong) NSMutableArray * books;

@end
