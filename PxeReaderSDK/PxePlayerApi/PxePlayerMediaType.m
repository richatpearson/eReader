//
//  PxePlayerMediaType.m
//  PxePlayerApi
//
//  Created by Saro Bear on 17/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerMediaType.h"

@implementation PxePlayerMediaType

#pragma mark - Self methods

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(void)dealloc
{
    self.type = nil;
    self.typeLabel = nil;

}

@end
