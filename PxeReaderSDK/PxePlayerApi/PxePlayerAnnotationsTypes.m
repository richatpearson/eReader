//
//  PxePlayerAnnotationsTypes.m
//  PxePlayerApi
//
//  Created by Barry Tomack.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerAnnotationsTypes.h"
#import "PxePlayerAnnotations.h"
#import "PXEPlayerMacro.h"

@implementation PxePlayerAnnotationsTypes

-(id)init
{
    self = [super init];
    if(self)
    {
        self.sharedAnnotationsArray = [NSArray new];
    }
    return self;
}

- (PxePlayerAnnotations *) combinedAnnotationsByURI
{
    PxePlayerAnnotations *pxePlayerAnnotations = [PxePlayerAnnotations new];
    
    NSMutableDictionary *annotations = [NSMutableDictionary new];
    if (self.myAnnotations)
    {
        [annotations addEntriesFromDictionary:self.myAnnotations.contentsAnnotations];
    }
    DLog(@"self.myAnnotations Annotations: %@", annotations);
    for (PxePlayerAnnotations *sharedAnnotations in self.sharedAnnotationsArray)
    {
        if (sharedAnnotations)
        {
            for (NSString *key in sharedAnnotations.contentsAnnotations)
            {
                DLog(@"SharedAnnotations key: %@", key);
                if ([[annotations allKeys] containsObject:key])
                {
                    DLog(@".......KEY EXISTS");
                    // Need to add annotation objects to existing array
                    NSMutableArray *annotationsArray = [[annotations objectForKey:key] mutableCopy];
                    NSArray *annotationsForKey = [sharedAnnotations.contentsAnnotations objectForKey:key];
                    for (PxePlayerAnnotation *pxePlayerAnnotation in annotationsForKey)
                    {
                        DLog(@"adding Annotation: %@ for Key:%@", pxePlayerAnnotation,key);
                        [annotationsArray addObject:pxePlayerAnnotation];
                    }
                    [annotations setObject:annotationsArray forKey:key];
                } else {
                    DLog(@".......KEY DOES NOT EXIST");
                    //[annotations addEntriesFromDictionary:sharedAnnotations.contentsAnnotations];
                    [annotations setObject:[sharedAnnotations.contentsAnnotations objectForKey:key] forKey:key];
                }
            }
        }
    }
    DLog(@"Annotations: %@", annotations);
    pxePlayerAnnotations.contentsAnnotations = annotations;
    
    return pxePlayerAnnotations;
}

- (PxePlayerAnnotations *) combinedAnnotationsByColor
{
    PxePlayerAnnotations *pxePlayerAnnotations = [PxePlayerAnnotations new];
    
    NSMutableDictionary *annotations = [NSMutableDictionary new];
    if (self.myAnnotations)
    {
        [annotations addEntriesFromDictionary:self.myAnnotations.contentsAnnotationsByColor];
    }
    for (PxePlayerAnnotations *sharedAnnotations in self.sharedAnnotationsArray)
    {
        if (sharedAnnotations)
        {
            [annotations addEntriesFromDictionary:sharedAnnotations.contentsAnnotationsByColor];
        }
    }
    
    pxePlayerAnnotations.contentsAnnotations = annotations;
    
    return pxePlayerAnnotations;
}

- (NSString*) description
{
    NSMutableString *notesDesc = [NSMutableString stringWithString:@"\nPxePlayerAnnotationsTypes: \n"];
    
    [notesDesc appendFormat:@"   myAnnotations: %@ \n", self.myAnnotations];
    if ([self.sharedAnnotationsArray count] > 0)
    {
        for (PxePlayerAnnotations *sharedAnnotations in self.sharedAnnotationsArray)
        {
            [notesDesc appendFormat:@"   sharedAnnotations: %@ \n", sharedAnnotations];
        }
    }
    
    return notesDesc;
}

- (NSString *) asJSONString
{
    NSMutableString *jsonString = [NSMutableString new];
    
    [jsonString appendFormat:@"{"];
    
    if([self.myAnnotations.contentsAnnotations count] > 0)
    {
        [jsonString appendFormat:@"\"myContentsAnnotations\":{"];
        [jsonString appendString:[self.myAnnotations asJSONString]];
        [jsonString appendFormat:@"}"];
    }
    if ([self.sharedAnnotationsArray count] > 0)
    {
        [jsonString appendFormat:@"\"sharedContentsAnnotations\":[{"];
        
        NSInteger cnt = 0;
        for (PxePlayerAnnotations *pxePlayerAnnotations in self.sharedAnnotationsArray)
        {
            [jsonString appendString:[pxePlayerAnnotations asJSONString]];
            cnt++;
            if ([self.sharedAnnotationsArray count] > cnt)
            {
                [jsonString appendFormat:@","];
            }
        }
        [jsonString appendFormat:@"}]"];
    }
    
    [jsonString appendFormat:@"}"];
    DLog(@"jsonString: %@", jsonString);
    return jsonString;
}

- (NSString *) asSerializedJSONString
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary new];
    
    if(self.myAnnotations)
    {
        [jsonDict setObject:[self.myAnnotations asDictionaryForJSON] forKey:@"myContentsAnnotations"];
    }
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
    // NSASCIIStringEncoding, NSUTF8StringEncoding dont' work when passing string to Javascript
    return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}

@end