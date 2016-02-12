//
//  PxePlayerAnnotations.h
//  PxeReader
//
//  Created by Saro Bear on 07/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PxePlayerAnnotation;

/**
 A simple class to parse the annotation data into the list of models
 */
@interface PxePlayerAnnotations : NSObject

/**
 A BOOL variable to indicate if it is myContentsAnnotations or sharedContentsAnnotations
 */
@property (nonatomic, assign) BOOL                  isMyAnnotations;

/**
 A NSDictionary variable keyed by uri with values as arrays of annotation objects
 */
@property (nonatomic, strong) NSMutableDictionary   *contentsAnnotations;

/**
 
 */
@property (nonatomic, strong) NSString              *annotationsIdentityId;

/**
 
 */
@property (nonatomic, strong) NSString              *contextId;

/**
 Adds a PxePlayerAnnotation to a mutable array which is a value for the uri key
 in the contentsAnnotations mutable dictionary property.
 */
- (void) setAnnotation:(PxePlayerAnnotation*)pxePlayerAnnotation forURI:(NSString*)uri;

/**
 
 */
- (NSDictionary *) contentsAnnotationsByColor;

/**
 
 */
- (NSString *) asJSONString;

/**
 
 */
- (NSDictionary *) asDictionaryForJSON;

@end