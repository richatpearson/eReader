//
//  PxePlayerPageViewBacklinkMapping.h
//  PxeReader
//
//  Created by Tomack, Barry on 5/29/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PxePlayerPageViewBacklinkMapping : NSObject

@property (nonatomic, retain) NSString *backlinkCSVMappings;
@property (nonatomic, retain) NSString *backlinkLaunchParams;
@property (nonatomic, retain) NSString *backlinkEndpointMapping;
@property (nonatomic, retain) NSString *backlinkSignatureEndpoint;

@end
