//
//  PxePlayerLabelProvider.m
//  PxeReader
//
//  Created by Tomack, Barry on 7/21/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayerLabelProvider.h"

@implementation PxePlayerLabelProvider

- (instancetype) initWithDelegate:(id <PxePlayerLabelProviderDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
    }
    return self;
}

- (NSString*) getLabelForPageWithPath:(NSString *)relativePath
{
    NSString *label;
    
    label = [self.delegate provideLabelForPageWithPath:relativePath];
    
    return label;
}

@end
