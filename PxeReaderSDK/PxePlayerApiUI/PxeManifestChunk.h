//
//  PxeManifestChunk.h
//  PxeReader
//
//  Created by Tomack, Barry on 7/15/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeManifest;

@interface PxeManifestChunk : NSManagedObject

@property (nonatomic, retain) NSString * base_url;
@property (nonatomic, retain) NSString * checksum;
@property (nonatomic, retain) NSString * chunk_id;
@property (nonatomic, retain) NSNumber * is_downloaded;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * src;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) PxeManifest *manifest;

@end
