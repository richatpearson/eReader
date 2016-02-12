//
//  PxePlayerAnnotations.m
//  PxeReader
//
//  Created by Saro Bear on 07/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerAnnotations.h"
#import "PxePlayerAnnotation.h"
#import "PXEPlayerMacro.h"

@implementation PxePlayerAnnotations

-(id)init
{
    self = [super init];
    if(self)
    {
        self.contentsAnnotations = [NSMutableDictionary new];
    }
    return self;
}

-(void)dealloc
{
    self.contentsAnnotations = nil;
}

- (void) setAnnotation:(PxePlayerAnnotation*)pxePlayerAnnotation forURI:(NSString*)uri
{
    NSMutableArray *annotationArray = [self.contentsAnnotations objectForKey:uri];
    if (!annotationArray)
    {
        annotationArray = [NSMutableArray new];
    }
    [annotationArray addObject:pxePlayerAnnotation];
    
    [self.contentsAnnotations setObject:annotationArray forKey:uri];
}

- (NSDictionary *) contentsAnnotationsByColor
{
    NSMutableDictionary *contentsByColor = [NSMutableDictionary new];
    
    for (NSString *key in self.contentsAnnotations)
    {
        NSArray *annotationArray = [self.contentsAnnotations objectForKey:key];
        
        for (PxePlayerAnnotation *pxePlayerAnnotation in annotationArray)
        {
            NSString *colorKey = pxePlayerAnnotation.colorCode;
            NSMutableArray *annotationsByColor = [contentsByColor objectForKey:colorKey];
            if (!annotationsByColor)
            {
                annotationsByColor = [NSMutableArray new];
            }
            [annotationsByColor addObject:pxePlayerAnnotation];
            
            [contentsByColor setObject:annotationsByColor forKey:colorKey];
        }
    }
    
    return contentsByColor;
}

- (NSString *) description
{
    NSMutableString *annotationsDesc = [NSMutableString stringWithString:@"PxePlayerAnnotations: \n"];
    [annotationsDesc appendFormat:@"   isMyAnnotations: %@ \n", self.isMyAnnotations?@"YES":@"NO"];
    [annotationsDesc appendFormat:@"   annotationsIdentityId: %@ \n", self.annotationsIdentityId];
    [annotationsDesc appendFormat:@"   contextId: %@ \n", self.contextId];
    [annotationsDesc appendFormat:@"   contentsAnnotations: \n%@ \n", self.contentsAnnotations];
    
    return annotationsDesc;
}


- (NSString *) asJSONString
{
    NSMutableString *jsonString = [NSMutableString new];
    
    [jsonString appendFormat:@"\"contextId\":\"%@\",", self.contextId];
    [jsonString appendFormat:@"\"identityId\":\"%@\",", self.annotationsIdentityId];
    [jsonString appendFormat:@"\"contentsAnnotations\":%@", [self contentsAnnotationsAsJSONString]];
    return jsonString;
}

- (NSString*) contentsAnnotationsAsJSONString
{
    NSMutableString *jsonString = [NSMutableString new];
    
    [jsonString appendFormat:@"{"];
    
    for (NSString *key in self.contentsAnnotations)
    {
        [jsonString appendFormat:@"\"%@\":{", key];
        
        // annotations array - Begin
        [jsonString appendFormat:@"\"annotations\":["];
        
        NSArray *annotations = [self.contentsAnnotations objectForKey:key];
        if ([annotations count] > 0)
        {
            [jsonString appendFormat:@"%@", [self annotationsArrayAsJSONString:annotations]];
        }
        
        [jsonString appendFormat:@"],"];
        // annotations array - End
        
        [jsonString appendFormat:@"\"uri\":\"%@\"", key];
        [jsonString appendFormat:@"}"];
    }
    
    [jsonString appendFormat:@"}"];
    
    return jsonString;
}

- (NSString*) annotationsArrayAsJSONString:(NSArray*)annotations
{
    NSMutableString *jsonString = [NSMutableString new];
    NSInteger cnt = 0;
    for (PxePlayerAnnotation *annotation in annotations)
    {
        [jsonString appendFormat:@"%@",[annotation asJSONString]];
        cnt++;
        if ([annotations count] > cnt)
        {
            [jsonString appendFormat:@","];
        }
    }
    
    return jsonString;
}

- (NSDictionary *) asDictionaryForJSON
{
    NSDictionary *jsonDictionary = @{
                                     @"contextId":self.contextId,
                                     @"identityId":self.annotationsIdentityId,
                                     @"contentsAnnotations":[self contentsAnnotationsAsDictionary]
                                     };
    return jsonDictionary;
}

- (NSDictionary *) contentsAnnotationsAsDictionary
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary new];
    
    for (NSString *key in self.contentsAnnotations)
    {
        [jsonDict setObject:key forKey:@"uri"];
        
        NSArray *annotations = [self annotationsArrayForJSON:[self.contentsAnnotations objectForKey:key]];
        
        [jsonDict setObject:annotations forKey:@"annotations"];
    }
    
    return jsonDict;
}

- (NSArray *) annotationsArrayForJSON:(NSArray*)annotationsAR
{
    NSMutableArray *jsonArray = [NSMutableArray new];
    
    for (PxePlayerAnnotation *annotation in annotationsAR)
    {
        [jsonArray addObject:[annotation asDictionaryForJSON]];
    }
    
    return jsonArray;
}

@end