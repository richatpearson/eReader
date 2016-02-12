//
//  PxePlayerPageManager.h
//  PxePlayerApi
//
//  Created by Saro Bear on 18/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePageDetail.h"
#import "PxePrintPage.h"
#import "PxePlayerUIConstants.h"

#pragma mark - Delegates

/**
  A simple protocol which target class can implement to receive the notification status from the PxePlayerPageManager
 */
@protocol PxePlayerPageManagerDelegate <NSObject>

@required
/**
  This method will be called when pages has been added into the download queue
  @param NSArray, pages, array of pages added into the queue
 */
-(void)pagesAdded:(NSArray*)pages;

/**
  This method will be called when particular page has been downloaded
  @param NSString, page , currently downloaded page
 */
-(void)pageDownloaded:(NSString*)page;

/**
  This method will be called when particular page download has been failed
  @param NSError, error information about the download failed
 */
-(void)pageDownloadFailed:(NSError *)error;

/**
  This method will be called when page content has been downloaded
 */
-(void)contentsDownloadSuccess;

/**
  This method wil be called when page content download has been failed
  @param NSError, error information about the page content download failed
 */
-(void)contentsDownloadFailed:(NSError*)error;

- (PxePlayerDataInterface *) getCurrentDataInterface;

- (NSString*) getCurrentContextId;


@end

#pragma mark - Classes

/**
  A simple class which manages pages download queue and sends the required information to the target class to rendering a page and maintaining the queue
 */
@interface PxePlayerPageManager : NSObject

@property (nonatomic, weak) id <PxePlayerPageManagerDelegate> delegate;

/**
  Instantiate the class with pre-required properties to render a UI
  @param NSString, url as a NCX URL used to download toc XML and content.
  @param NSArray, urls, cutom playlist url's which user can speicifically navigate to the filtered list of pages from the book
  @param id, delegate, target class can implement it to receive notification
  @see initWithMasterPlaylist:withCustomPlaylist:andDelegate:
  @see PxePlayerPageManagerDelegate
 */
-(id)initWithNCXUrl:(NSString*)url withCustomPlaylist:(NSArray*)urls andDelegate:(id)delegate;

/**
  Instantiate the class with pre-required properties to render a UI
  @param NSArray, masterurls as a list of url's in which user can navigate pages
  @param NSArray, urls, cutom playlist url's which user can speicifically navigate to the filtered list of pages from the master playlist
  @param id, delegate, target class can implement it to receive notification
  @see initWithNCXUrl:withCustomPlaylist:andDelegate:
  @see PxePlayerPageManagerDelegate
 */
-(id)initWithMasterPlaylist:(NSArray*)masterurls withCustomPlaylist:(NSArray*)urls andDelegate:(id)delegate;

/**
  Navigate to the next page and returns it's URL
  @return NSString, returns the next page's URL
 */
-(NSString*)nextPage;

/**
  Navigate to the previous page and returns it's URL
  @return NSString, returns the previous page's URL
 */
-(NSString*)prevPage;

/**
 
 */
- (NSString*)getPageFromPageNumber:(NSNumber*)pageNum;

/**
 Get the currently rendered page base on the virtual page ID
 @return NSString, returns the current page's URL
 */
-(NSString*)getVirtualPage;

/**
 Get the currently rendered page based on the current page ID
 @return NSString, returns the current page's URL
 */
-(NSString*)getCurrentPage;

/**
  Navigate to the page by using page id
  @param NSString, pageId is a reference to jump to the particular page
  @return NSString, newly navigated page's URL
 */
-(NSString*)gotoPageByPageId:(NSString*)pageId;

/**
  Navigate to the particular page by using page URL
  @param NSString, pageURL is a reference to jump to the particular page
  @return NSString, newly navigated page's URL
 */
-(NSString*)gotoPageByPageURL:(NSString*)pageURL;

/**
  Navigate to the particular page by using page number
  @param NSString, pageNumber is a reference to jump to the particular page
  @return NSString, newly navigated page's URL
 */
-(NSString*)gotoPageByPageNumber:(NSNumber*)pageNumber;

/**
  This method will be called when current page has been loaded 
 */
-(void)pageDidLoad;

/**
  This method should be called after rendering the particular page and update's current page index
 */
-(void)updatePageIndex;

/**
  This method should be called to reset the current page index
  @param NSString, page as a page URL is a reference to set the current page
 */
-(void)resetCurrentPage:(NSString*)page;

/**
  Refresh the current page by freshly downloading the page content and render it and reset the current page properties
 */
-(void)refreshCurrentPage;

/**
  Refresh the particular page by freshly downloading the page content to reset the page properties
  @param NSString, pageId is a reference to refresh the particular page
 */
-(void)refreshPage:(NSString*)pageId;

/**
 This method returns if the current page has first page of the book
 @return BOOL, returns true if the page is first page of the book
 */
-(BOOL)isFirstPage;

/**
  This method returns if the current page has last page of the book
  @return BOOL, returns true if the page is last page of the book
 */
-(BOOL)isLastPage;

/**
  This method returns the current page number
  @return NSUInteger, returns the current page number
 */
-(NSInteger)getCurrentPageNumber;

/**
 This returns the current page title 
 @return NSString, page title
 */
-(NSString*)getCurrentPageTitle;

/**
  This method returns the total pages count in the book
  @return NSUInteger, returns the total page count in the book
 */
-(NSUInteger)getTotalPagesCount;

/**
  This method returns the current page index
  @return NSUInteger, returns the current page index
 */
-(NSInteger)getCurrentPageIndex;

/**
  This method returns the current transition page index
  @return NSUInteger, returns the current transitiosn page index
 */
-(NSInteger)getVirtualCurrentPageIndex;

/**
  This method returns the current page's page id
  @param NSString, returns the current page id
 */
-(NSString*)getCurrentPageId;

/**
  This method pop out the page stored in the history stack (LIFO)
  @return NSNumber, remove the last stored page number for history reference and returns the removed page number
 */
-(NSNumber*)popHistory;

/**
 
 */
- (BOOL) testURLForValidPage:(NSString*)pageURL;

/**
 
 */
- (PxePrintPage*) getPrintPageFromPrintPageNumber:(NSString *)printPageNumber;

/**
 
 */
- (void) initializePages;

- (PxePageDetail *) firstAvailablePageFromCurrentPageNumber:(NSInteger)currPage direction:(PxePlayerNavigationDirection)dir;

@end
