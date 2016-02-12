//
//  PxePlayerPageViewController.h
//  PxePlayerApi
//
//  Created by Saro Bear on 26/10/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAI.h"
#import "GAIFields.h"

#import "PxePlayerLightBoxViewController.h"
#import "PXEPlayerMoreInfoViewController.h"
#import "PxePlayerDataInterface.h"
#import "PxePlayerAnnotation.h"

@class PxePlayerPageViewOptions;
@class PxePlayerLabelProvider;

#pragma mark - Delegates

/**
  A Protocol to which send's the page view's few properties present status
  @Extension <NSObject>, extented from NSObject
 */
@protocol PxePlayerPageViewDelegate <NSObject>

@optional
/**
  Sends the page view's UI updates
  @param hasPrevious, page has reached first page or not 
  @param hasNext, page has reached last page or not
  @param pageNumber, current page number
 */
-(void)updatePageViewUI:(BOOL)hasPrevious orLastPage:(BOOL)hasNext andPageNumber:(NSNumber*)pageNumber;

/**
 
 */
- (void) cleanPageViewContent;

@end


#pragma mark - Classes

/**
   Class to display a book pages navigation .
 */

@interface PxePlayerPageViewController : UIViewController <PxePlayerLightboxDelegate , PXEPlayerMoreInfoDelegate>


/**
  Delegate instance which external class can communicate to the self class.
  @see PxePlayerPageViewDelegate
 */
@property (nonatomic, weak) id  <PxePlayerPageViewDelegate> delegate;

# pragma mark Initialization

/**
  Instantiate the class with preloaded information to customize the page navigation. 
  @param id, masterdata to be either NSArray of page URL's or NSString of NCX file URL 
  @param NSArray, custompages should be array of pageURL's should be collected from primary NCX data and user allowed to navigate only given page URL's.
  @see initWithURL:andCustomPlaylistURLs:withOptions:
  @see initWithURL:andCustomPlaylistURLs:andGotoPage:withOptions:
 */
- (id) initWithDataInterface:(PxePlayerDataInterface*)dataInterface
          customPlaylistURLs:(NSArray*)custompages;

/**
  Instantiate the class with preloaded information to customize the page navigation.
  @param id, masterdata to be either NSArray of page URL's or NSString of NCX file URL
  @param NSArray, custompages should be array of pageURL's should be collected from primary NCX data and user allowed to navigate only given page URL's.
  @param NSDictionary, options allows the UI customisation
  @see initWithURL:andCustomPlaylistURLs:
  @see initWithURL:andCustomPlaylistURLs:andGotoPage:withOptions:
 */
- (id) initWithDataInterface:(PxePlayerDataInterface*)dataInterface
          customPlaylistURLs:(NSArray*)custompages
                 withOptions:(PxePlayerPageViewOptions*)options;

/**
  Instantiate the class with preloaded information to customize the page navigation.
  @param id, masterdata to be either NSArray of page URL's or NSString of NCX file URL
  @param NSArray, custompages should be array of pageURL's should be collected from primary NCX data and user allowed to navigate only given page URL's.
  @param NSString, page should be either any book pageURL or pageID to start reading from the launch.
  @param NSDictionary, options allows the UI customisation
  @see initWithURL:andCustomPlaylistURLs:
  @see initWithURL:andCustomPlaylistURLs:withOptions:
 */
- (id) initWithDataInterface:(PxePlayerDataInterface*)dataInterface
          customPlaylistURLs:(NSArray*)custompages
                 andGotoPage:(NSString*)page
                 withOptions:(PxePlayerPageViewOptions*)options;

# pragma mark Navigation

/**
  Navigate page from left to right or vice versa
  @param BOOL, isLeft is true page navigate backword else forward
 */
- (BOOL) scrollPageToDirection:(BOOL)isLeft;

/**
 
 */
- (BOOL) scrollPageToDirection:(BOOL)isLeft error:(NSError**)error;

/**
  Navigate to the particular page by using pageId
  @param NSString, pageId is a reference to jump to the particular page
 */
-(void)gotoPageWithContentID:(NSString*)pageId;

/**
  Navigate to the particular page by using pageURL
  @param NSString, pageUrl is a reference to jump to the particular page
 */
-(void)gotoPageWithPageURL:(NSString*)pageUrl __attribute((deprecated("use gotoPageWithPageURL:error: instead")));

- (BOOL) gotoPageWithPageURL:(NSString*)pageUrl error:(NSError**)error;

/**
  Navigate to the particular page by using pageUrl and should show the highlights in the page
  @param NSString, pageUrl is a reference to jump to the particular page
  @param NSArray, labels is references of higlights area in the page
 */
