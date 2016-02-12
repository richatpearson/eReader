//
//  PxeManifest.m
//  PxeReader
//
//  Created by Tomack, Barry on 7/15/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxeManifest.h"
#import "PxeContext.h"
#import "PxeManifestChunk.h"


@implementation PxeManifest

@dynamic base_url;
@dynamic checksum;
@dynamic external_context_id;
@dynamic src;
@dynamic title;
@dynamic total_size;
@dynamic chunks;
@dynamic context;

@end
