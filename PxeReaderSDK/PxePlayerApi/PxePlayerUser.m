//
//  NTUser.m
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerUser.h"

@implementation PxePlayerUser

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    
    return self;
}

-(void)dealloc
{
    self.identityId = nil;
    self.authToken = nil;
}

- (NSString *)description
{
    NSMutableString *userDesc = [NSMutableString stringWithString:@"PxePlayerUser: \n"];
    [userDesc appendFormat:@"   identityId: %@ \n", self.identityId];
    [userDesc appendFormat:@"   authToken: %@ \n", self.authToken];
    
    return userDesc;
}

@end




