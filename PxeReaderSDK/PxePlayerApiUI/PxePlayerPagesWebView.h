//
//  NTPagesWebView.h
//  NTApi
//
//  Created by Saro Bear on 10/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerNotesHighlightsDelegate.h"
#import "PxePlayerNoteView.h"
#import "PXEPlayerMenuControllerManager.h"

/**
 Class to render a page web view
 */

@interface PxePlayerPagesWebView : UIWebView <PxePlayerNoteViewDelegate>

@property (nonatomic, strong) PXEPlayerMenuControllerManager *menuControllerManager;
@property (nonatomic, assign) CGRect baseMenuPosition;
@property (nonatomic, strong) PxePlayerNoteView *noteView;
@property (nonatomic, strong) PxePlayerAnnotation *currentAnnotation; //may not need it here...
@property (nonatomic, assign) CGPoint singleTapLocation;

@property (nonatomic, assign) BOOL shouldOpenNoteView;
@property (nonatomic, assign) BOOL isAnnotationNew;
@property (nonatomic, assign) BOOL isNoteViewOpen;

/**
 This method creates the UIWebView instance with custom frame and content auto fit option
 @param CGRect, frame is the custom frame for web view 
 @param BOOL, scalePageToFit is the boolean value to enable/disable auto fit in the UIWebView
 @return id, returns the UIWebView instance created with given properties
 */
- (id) initWithFrame:(CGRect)frame withScalePageToFit:(BOOL)scalePageToFit;

- (void) updateNote:(NSString*)jsonString;
//- (void) createNotesAndHighlightsMenu:(NSString*)message event:(NSString*)event;
- (void) respondToAnnotationDataWithMessage:(NSString*)message event:(NSString*)event;
- (void) removeOrientationChangeObserver;
- (void) disableUserSelection;

@end
