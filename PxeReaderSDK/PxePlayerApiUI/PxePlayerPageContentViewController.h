//
//  NTPageContentViewController.h
//  NTApi
//
//  Created by Saro Bear on 10/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerBookDelegate.h"
#import "PXEPlayerMoreInfoViewController.h"
#import "PxePlayerPageViewBacklinkMapping.h"
#import "PxePlayerDataInterface.h"

#import "GAI.h"
#import "GAIFields.h"

@class PxePlayerPagesWebView;
@class PxePlayerPageData;
@class PxePlayerLabelProvider;

#pragma mark - Delegates

/**
  A Protocol to which send's the page content view's few properties present status
  @Extension <NSObject>, extented from NSObject
 */
@protocol PageContentDelegate <PxePlayerBookDelegate>


/**
  Set the auto scale option to the UIWebView , page can auto-scale or resize based on the view frame
  @return NSUInteger , returns the current auto scale status either enabled or disabled
  @see UIWebView
 */
- (NSUInteger) scalePageToFit;

- (PxePlayerDataInterface *) getCurrentDataInterface;

- (BOOL) appSupportsPrintPages;
- (PxePlayerLabelProvider *) getLabelProvider;
- (NSString*) getPageTheme;
- (NSInteger) getPageFontSize;
- (NSMutableArray*) getHostWhiteList;
- (NSMutableArray*) getHostExternalList;
- (void)refreshPageWithUrl:(NSString*)url;

@optional

/**
  Load the external URL on external browser
  @param NSString ,relativeURL as a URL for external link will be loaded in the external browser
  @see UIWebView
 */
- (void) loadBrowserWithURL:(NSString *)relativeURL forType:(NSString*)type asLightbox:(BOOL)browser;

- (void) loadBrowserWithDictionary:(NSDictionary*)dict asLightbox:(BOOL)lightbox;

/**
 
 */
- (BOOL) isValidPage:(NSString*)pageURL;

/**
  This method called when current page has been loaded
  @param NSString , loadedPage , returns the page currently rendered on the book
 */
-(void)pageContentDidLoad:(NSString*)loadedPage;

/**
  This method getting called when page content is loading
  @param NSString , loadingPage , returns the currently loading page
 */
-(void)pageContentLoading:(NSString*)loadingPage;

/**
 Returns the current page title.
 @return NSString, page title
 */
-(NSString*)getCurrentPageTitle;

/**
 Returns the current page id.
 @return NSString, page id
 */
- (NSString*) getCurrentPageId;

- (NSString*) getCurrentContextId;

/**
  This method getting called when page loading has been failed
  @param NSString , pageURL , returns the loading page URL when the page loading has been failed
 */
-(void)pageLoadFailed:(NSString*)pageURL;

- (void) displayMoreInfoVC:(PXEPlayerMoreInfoViewController *)moreInfoVC;

- (void) scrollPageToDirection:(BOOL)isLeft error:(NSError**)error;

@end


#pragma mark - Classes

@interface PxePlayerPageContentViewController : UIViewController <UIWebViewDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate, PXEPlayerMoreInfoDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) id <PageContentDelegate> delegate;
//@property (nonatomic, strong) NSString *currentPage;

/**
 UIWebview instance for loading the page html content
 */
@property (nonatomic, strong) PxePlayerPagesWebView *pageContent; //made public - PXEPL-7005

/**
  This method Intialise the page content view controller UI and all required settings and prepares for rendering into the screen
  @param NSString , page , the page url which going to be rendered into the internal webview
  @param CGRect, frame, the frame of the view which going to be rendered on top of the window
  @param id, delegate , delegate class can get notification from the self class for certain events
  @see PageContentDelegate
 */
-(id)initWithPage:(NSString*)page
        withFrame:(CGRect)frame
      andDelegate:(id)delegate;

/**
  This method used for freshly (re)load the page on the web view
  @see UIWebView
 */
-(void)loadPage;

/**
  This method return status of either page has been loaded or not
  @return BOOL, returns page loaded or not
 */
-(BOOL)isPageDidLoad;

/**
  Set the current page id
  @param NSString , pageId , current page id will be assigned
 */
-(void)setPageId:(NSString*)pageId;

/**
  Get the page's absolute URL
  @return NSString , returns the current page absolute url
 */
-(NSString*)getPageAbsoluteURL;

/**
  Get the page's relative URL
  @return NSString , returns the current page relative url
 */
-(NSString*)getPageRelativeURL;

/**
  Get the page's UUID
  @return NSString , returns the current page UUID
 */
-(NSString*)getPageUUID;

/**
  Highlight the search words in the rendered page
  @param NSArray , highlightLabels , the array of labels that should be highlighted
 */
-(void)highlightSearchWords:(NSArray*)highlightLabels;

/**
  This method should be called to update the font properties into the page
 */
-(void)updateFont;

/**
  This method should be called to update the theme properties into the page
 */
-(void)updateTheme;

/**
  This method should be called to navigate to the particular title with in a page
  @param NSString , urlTag , the page url which going to be rendered into the internal webview
 */
-(void)gotoURLTag:(NSString*)urlTag;

/**
  This method should be called to set the annotation label
  @param NSString, label , annotate the label on the page
 */
-(void)setAnnotationLabel:(NSString*)label;

/*
 *Called when annotations should be toggled
 */
-(void)annotateState;

/**
 
 */
- (void) clearPageContent;

- (void) showSearchHighlightsOnPage;

/**
 
 */
- (void) updateBacklinkMapping:(PxePlayerPageViewBacklinkMapping*) backlinkMapping;

/**
 
 */
- (void) scrollToAnchor:(NSString*)anchor;

@end
