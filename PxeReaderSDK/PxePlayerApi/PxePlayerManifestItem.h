//
//  PxePlayerManifestItem.h
//  PxeReader
//
//  Created by Richard Rosiak on 6/26/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PxePlayerManifestItem : NSObject

@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSString *assetId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *epubFileName;
@property (nonatomic, assign) BOOL isDownloaded;

@property (nonatomic, strong) NSString *fullUrl;

@end