-(void)gotoPageWithPageURL:(NSString *)pageUrl andHighlightLabels:(NSArray*)labels __attribute((deprecated("use gotoPageWithPageURL:andHighlightLabels:error: instead")));

/**
 
 */
- (BOOL) gotoPageWithPageURL:(NSString *)pageUrl andHighlightLabels:(NSArray*)labels error:(NSError**)error;

/**
  Navigate to the particular page by using pageURL and navigate further within a page using pageId
  @param NSString, pageId is a reference to jump to the title with in a particular page
  @param NSString, pageUrl is a reference to jump to the particular page
 */
-(void)gotoPageWithPageId:(NSString*)pageId withURL:(NSString*)pageURL;

/**
  Navigate to the particular page by using pageNumber
  @param NSString, pageNumber is a reference to jump to the particular page
 */
-(void)jumpToPage:(NSNumber*)pageNumber;

/**
 Navigating to a print page by print page number
 @param NSString, print page number the client wants to navigate to
 */
- (void) jumpToPrintPage:(NSString*)printPageNumber;

- (void) jumpToPrintPage:(NSString*)printPageNumber onComplete:(void (^)(BOOL success, NSNumber *digitalPage, NSString *pageURL))handler;

/**
 Navigating to annotation by page url and then scrolling to annotation highlight
 */
- (void) jumpToAnnotation:(PxePlayerAnnotation*)annotation;

# pragma mark Getters and Setters

/**
 Returns the current page title from the page manager (PxePlayerPageManager)
 @return NSString, current title
 */
- (NSString*) getCurrentPageTitle;

/**
 
 */
- (NSString*) getCurrentPageId;

/*
 Called when annotations should be toggled
 @param BOOL, yes or no
 */
-(void)annotateState:(BOOL)canShow;

/**
  SWitch the view mode from vertical to horizontal and vice versa
  @param BOOL, toVertical is true navigation happens vertical else horizontal
 */
-(void)switchViewMode:(BOOL)toVertical;

/**
 Undo the history of page navigation
 */
-(void)popHistory;

/**
  Returns true until the page navigation has not reached first page
 */
-(BOOL)hasPrevious;

/**
  Returns true until the page navigation has not reached last page
 */
-(BOOL)hasNext;

- (BOOL) isFirstPage;

- (BOOL) isLastPage;


/**
  Returns the current page's page number
 */
-(NSNumber*)getCurrentPageNumber;

/**
  Returns total pages count in the book
 */
-(NSUInteger)getTotalPagesCount;

/**
  Returns the current page's URL
 */
-(NSString*)getCurrentPageURL __attribute((deprecated("Use method getCurrentPageRelativeURL: instead. This method may return an absolute URL")));

/**
 Returns the current page's Relative URL as stored in DB
 */
-(NSString*)getCurrentPageRelativeURL;

/**
 Returns the upcoming page's URL
 to be displayed
 */
-(NSString*)getTransitionPageURL;

/**
  Customise the book page's static font size
  @param int, fontSize to adjust the size of the font
 */
-(void)setBookPageFontSize:(NSInteger)fontSize;

/**
  Customise the book page's static theme
  @param theme, NSString to change the theme of the page
 */
-(void)setBookPageTheme:(NSString*)theme;

/**
  Navigate to the particular page by using pageId
  @param NSString, pageId is a reference to jump to the particular page
 */
-(void)setAnnotationLabel:(NSString*)label;

/**
 
 */
- (void) lightboxDidClose;

-(void) reloadCurrentPage;

-(void)cleanPageViewContent;

- (BOOL) appSupportsPrintPages;

/**
 * Returns the labelProvider object from the dataInterface
 */
- (PxePlayerLabelProvider *) getLabelProvider;

/**
 * Sets the labelProvider object in the dataInterface
 */
- (void) setLabelProvider:(PxePlayerLabelProvider *)labelProvider;

/**
 Get the current book page theme
 @return NSString, returns the current book page theme
 @see PxePlayerDataInterface
 */
-(NSString*)getPageTheme;

/**
 Set the current book page theme
 @param NSString, theme is a reference to set the page current theme
 @see PxePlayerDataInterface
 */
-(void)setPageTheme:(NSString*)theme;

/**
 Get the current book page font size
 @return int , returns the current page font size
 @see PxePlayerDataInterface
 */
-(NSInteger)getPageFontSize;

/**
 Set the current book page font size
 @param int, fontSize as a integer values assigned to be a font size of the book
 @see PxePlayerDataInterface
 */
-(void)setPageFontSize:(NSInteger)fontSize;

/**
 
 */
- (NSMutableArray*) getHostWhiteList;

/**
 
 */
- (NSMutableArray*) getHostExternalList;

@end


