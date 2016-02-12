//
//  PxePlayerTOCItem.h
//  Sample
//
//  Created by Satyanarayana SVV on 10/28/13.
//  Copyright (c) 2013 Satyam. All rights reserved.
//
#import <Foundation/Foundation.h>


/**
 A simple class to handle the array of toc entries parsed from the URL or file.
 */
@interface PxePlayerToc : NSObject <NSCoding>

/**
 A NSString variable to hold the array of toc entries
 */
@property (nonatomic, strong) id tocEntries;

@property (nonatomic, strong) id customBaskets;

@end
