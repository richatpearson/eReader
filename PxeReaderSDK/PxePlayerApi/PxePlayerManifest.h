//
//  PxePlayerManifest.h
//  PxeReader
//
//  Created by Richard Rosiak on 6/26/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PxePlayerManifest : NSObject

@property (nonatomic, assign) NSNumber *totalSize;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *epubFileName;
@property (nonatomic, strong) NSString *bookTitle;
@property (nonatomic, strong) NSString *contextId;
@property (nonatomic, strong) NSString *fullUrl;

@property (nonatomic, strong) NSArray *items;

@end
