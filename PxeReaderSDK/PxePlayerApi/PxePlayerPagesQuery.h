//
//  NTPagesQuery.h
//  NTApi
//
//  Created by Saro Bear on 04/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerNavigationsQuery.h"

/**
 A simple class to parse the pages query data
 */
@interface PxePlayerPagesQuery : PxePlayerNavigationsQuery

/**
 A NSString variable to hold the chapters UUID
 */
@property (nonatomic, strong) NSString  *chaptersUUID;

/**
 A NSString variable to hold the pages UUID
 */
@property (nonatomic, strong) NSString  *pagesUUID;

/**
 A NSString variable to hold the page URL 
 */
@property (nonatomic, strong) NSString  *pageUrl;

@end
