//
//  PxePlayerAnnotationsTypes.h
//  PxePlayerApi
//
//  Created by Barry Tomack.
//  Copyright (c) 2015 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

@class PxePlayerAnnotations;

/**
 A simple class to parse the notes
 */
@interface PxePlayerAnnotationsTypes : NSObject

/**
 A PxePlayerAnnotations object to hold myContentsAnnotations (from JSON
 */
@property (nonatomic, strong) PxePlayerAnnotations *myAnnotations;

/**
 An array of PxePlayerAnnotations objects to hold sharedContentsAnnotations (from JSON)
 */
@property (nonatomic, strong) NSArray *sharedAnnotationsArray;

/**
 
 */
- (PxePlayerAnnotations *) combinedAnnotationsByURI;

/**
 
 */
- (PxePlayerAnnotations *) combinedAnnotationsByColor;

/**
 
 */
- (NSString *) asJSONString;

/**
 
 */
- (NSString *) asSerializedJSONString;

@end