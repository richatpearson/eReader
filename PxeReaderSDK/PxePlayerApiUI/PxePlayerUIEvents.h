//
//  PxePlayerUIEvents.h
//  PxeReader
//
//  Created by Tomack, Barry on 11/6/14.
//  Copyright (c) 2014 Pearson, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PxePlayerUIEvents : NSObject

/**
 
 */
extern NSString* const PXE_UIError;
/**
 
 */
extern NSString* const PXE_AnnotationAdd;

/**
 
 */
extern NSString* const PXE_AnnotationData;

/**
 
 */
extern NSString* const PXE_AnnotationLoad;

/**
 
 */
extern NSString* const PXE_AnnotationFailure;

/**
 
 */
extern NSString* const PXE_GlossaryData;

/**
 
 */
extern NSString* const PXE_WidgetEvent;

/**
 
 */
extern NSString* const PXE_NotebookEvent;

/**
 
 */
extern NSString* const PXE_PageClickEvent;

/**
 
 */
extern NSString* const PXE_ContentStartedScrolling;

/**
 
 */
extern NSString* const PXE_ContentStoppedScrolling;

/**
 
 */
extern NSString* const PXE_ContentScrolling;

/**
 
 */
extern NSString* const PXE_Navigation;

@end
