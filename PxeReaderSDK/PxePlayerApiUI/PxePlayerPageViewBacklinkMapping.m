//
//  PxePlayerPageViewBacklinkMapping.m
//  PxeReader
//
//  Created by Tomack, Barry on 5/29/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayerPageViewBacklinkMapping.h"

@implementation PxePlayerPageViewBacklinkMapping

- (NSString*) description
{
    NSMutableString *dataDesc = [NSMutableString stringWithString:@"PxePlayerPageViewBacklinkMapping: \n"];
    [dataDesc appendFormat:@"   backlinkCSVMappings: %@ \n", self.backlinkCSVMappings];
    [dataDesc appendFormat:@"   backlinkLaunchParams: %@ \n", self.backlinkLaunchParams];
    [dataDesc appendFormat:@"   backlinkEndpointMapping: %@ \n", self.backlinkEndpointMapping];
    [dataDesc appendFormat:@"   backlinkSignatureEndpoint: %@ \n", self.backlinkSignatureEndpoint];
    
    return dataDesc;
}

@end
