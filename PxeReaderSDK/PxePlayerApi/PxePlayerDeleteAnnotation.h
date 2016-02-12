//
//  PxePlayerDeleteAnnotation.h
//  PxeReader
//
//  Created by Saro Bear on 07/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple class to parse the delete annotation
 */
@interface PxePlayerDeleteAnnotation : NSObject

/**
 A NSString variable to hold the context id
 */
@property (nonatomic, strong) NSString  *contextId;

/**
 A NSString variable to hold the identity id
 */
@property (nonatomic, strong) NSString  *identityId;

/**
 A NSString variable to hold the content id
 */
@property (nonatomic, strong) NSString  *contentId;

/**
 A NSString variable to hold the annotation description
 */
@property (nonatomic, strong) NSString  *annotationDttm;

@end
