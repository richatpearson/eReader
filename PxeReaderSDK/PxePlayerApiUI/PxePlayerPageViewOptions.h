//
//  PxePlayerPageViewOptions.h
//  PxeReader
//
//  Created by Tomack, Barry on 10/24/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PxePlayerPageViewBacklinkMapping.h"
#import "PxePlayerLabelProvider.h"

@interface PxePlayerPageViewOptions : NSObject

/**
 Enable/Disable page swipe to navigation option.
 */
@property (nonatomic, assign) BOOL shouldAllowPageSwipe;

/**
 Option to set the transition style of the UIPageViewContoller
 */
@property (nonatomic, assign) NSUInteger transitionStyle;;

/**
 Option to customize the page WebView scale content to fit
 @see UIWebView , scalePageContentToFit
 */
@property (nonatomic, assign) BOOL scalePage;

/**
 Options for backlinking (linking back to an app or web app that launched you)
 */
@property (nonatomic, retain) PxePlayerPageViewBacklinkMapping *backlinkMapping;

/**
 The following properties are in the process of being migrated to here from the PxePlayerDataInterface
 */

/**

 Tells PXE to use default font and theme settings at start (in case no settings are provided). Default is YES.
 If set to NO, PXE will not pass any values to Javascript.
 */
@property (nonatomic, assign) BOOL useDefaultFontAndTheme;

/**
 A BOOL that will set the shareble flag for notes and annotations - Can be moved to PageViewOptions
 */
@property (nonatomic,readwrite) BOOL annotationsSharable;

/**
 A BOOL that will set the mathML to be used or not
 */
@property (nonatomic,readwrite) BOOL enableMathML;

/**
 A BOOL that indicates whether Print Page display is supported
 */
@property (nonatomic,readwrite) BOOL printPageSupport;

/**
 Meant for disabling horizontal scroll in web view so that there are no conflicts with
 page swiping. Rejected by eText. Not used in current PXE (eRPS)
 */
@property (nonatomic, assign) BOOL disableHorizontalScrolling;

/**
 An optional object through which a client applications can provide custom labels for annotations and bookmarks
 */
@property (nonatomic,readwrite) PxePlayerLabelProvider *labelProvider;

/**
 A BOOL that determines if we are able to show annotation pop up menu
 */
@property (nonatomic,readwrite) BOOL showAnnotate;

/**
 A NSString variable to hold the book page theme
 */
@property (nonatomic, strong, getter=bookPageTheme, setter=setBookPageTheme:) NSString *bookTheme;

/**
 A NSInteger variable to hold the book page font size
 */
@property (nonatomic, assign, getter=bookPageFontSize, setter=setBookPageFontSize:) NSInteger fontSize;

#pragma mark Host White List - array of known hosts whos served content must appear inline (embedded)
/**
 
 */
- (NSMutableArray*) addHostToWhiteList:(NSString*)host;

/**
 
 */
- (NSMutableArray*) addHostArrayToWhiteList:(NSArray*)hostArray;

/**
 
 */
- (NSMutableArray*) hostWhiteList;

#pragma mark Host External List - array of known hosts whos content must appear externally in Safari
/**
 
 */
- (NSMutableArray*) addHostToExternalList:(NSString*)host;

/**
 
 */
- (NSMutableArray*) addHostArrayToExternalList:(NSArray*)hostArray;

/**
 
 */
- (NSMutableArray*) hostExternalList;

@end
