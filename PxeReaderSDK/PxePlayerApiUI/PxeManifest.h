//
//  PxeManifest.h
//  PxeReader
//
//  Created by Tomack, Barry on 7/15/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeContext, PxeManifestChunk;

@interface PxeManifest : NSManagedObject

@property (nonatomic, retain) NSString * base_url;
@property (nonatomic, retain) NSString * checksum;
@property (nonatomic, retain) NSString * external_context_id;
@property (nonatomic, retain) NSString * src;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * total_size;
@property (nonatomic, retain) NSSet *chunks;
@property (nonatomic, retain) PxeContext *context;
@end

@interface PxeManifest (CoreDataGeneratedAccessors)

- (void)addChunksObject:(PxeManifestChunk *)value;
- (void)removeChunksObject:(PxeManifestChunk *)value;
- (void)addChunks:(NSSet *)values;
- (void)removeChunks:(NSSet *)values;

@end
