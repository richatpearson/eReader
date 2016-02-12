//
//  PxePlayerAddAnnotation.m
//  PxeReader
//
//  Created by Saro Bear on 07/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerAddAnnotationQuery.h"

@implementation PxePlayerAddAnnotationQuery

-(id)init
{
    self = [super init];
    if(self) {
        self.annotations = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

-(void)dealloc
{
    self.annotations  = nil;
    self.contentId = nil;
}

@end
