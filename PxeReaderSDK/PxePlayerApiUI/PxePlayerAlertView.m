//
//  PxePlayerAlertView.m
//  PxePlayerApi
//
//  Created by Saro Bear on 27/08/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerAlertView.h"

@interface PxePlayerAlertView ()

@property (nonatomic, strong) NSMutableDictionary *values;

@end


@implementation PxePlayerAlertView

-(void)addCustomValue:(NSString*)value withKey:(NSString*)key
{
    if(!self.values)
    {
        self.values = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    if(key)
    {
        [self.values setObject:value forKey:key];
    }
}

-(void)removeCustomValue:(NSString*)key
{
    if(self.values){
        [self.values removeObjectForKey:key];
    }
}

-(NSString*)getCustomValue:(NSString*)key
{
    if(!self.values) return nil;
    
    return [self.values valueForKey:key];
}

-(void)dealloc
{
    self.values = nil;
}

@end
