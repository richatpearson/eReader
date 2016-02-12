//
//  PxePlayerPageViewController.m
//  PxePlayerApi
//
//  Created by Saro Bear on 26/10/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerPageViewController.h"
#import "PxePlayerPageContentViewController.h"
#import "PxePlayerPageManager.h"
#import "PxePlayerLoadingView.h"
#import "PxePlayerUIConstants.h"
#import "PxePlayerInterface.h"
#import "Reachability.h"
#import "PxePlayer.h"
#import "PxePlayerDataManager.h"
#import "PxePageDetail.h"
#import "PxePrintPage.h"
#import "PXEPlayerMacro.h"
#import "PxePlayerError.h"
#import "PxePlayerPageViewOptions.h"
#import "PxePlayerUIEvents.h"
#import "PxePlayerPageViewBacklinkMapping.h"

#import "GAIDictionaryBuilder.h"

/**
  Class extension to display a book pages navigation .
 */

@interface PxePlayerPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, PxePlayerPageManagerDelegate>

/**
  Returns true if page is in transistion
 */
@property (nonatomic, assign) BOOL                  isPageAnimating;

/**
  Enable/Disable page swipe to navigation option.
 */
@property (nonatomic, assign) BOOL                  shouldAllowPageSwipe;

/**
  Starts book reading from the particular page
 */
@property (nonatomic, strong) NSString              *startPage;

/**
  Stores the page content view controller instances.
  @see PxePlayerPageContentViewController
 */
@property (nonatomic, strong) NSMutableDictionary   *pagesContainer;

/**
  Container Instance of UIPageViewController which holds the pageContent and page navigation options
  @see UIPageViewController
 */
@property (nonatomic, strong) UIPageViewController  *pxePageViewController;

/**
  Option to set the transition style of the UIPageViewContoller
 */
@property (nonatomic, assign) NSUInteger            transitionStyle;

/**
  Option to customise the page WebView scale content to fit
  @see UIWebView , scalePageContentToFit
 */
@property (nonatomic, assign) BOOL                  scalePage;

/**
  Class to handle downloading NCX content and helper for page navigation & download 
  @see PxePlayerPageManager
 */
@property (nonatomic, strong) PxePlayerPageManager  *pageManager;

/**
  Overlay screen of showing loading status
  @see PxePlayerLoadingView
 */
@property (nonatomic, strong) PxePlayerLoadingView  *loadingView; //this seems to be duplicated in the the pxeplayerPageContentViewController.

/**
 NSTimer variable to terminate the loading view at time interval
 */
@property (nonatomic) NSTimer                       *loadingViewTimer;

/**
 
 */
@property (nonatomic, strong) PxePlayerLightBoxViewController *lightBox;

/**
 
 */
@property (nonatomic, strong) PXEPlayerMoreInfoViewController *moreInfo;

/**
 
 */
@property (nonatomic, strong) PxePlayerPageViewBacklinkMapping *backlinkMapping;

/**
 Place to store the currently retrieved PxePrintPage so that we can scroll to 
 an id after the page has loaded.
 */
@property (nonatomic, strong) PxePrintPage *currentPrintPage;

@property (nonatomic, strong) PxePlayerDataInterface *dataInterface;

@property (nonatomic,strong) PxePlayerPageViewOptions *pageViewOptions;

@property (nonatomic, strong) PxePlayerAnnotation *currentAnnotation;

@property (nonatomic, assign) BOOL isPageRefreshing;

@end

@implementation PxePlayerPageViewController

#pragma mark - Self Methods

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_DID_WEBVIEW_ROTATE object:[NSNumber numberWithBool:isPortrait]];
}

- (id) initWithDataInterface:(PxePlayerDataInterface*)dataInterface
          customPlaylistURLs:(NSArray*)custompages
{
    self = [self initWithDataInterface:(PxePlayerDataInterface*)dataInterface
                    customPlaylistURLs:custompages
                           andGotoPage:nil
                           withOptions:nil];
    
    return self;
}

- (id)initWithDataInterface:(PxePlayerDataInterface*)dataInterface
         customPlaylistURLs:(NSArray*)custompages
                withOptions:(PxePlayerPageViewOptions*)options
{
    self = [self initWithDataInterface:(PxePlayerDataInterface*)dataInterface
                    customPlaylistURLs:custompages
                           andGotoPage:nil
                           withOptions:options];
    
    return self;
}

- (id) initWithDataInterface:(PxePlayerDataInterface*)dataInterface
          customPlaylistURLs:(NSArray*)custompages
                 andGotoPage:(NSString*)page
                 withOptions:(PxePlayerPageViewOptions*)options
{
    self = [super init];
    if (self)
    {
#ifdef DEBUG
        [[PxePlayer sharedInstance] markLoadTime:@"START - LOADING Page Views"];
#endif
        self.shouldAllowPageSwipe = YES;
        self.scalePage = NO;
        self.transitionStyle = UIPageViewControllerTransitionStylePageCurl;
        
        self.dataInterface = dataInterface;
        
        id masterdata = [self.dataInterface getTocOrPlaylist];
        if ([masterdata isKindOfClass:[NSString class]])
        {
            self.pageManager = [[PxePlayerPageManager alloc] initWithNCXUrl:masterdata withCustomPlaylist:custompages andDelegate:self];
        }
        else
        {
            self.pageManager = [[PxePlayerPageManager alloc] initWithMasterPlaylist:masterdata withCustomPlaylist:custompages andDelegate:self];
        }
        
        if(options)
        {
            self.pageViewOptions = options;
            
            if(options.shouldAllowPageSwipe)
            {
                self.shouldAllowPageSwipe = options.shouldAllowPageSwipe;
            }
            if(options.transitionStyle)
            {
                self.transitionStyle = options.transitionStyle;
            }
            if(options.scalePage)
            {
                // Commented out because it doesn't work
                // Causes too many problems
                // Try http://stackoverflow.com/questions/10666484/html-content-fit-in-uiwebview-without-zooming-out
                //self.scalePage = options.scalePage;
                DLog(@"self.scalePage: %@", (BOOL)self.scalePage?@"YES":@"NO");
            }
            if (options.backlinkMapping)
            {
                self.backlinkMapping = options.backlinkMapping;
            }
        }
        
        if (page)
        {
            self.startPage = page;
        }
        else
        {
            PxePageDetail *page = [self.pageManager firstAvailablePageFromCurrentPageNumber:0 direction:PxePlayerNavNext];
            self.startPage = page.pageURL;
        }
        DLog(@"self.startPage: %@", self.startPage);
    }
    
    return self;

}

- (void) loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view = view;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.pagesContainer = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSDictionary *spineOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                             forKey:UIPageViewControllerOptionSpineLocationKey];
    
    self.pxePageViewController = [[UIPageViewController alloc] initWithTransitionStyle:self.transitionStyle
                                                                 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                               options:spineOptions];
    
    self.pxePageViewController.dataSource = self;
    self.pxePageViewController.delegate = self;
    
    //add the page view controler
    self.pxePageViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.pxePageViewController];
    [self.pxePageViewController didMoveToParentViewController:self];
    [self.view addSubview:self.pxePageViewController.view];
    
    UIViewController *contentController = [[UIViewController alloc] init];
    NSArray *viewControllers = @[contentController];

    [self.pxePageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                        completion:^(BOOL finished)
                                         {
                                             if(finished)
                                             {
                                                 DLog(@"PageView FINISHED");
                                             }
                                         }];
    self.isPageAnimating = NO;
    
    self.loadingView = [PxePlayerLoadingView loadingViewInView:self.view];
    [self showLoader];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    DLog(@"definesPresentationContext: %d", self.definesPresentationContext);
    if(!self.lightBox && !self.moreInfo)
    {   //dont do this if its a lightbox OR MORE INFO
//        [self cleanPageContent];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    DLog(@"<------------------------------------------------------------------------------->");
    DLog(@"<------------------------------ MEMORY WARNING --------------------------------->");
    DLog(@"<------------------------------------------------------------------------------->\n");
    
    [super didReceiveMemoryWarning];
    
    //[self cleanPageViewContent];
}

-(void)dealloc
{
    DLog(@"page view controller deallocated...");
    
    self.startPage              = nil;
    self.pagesContainer         = nil;
    
    self.pxePageViewController.delegate = nil;
    self.pageManager.delegate   = nil;
    
    self.pxePageViewController  = nil;
    self.pageManager            = nil;
    self.loadingView            = nil;
}


#pragma mark - Private Methods
/**
 *  remove all the content pages otherwise you will see duplicates even when you change books
 */
-(void)cleanPageViewContent
{
    DLog(@"Clean PageView Content");
    PxePlayerPageContentViewController * contentViewController = [self getContentViewController];
    [contentViewController clearPageContent];
    
    PxePlayerPageContentViewController * nextContentViewController = [self getNextContentViewController];
    [nextContentViewController clearPageContent];
    
    PxePlayerPageContentViewController * prevContentViewController = [self getPreviousContentViewController];
    [prevContentViewController clearPageContent];

}
/**
  Initialize page rendering on the screen by instantiating the required objects, get the current page or start page id from the pageManager
  to start rendering the page and returns the UI updates to the delegate classes
  @see PxePlayerDataManager which returns the necessary data required from Core data to render pages
  @see PxePlayerPageManager
  @see PxePlayerPageContentViewController
  @see UIPageViewController
  @see NSNotificationCenter
 */
- (void) initializePages
{
    DLog(@"self.startPage: %@", self.startPage);
    NSString *curPage = nil;
    
    if(!self.startPage)
    {
        curPage = [self.pageManager getVirtualPage];
    }
    else
    {
        PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
        DLog(@"self.startPage: %@", self.startPage);
        if([[PxePlayer sharedInstance] usingPlaylist])
        {
            NSDictionary *entity = [dataManager fetchEntity:@"pageId"
                                               forContextId:[[PxePlayer sharedInstance] getContextID]
                                                   forModel:NSStringFromClass([PxePageDetail class])
                                                  withValue:self.startPage
                                                 resultType:NSDictionaryResultType
                                                withSortKey:nil
                                               andAscending:NO];
            
            NSInteger pageNumber = [entity[@"pageNumber"] integerValue];
            if(pageNumber == 1)
            {
                curPage = [self.pageManager getVirtualPage];
            }
            else
            {
                curPage = [self.pageManager gotoPageByPageId:self.startPage];
            }
        }
        else
        {
            NSDictionary *entity = [dataManager fetchEntity:@"pageURL"
                                               forContextId:[[PxePlayer sharedInstance] getContextID]
                                                   forModel:NSStringFromClass([PxePageDetail class])
                                                  withValue:self.startPage
                                                 resultType:NSDictionaryResultType
                                                withSortKey:nil
                                               andAscending:NO];
            
            NSInteger pageNumber = [entity[@"pageNumber"] integerValue];
            if(pageNumber == 1)
            {
                curPage = [self.pageManager getVirtualPage];
            }
            else
            {
                curPage = [self.pageManager gotoPageByPageURL:self.startPage];
            }
        }
        
        self.startPage = nil;
    }
    
    if(!curPage)
    {
        NSDictionary *uInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"Page not available", @"Page not available") };
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                            object:curPage
                                                          userInfo:uInfo];
        return;
    }
    
    PxePlayerPageContentViewController *contentController = [self.pagesContainer objectForKey:curPage];
    if(!contentController)
    {
        contentController = [[PxePlayerPageContentViewController alloc] initWithPage:nil
                                                                           withFrame:self.pxePageViewController.view.bounds
                                                                         andDelegate:self];
        
        //TODO: Don't know why we need this the content controler should only be aware of it's page
//        contentController.currentPage = [[self pageManager] getCurrentPage];
    }
    
    NSArray *viewControllers = @[contentController];
    
#ifdef DEBUG
    [[PxePlayer sharedInstance] markLoadTime:@"START - Setting Page Views"];
#endif
    __block __unsafe_unretained PxePlayerPageViewController *SELF = self;
    [self.pxePageViewController setViewControllers:viewControllers
                                         direction:UIPageViewControllerNavigationDirectionForward
                                          animated:NO
                                        completion:^(BOOL finished)
                                         {
#ifdef DEBUG
                                             [[PxePlayer sharedInstance] markLoadTime:@"FINISHED - Setting Page Views"];
#endif
                                             if(finished)
                                             {
                                                 // Moved code out of conditional to see if that improves page navigation whether the animation finshes or not
                                                 DLog(@"PageView animation FINISHED");
                                             }
                                             else
                                             {
                                                 NSLog(@"ERROR: animation DIDN'T FINISH");
                                             }
                                             [[SELF pageManager] updatePageIndex];
                                             if ([[SELF delegate] respondsToSelector:@selector(updatePageViewUI:orLastPage:andPageNumber:)])
                                             {
                                                 [[SELF delegate] updatePageViewUI:[SELF hasPrevious]
                                                                        orLastPage:[SELF hasNext]
                                                                     andPageNumber:[SELF getCurrentPageNumber]];
                                             }
                                             [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_BOOK_LOADED object:nil];
                                             [SELF notifyForPageChange];
#ifdef DEBUG
                                             [[PxePlayer sharedInstance] markLoadTime:@"FINISHED - LOADING Page Views"];
#endif
                                         }];
}

/**
  Push the current page number into the history stack to allow the user to undo the page navigations
  @param NSNumber, pageNumber, pageNumber should be pushed into the stack
 */
-(void)setPageFromHistory:(NSNumber*)pageNumber
{
    if(!pageNumber)
    {
        return;
    }
    
    NSString *currentPage = [self.pageManager gotoPageByPageNumber:pageNumber];
    if(currentPage)
    {
        NSInteger currentPageIndex = [self.pageManager getCurrentPageIndex];
        NSInteger newPageIndex = [self.pageManager getVirtualCurrentPageIndex];
        
        //if user selects the same page where he is in than don't load the page again
        if(newPageIndex == currentPageIndex) return;
        
        PxePlayerPageContentViewController *contentController = [self.pagesContainer objectForKey:currentPage];
        if(!contentController)
        {
            contentController = [[PxePlayerPageContentViewController alloc] initWithPage:currentPage
                                                                               withFrame:self.pxePageViewController.view.bounds
                                                                             andDelegate:self];
        }
        
        NSArray *viewControllers = @[contentController];
        NSInteger direction = UIPageViewControllerNavigationDirectionReverse;
        
        if(newPageIndex > currentPageIndex)
        {
            direction = UIPageViewControllerNavigationDirectionForward;
        }
        
        __block __unsafe_unretained PxePlayerPageViewController *SELF = self;
        [self.pxePageViewController setViewControllers:viewControllers
                                          direction:direction
                                           animated:YES
                                         completion:^(BOOL finished)
                                         {
                                             if(finished)
                                             {
                                                 // Moved code out of conditional to see if that improves page navigation whether the animation finshes or not
                                                 DLog(@"PageView animation FINISHED");
                                             }
                                             else
                                             {
                                                 NSLog(@"ERROR: animation DIDN'T FINISH");
                                             }
                                             
                                             [[SELF pageManager] updatePageIndex];
                                             if ([[SELF delegate] respondsToSelector:@selector(updatePageViewUI:orLastPage:andPageNumber:)]) {
                                                 [[SELF delegate] updatePageViewUI:[SELF.pageManager isFirstPage]
                                                                        orLastPage:[SELF.pageManager isLastPage]
                                                                     andPageNumber:[SELF getCurrentPageNumber]];
                                                 DLog(@"PageView FINISHED");
                                             }
                                            //TODO: Find out if this needs backlink mapping set 
                                         }];
    }
    else
    {
        NSDictionary *uInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"Can't access page from history",@"Can't access page from history") };
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                            object:currentPage
                                                          userInfo:uInfo];
    }
}

/**
  Render the current page with search words should be highlighted .
  @param NSString, currentPage is a reference to jump to the particular page
  @param NSString, pageId is a reference to jump to the particular title with in a page
  @param NSArray, labels is references of higlights area in the page .
 */
- (BOOL) setCurrentPage:(NSString*)currentPage
              andPageId:(NSString*)pageId
         withHighlights:(NSArray*)labels
                  error:(NSError**)error
{
    DLog(@"^^^^SET CURRENT PAGE^^^^");
    DLog(@"currentPage: %@", currentPage);
    // Optimistic
    BOOL currentPageSet = YES;
    if(currentPage)
    {
        DLog(@"getCurrentPageURL: %@", currentPage);
        NSInteger currentPageIndex = [self.pageManager getCurrentPageIndex];
        NSInteger newPageIndex = [self.pageManager getVirtualCurrentPageIndex];
        
        PxePlayerPageContentViewController *contentController = [self.pagesContainer objectForKey:currentPage];
        
        if(!contentController)
        {
            DLog(@"No content controller for url %@", currentPage);
            contentController = [[PxePlayerPageContentViewController alloc] initWithPage:currentPage
                                                                               withFrame:self.pxePageViewController.view.bounds
                                                                             andDelegate:self];
            
            [self.pagesContainer setObject:contentController forKey:currentPage];
        }
        
        if(!contentController)
        {
            NSError *underlyingError = [PxePlayerError errorForCode:PxePlayerNavigationError];
            NSDictionary * errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Can't set current page",@"Can't set current page"),
                                         NSUnderlyingErrorKey : underlyingError};
            if (error != NULL)
            {
                *error = [[NSError alloc] initWithDomain:PxePlayerErrorDomain
                                                    code:underlyingError.code
                                                userInfo:errorDict];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                                object:currentPage
                                                              userInfo:errorDict];
            
            currentPageSet = NO;
            return currentPageSet;
        }
        
        DLog(@"labels: %@", labels);
        if (labels && labels.count)
        {
            DLog(@"you would think it would get called here");
            [contentController highlightSearchWords:labels];
        }
        
        BOOL animated = YES;
        
        //if user selects the same page where he is in then don't load the page again
        DLog(@"newPageIndex: %ld ::: currentPageIndex: %ld", (long)newPageIndex, (long)currentPageIndex);
        if(newPageIndex == currentPageIndex)
        {
            if (contentController && labels && labels.count)
            {
                [contentController showSearchHighlightsOnPage];
            }
            currentPageSet = YES;
            
            if (SYSTEM_VERSION_LESS_THAN(@"9.0") || self.isPageRefreshing) //PXEPL-7005, PXEPL-7126
            {
                animated = NO;
                self.isPageRefreshing = NO;
            }
            else
            {
                DLog(@"Posting PXEPLAYER_PAGE_SETUP_COMPLETE notification for page we're already on...");
                [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_SETUP_COMPLETE object:nil userInfo:nil];
            }
            return currentPageSet;
        }
        
        [contentController setPageId:pageId];
        DLog(@"contentController pageId: %@", [contentController getPageUUID]);
        NSArray *viewControllers = @[contentController];
        NSInteger direction = UIPageViewControllerNavigationDirectionReverse;
        
        if(newPageIndex > currentPageIndex)
        {
            direction = UIPageViewControllerNavigationDirectionForward;
        }
        
        __block __unsafe_unretained PxePlayerPageViewController *SELF = self;
        [self.pxePageViewController setViewControllers:viewControllers
                                             direction:direction
                                              animated:animated //YES
                                            completion:^(BOOL finished)
                                            {
                                                if(finished)
                                                {
                                                    DLog(@"PageView FINISHED");
                                                    // Moved update page view code outside of conditional
                                                }
                                                else
                                                {
                                                    NSLog(@"ERROR: Didn't Finish");
                                                }
                                                // 4/9/15 - Trying to let this run whether or not the animation finshes - BT
                                                [[SELF pageManager] pageDidLoad];
                                                if ([[SELF delegate] respondsToSelector:@selector(updatePageViewUI:orLastPage:andPageNumber:)])
                                                {
                                                    [[SELF delegate] updatePageViewUI:[SELF hasPrevious]
                                                                           orLastPage:[SELF hasNext]
                                                                        andPageNumber:[SELF getCurrentPageNumber]];
                                                }
                                                
                                                [SELF notifyForPageChange];
                                                [contentController showSearchHighlightsOnPage];
                                                if (SELF.backlinkMapping)
                                                {
                                                    [contentController updateBacklinkMapping:SELF.backlinkMapping];
                                                }
                                            }];
    }
    else
    {
        NSLog(@"Error: call to set current page with nil value");
        
        NSError *underlyingError = [PxePlayerError errorForCode:PxePlayerNavigationError];
        NSDictionary * errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Page not available",@"Page not available"),
                                     NSUnderlyingErrorKey : underlyingError};
        if (error != NULL)
        {
            *error = [[NSError alloc] initWithDomain:PxePlayerErrorDomain
                                                code:underlyingError.code
                                            userInfo:errorDict];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_NOT_FOUND
                                                            object:pageId
                                                          userInfo:errorDict];
        currentPageSet = NO;
        return currentPageSet;
    }
    DLog(@"DONE!!!!!");
    return currentPageSet;
}

//TODO: When current page is established (by a page turn or intially), should return a page object
//with the current page and page number and let the app deal with it.
- (void) notifyForPageChange
{
    DLog(@"NOTIFY FOR PAGE CHANGE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    if([self isFirstPage])
    {
        DLog(@"MUST BE FIRST PAGE: %@", PXEPLAYER_FIRSTPAGE);
        NSDictionary* dict = @{@"navigation":PXEPLAYER_FIRSTPAGE};
        [[NSNotificationCenter defaultCenter] postNotificationName:PXE_Navigation
                                                            object:self
                                                          userInfo:dict];
    }
    else if([self isLastPage])
    {
        DLog(@"MUST BE LAST PAGE: %@", PXEPLAYER_LASTPAGE);
        NSDictionary* dict = @{@"navigation":PXEPLAYER_LASTPAGE};
        [[NSNotificationCenter defaultCenter] postNotificationName:PXE_Navigation
                                                            object:self
                                                          userInfo:dict];
    }
    else
    {
        DLog(@"MUST BE MIDDLE PAGE: %@", PXEPLAYER_MIDDLEPAGE);
        NSDictionary* dict = @{@"navigation":PXEPLAYER_MIDDLEPAGE};
        [[NSNotificationCenter defaultCenter] postNotificationName:PXE_Navigation
                                                            object:self
                                                          userInfo:dict];
    }
}

#pragma mark - Public methods
-(void)reloadCurrentPage
{
    PxePlayerPageContentViewController * contentViewController = [self getContentViewController];
    DLog(@"contentViewCOntroller: %@", contentViewController);
    [contentViewController loadPage];
}

- (BOOL) scrollPageToDirection:(BOOL)isLeft
{
    BOOL scrolled = NO;
    if(self.isPageAnimating)
    {
        DLog(@"Still ANIMATING so sit tight..");
        return scrolled;
    }
    
    if([self.loadingView isHidden])
    {
        [self showLoader];
    }
    
    NSString *goToPage = @"";
    // TODO: This seems backwards
    // Get Page
    if(isLeft)
    {
        //right navigation
        goToPage = [self.pageManager nextPage];
    }
    else
    {
        //left navigation
        goToPage = [self.pageManager prevPage];
    }
    // Go to page (maybe)
    if( goToPage != (id)[NSNull null] && [goToPage length] > 0 )
    {
        [self gotoPageWithPageURL:goToPage error:nil];
        scrolled = YES;
    }
    else
    {
        [self hideLoader];
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                            object:nil
                                                          userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot jump to invalid page",@"invalid page number")}];
    }
    return scrolled;
}

- (BOOL) scrollPageToDirection:(BOOL)isLeft error:(NSError**)error
{
    BOOL scrolled = NO;
    if(self.isPageAnimating)
    {
        DLog(@"Still ANIMATING so sit tight.."); return scrolled;
    }
    
    if([self.loadingView isHidden])
    {
        [self showLoader];
    }
    
    NSString *goToPage = @"";
    // Get Page
    if(isLeft)
    {
        //right navigation
        goToPage = [self.pageManager nextPage];
    }
    else
    {
        //left navigation
        goToPage = [self.pageManager prevPage];
    }
    // Go to page (maybe)
    if( goToPage != (id)[NSNull null] && [goToPage length] > 0 )
    {
        [self gotoPageWithPageURL:goToPage error:error];
        scrolled = YES;
    }
    else
    {
        [self hideLoader];
        NSError *underlyingError = [PxePlayerError errorForCode:PxePlayerOfflineDataError];
        NSDictionary * errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot jump to invalid page",@"invalid page number"),
                                     NSUnderlyingErrorKey : underlyingError};
        if (error != NULL)
        {
            *error = [[NSError alloc] initWithDomain:PxePlayerErrorDomain
                                                code:underlyingError.code
                                            userInfo:errorDict];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                            object:nil
                                                          userInfo:errorDict];
    }
    
    return scrolled;
}

- (void) jumpToPage:(NSNumber*)pageNumber
{
    DLog(@"pageNumber: %@", pageNumber);
    NSError *pageError;
    if (pageNumber)
    {
        NSString *goToPage = [self.pageManager getPageFromPageNumber:pageNumber];
        if(goToPage)
        {
            [self gotoPageWithPageURL:goToPage error:nil];
        }
        else
        {
            if ([[pageNumber stringValue] isEqualToString: [self.pageManager getVirtualPage]])
            {
                pageError = [PxePlayerError errorForCode:PxePlayerNavigationError];
                NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot jump to invalid page number",@"invalid page number"),
                                            NSUnderlyingErrorKey : pageError};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                                    object:nil
                                                                  userInfo:errorDict];
            }
            
        }
    }
    else
    {
        NSLog(@"Error: call to jumpToPage without valid page number.");
        pageError = [PxePlayerError errorForCode:PxePlayerNavigationError];
        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot jump to invalid page number",@"invalid page number"),
                                    NSUnderlyingErrorKey : pageError};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                            object:nil
                                                          userInfo:errorDict];
    }
}

- (void) jumpToPrintPage:(NSString*)printPageNumber
{
    [self jumpToPrintPage:printPageNumber onComplete:nil];
}

- (void) jumpToPrintPage:(NSString*)printPageNumber onComplete:(void (^)(BOOL success, NSNumber *digitalPage, NSString *pageURL))handler
{
    if (!printPageNumber || [printPageNumber isEqualToString:@""])
    {
        DLog(@"Missing print page number");
        [self reportPrintPageNumberError];
        if(handler)
        {
            handler(NO,nil,nil);
        }
        return;
    }
    DLog(@"Jump to print page: %@", printPageNumber);
    
    self.currentPrintPage = [self.pageManager getPrintPageFromPrintPageNumber:printPageNumber];
    
    if (self.currentPrintPage)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToPrintPage:) name:PXEPLAYER_PAGE_LOADED object:nil];
        NSError *printPageJumpError;
        PxePageDetail *digitalPage = self.currentPrintPage.page;
        [self gotoPageWithPageURL:digitalPage.pageURL error:&printPageJumpError];
        if (printPageJumpError)
        {
            [self reportPrintPageNumberError];
            if (handler)
            {
                handler(NO,nil,nil);
            }
        }
        else
        {
            if (handler)
            {
                handler(YES,self.currentPrintPage.page.pageNumber, self.currentPrintPage.page.pageURL);
            }
        }
    }
    else {
        //no print page url for page number
        [self reportPrintPageNumberError];
        if (handler)
        {
            handler(NO,nil,nil);
        }
    }
}

- (void) scrollToPrintPage:(NSNotification*)notification
{
    PxePlayerPageContentViewController *currentPageVC;
    
    NSArray *viewControllers = (NSArray*)[self.pxePageViewController viewControllers];
    DLog(@"viewControllers: %@", viewControllers);
    if([viewControllers count])
    {
        NSString *pageUrl = self.currentPrintPage.page.pageURL;
        
        NSInteger srchIndx = [viewControllers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                              {
                                  PxePlayerPageContentViewController *contentVC = (PxePlayerPageContentViewController*)obj;
                                  if (pageUrl && [contentVC isKindOfClass:[PxePlayerPageContentViewController class]])
                                  {
                                      NSString *relativePage = [contentVC getPageRelativeURL];
                                      
                                      if (relativePage)
                                      {
                                          return [relativePage isEqualToString:pageUrl];
                                      }
                                      else
                                      {
                                          return NO;
                                      }
                                  }
                                  return NO;
                              }];
        if (srchIndx != NSNotFound)
        {
            NSArray *splitURL = [self.currentPrintPage.pageURL componentsSeparatedByString:@"#"];
            
            if([splitURL count] > 1)
            {
                NSString *printPageAnchor = [splitURL objectAtIndex:1];
                DLog(@"printPageAnchor: %@", printPageAnchor);
                currentPageVC = viewControllers[srchIndx];
                DLog(@"currentPageVC: %@", currentPageVC);
                [currentPageVC scrollToAnchor:printPageAnchor];
            }
        }
        else
        {
            [self reportPrintPageNumberError];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXEPLAYER_PAGE_LOADED object:nil];
    self.currentPrintPage = nil;
}

-(void) reportPrintPageNumberError
{
    NSLog(@"Error: call to jumpToPrintPage without valid page number.");
    
    NSError *pageError = [PxePlayerError errorForCode:PxePlayerNavigationError];
    NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Invalid print page number.",@"invalid print page number"),
                                NSUnderlyingErrorKey : pageError};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                        object:nil
                                                      userInfo:errorDict];
}

- (void) jumpToAnnotation:(PxePlayerAnnotation*)annotation
{
    if (![self isAnnotationValid:annotation])
    {
        return;
    }
    
    DLog(@"Setting page_loaded notification to scrollToAnnotation...");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToAnnotation:) name:PXEPLAYER_PAGE_SETUP_COMPLETE object:nil];
    
    self.currentAnnotation = annotation;
    
    NSError *jumpToAnnotationError;
    [self gotoPageWithPageURL:annotation.uri error:&jumpToAnnotationError];
    if (jumpToAnnotationError)
    {
        [self reportJumpToAnnotationErrorForCode:PxePlayerNavigationError];
    }
}

- (BOOL) isAnnotationValid:(PxePlayerAnnotation*)annotation
{
    if (!annotation)
    {
        [self reportJumpToAnnotationErrorForCode:PxePlayerMissingAnnotationError];
        
        return NO;
    }
    if (!annotation.annotationDttm)
    {
        [self reportJumpToAnnotationErrorForCode:PxePlayerMissingAnnotationIdError];
        
        return NO;
    }
    
    if (!annotation.uri || [annotation.uri isEqualToString:@""])
    {
        [self reportJumpToAnnotationErrorForCode:PxePlayerInvalidURL];
        
        return NO;
    }
    
    return  YES;
}

- (void) reportJumpToAnnotationErrorForCode:(PxePlayerErrorCode)errorCode
{
    NSError *pageError = [PxePlayerError errorForCode:errorCode];
    NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Unable to scroll to annotation.",@"Unable to scroll to annotation"),
                                NSUnderlyingErrorKey : pageError};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                        object:nil
                                                      userInfo:errorDict];
}

- (void) scrollToAnnotation:(NSNotification*)notification
{
    PxePlayerPageContentViewController *currentPageVC;
    
    NSArray *viewControllers = (NSArray*)[self.pxePageViewController viewControllers];
    DLog(@"viewControllers: %@", viewControllers);
    if([viewControllers count])
    {
        NSString *pageUrl = self.currentAnnotation.uri;
        
        NSInteger srchIndx = [viewControllers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                              {
                                  PxePlayerPageContentViewController *contentVC = (PxePlayerPageContentViewController*)obj;
                                  if (pageUrl && [contentVC isKindOfClass:[PxePlayerPageContentViewController class]])
                                  {
                                      NSString *relativePage = [contentVC getPageRelativeURL];
                                      
                                      if (relativePage)
                                      {
                                          return [relativePage isEqualToString:pageUrl];
                                      }
                                      else
                                      {
                                          return NO;
                                      }
                                  }
                                  return NO;
                              }];
        if (srchIndx != NSNotFound)
        {
            NSString *annotationAnchor = [NSString stringWithFormat:@"an-%@", self.currentAnnotation.annotationDttm];
            DLog(@"Highlight id in html: %@", annotationAnchor);
            currentPageVC = viewControllers[srchIndx];
            [currentPageVC performSelector:@selector(scrollToAnchor:) withObject:annotationAnchor afterDelay:2.0f];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:PXEPLAYER_PAGE_SETUP_COMPLETE object:nil];
            self.currentAnnotation = nil;
        }
        else
        {
            DLog(@"Error - Could not find page to jump to annotation.");
            [self reportJumpToAnnotationErrorForCode:PxePlayerInvalidURL];
        }
    }
}

- (BOOL) hasPrevious
{
    DLog(@"FIRST PAGE: %@", [self.pageManager isFirstPage]?@"YES":@"NO");
    return [self.pageManager isFirstPage];
}

- (BOOL) hasNext
{
   DLog(@"LAST PAGE: %@", [self.pageManager isLastPage]?@"YES":@"NO");
   return [self.pageManager isLastPage];
}

- (BOOL) isFirstPage
{
    return [self.pageManager isFirstPage];
}

- (BOOL) isLastPage
{
    return [self.pageManager isLastPage];
}

- (NSNumber*) getCurrentPageNumber
{
    if(!self.pageManager)
    {
        return nil;
    }
    
    NSNumber *pageNumber = [NSNumber numberWithInteger:[self.pageManager getCurrentPageNumber]];
    return pageNumber;
}

- (NSUInteger) getTotalPagesCount
{
    if(!self.pageManager)
    {
        return 0;
    }
    
    return [self.pageManager getTotalPagesCount];
}

- (void) gotoPageWithContentID:(NSString*)pageId
{
    NSString *curPage = [self.pageManager gotoPageByPageId:pageId];
    if(curPage)
    {
        NSError *goToPageError;
        [self setCurrentPage:curPage andPageId:nil withHighlights:nil error:&goToPageError];
    }
    else
    {
        NSLog(@"ERROR - Page not available");
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_NOT_FOUND
                                                            object:pageId
                                                          userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Page not available",@"Page not available")}];
    }
}

-(void)gotoPageWithPageURL:(NSString*)pageUrl
{
    [self gotoPageWithPageURL:pageUrl andHighlightLabels:nil];
}

- (BOOL) gotoPageWithPageURL:(NSString*)pageUrl error:(NSError**)error
{
    // Optimistic
    BOOL wentToPage = YES;
    if (error == NULL)
    {
        wentToPage = [self gotoPageWithPageURL:pageUrl andHighlightLabels:nil error:nil];
    } else {
        wentToPage = [self gotoPageWithPageURL:pageUrl andHighlightLabels:nil error: error];
    }
    return wentToPage;
}

- (void) gotoPageWithPageId:(NSString*)pageId withURL:(NSString*)pageURL
{
    NSString *curPage = [self.pageManager getVirtualPage];
    
    if([curPage isEqualToString:pageURL])
    {
        PxePlayerPageContentViewController *contentController = [self.pagesContainer objectForKey:curPage];
        if(contentController)
        {
            [contentController gotoURLTag:pageId];
            return;
        }
    }
    
    NSString *newPage = [self.pageManager gotoPageByPageURL:pageURL];
    NSError *newPageError;
    if(newPage)
    {
        [self setCurrentPage:newPage andPageId:pageId withHighlights:nil error:&newPageError];
    }
    else
    {
        NSLog(@"ERROR - Page not available");
        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Page not available", @"Page not available")};
        newPageError = [PxePlayerError errorForCode:PxePlayerNavigationError errorDetail:errorDict];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_NOT_FOUND
                                                            object:pageURL
                                                          userInfo:errorDict];
    }
}

- (void) gotoPageWithPageURL:(NSString *)pageUrl andHighlightLabels:(NSArray*)labels
{
    NSString *curPage = [self.pageManager gotoPageByPageURL:pageUrl];
    NSError *curPageError;
    if(curPage)
    {
        DLog(@"setting current page with highlights: %@", labels);
        [self setCurrentPage:curPage andPageId:nil withHighlights:labels error:&curPageError];
    }
    else
    {
        NSLog(@"ERROR - Page not available");
        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Page not available", @"Page not available")};
        curPageError = [PxePlayerError errorForCode:PxePlayerNavigationError errorDetail:errorDict];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_NOT_FOUND
                                                            object:pageUrl
                                                          userInfo:errorDict];
    }
}

- (BOOL) gotoPageWithPageURL:(NSString *)pageUrl andHighlightLabels:(NSArray*)labels error:(NSError**)error
{
    BOOL wentToPage = YES;
    NSString *curPage = [self.pageManager gotoPageByPageURL:pageUrl];
    DLog(@"curPage: %@", curPage);
    if(curPage)
    {
        if ([self setCurrentPage:curPage andPageId:nil withHighlights:labels error:error])
        {
            DLog(@"Current PAge is SET");
        }
    }
    else
    {
        /* 
         HACK ALERT - added conditional here to strip off the anchor tag
         if the original goTo url is not found by the pageManager. Adding 
         code to PageManager gotoPageByPageURL did not work but adding 
         the code here does work.
         */
        if ([self urlHasAnchorTag: pageUrl])
        {
            pageUrl = [self stripAnchorTagFromURL:pageUrl];
            DLog(@"TRY IT AGAIN WITH STRIPPED URL: %@", pageUrl);
            [self gotoPageWithPageURL:pageUrl andHighlightLabels:labels error:error];
            
        } else {
            NSLog(@"ERROR - Page not available");
            NSError *error = [PxePlayerError errorForCode:PxePlayerNavigationError];
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Page not available",@"Page not available"),
                                        NSUnderlyingErrorKey : error};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_NOT_FOUND
                                                                object:pageUrl
                                                              userInfo:errorDict];
            wentToPage = NO;
        }
    }
    return wentToPage;
}

- (BOOL) urlHasAnchorTag:(NSString*)testURL
{
    BOOL hasAnchor = NO;
    
    NSArray *splitURL = [testURL componentsSeparatedByString:@"#"];
    
    if ([splitURL count] > 1)
    {
        hasAnchor = YES;
    }
    
    return hasAnchor;
}

- (NSString*) stripAnchorTagFromURL:(NSString*)url
{
    NSArray *splitURL = [url componentsSeparatedByString:@"#"];
    
    return [splitURL objectAtIndex:0];
}

- (BOOL) isValidPage:(NSString*)pageURL
{
    DLog(@"...testing valid page...");
    return [self.pageManager testURLForValidPage:pageURL];
}

- (void) popHistory
{
    [self setPageFromHistory:[self.pageManager popHistory]];
}

- (NSString*) getCurrentPageURL
{
    //TODO: Re-evaluate the relative and absolute page url
    NSString * pageUrl = [self.pageManager getCurrentPage];
    NSArray *viewControllers = (NSArray*)[self.pxePageViewController viewControllers];
    
    if([viewControllers count])
    {
        NSInteger srchIndx = [viewControllers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
        {
            PxePlayerPageContentViewController *contentVC = (PxePlayerPageContentViewController*)obj;
            if (pageUrl && [contentVC isKindOfClass:[PxePlayerPageContentViewController class]])
            {
                NSString *relativePage = [contentVC getPageRelativeURL];
                
                if (relativePage)
                {
                    return [relativePage isEqualToString:pageUrl];
                }
                else
                {
                    return NO;
                }
            }
            return NO;
        }];
        if (srchIndx != NSNotFound)
        {
            return [viewControllers[srchIndx] getPageAbsoluteURL];
        }
        else
        {
            return pageUrl;
        }
    }
    
    return nil;
}

-(NSString*)getCurrentPageRelativeURL
{
    return [self.pageManager getCurrentPage];
}

-(NSString*)getTransitionPageURL
{
    //TODO: Re-evaluate the relative and absolute page url
    NSString * pageUrl = [self.pageManager getVirtualPage];
    NSArray *viewControllers = (NSArray*)[self.pxePageViewController viewControllers];
    
    if([viewControllers count])
    {
        NSInteger srchIndx = [viewControllers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                              {
                                  PxePlayerPageContentViewController *contentVC = (PxePlayerPageContentViewController*)obj;
                                  if (pageUrl && [contentVC isKindOfClass:[PxePlayerPageContentViewController class]])
                                  {
                                      NSString *relativePage = [contentVC getPageRelativeURL];
                                      
                                      if (relativePage)
                                      {
                                          return [relativePage isEqualToString:pageUrl];
                                      }
                                      else
                                      {
                                          return NO;
                                      }
                                  }
                                  return NO;
                              }];
        if (srchIndx != NSNotFound)
        {
            return [(PxePlayerPageContentViewController*)viewControllers[srchIndx] getPageUUID];
        }
        else
        {
            return pageUrl;
        }
    }
    
    return nil;
}

- (void) switchViewMode:(BOOL)toVertical
{
    //add the page view controler
    NSDictionary *spineOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                             forKey:UIPageViewControllerOptionSpineLocationKey];
    UIPageViewController *pageController = nil;
    
    if(toVertical)
    {
        pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                         navigationOrientation:UIPageViewControllerNavigationOrientationVertical
                                                                       options:spineOptions];
    }
    else
    {
        pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                         navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                       options:spineOptions];
    }
    
    [pageController setDataSource:self];
    [pageController setDelegate:self];
    [self didMoveToParentViewController:pageController];
    [self addChildViewController:pageController];
    
    if(!self.pxePageViewController)
    {
        self.pxePageViewController = pageController;
        [self.view insertSubview:self.pxePageViewController.view atIndex:0];
    }
    else
    {
        [pageController.view setFrame:self.pxePageViewController.view.frame];
        __weak __block PxePlayerPageViewController *weakSelf = self;
        
        NSArray *viewControllers =  [NSArray arrayWithArray:[self.pxePageViewController viewControllers]];
        [self transitionFromViewController:self.pxePageViewController toViewController:pageController
                                  duration:0.01f options:UIViewAnimationOptionTransitionNone
                                animations:nil completion:^(BOOL finished)
         {
             [weakSelf.pxePageViewController willMoveToParentViewController:nil];
             [weakSelf.pxePageViewController removeFromParentViewController];
             weakSelf.pxePageViewController = pageController;
             
             [self.view insertSubview:self.pxePageViewController.view atIndex:0];
             
             [self.pxePageViewController setViewControllers:viewControllers
                                                  direction:UIPageViewControllerNavigationDirectionForward
                                                   animated:NO
                                                 completion:^(BOOL finished)
                                                  {
                                                      if(finished)
                                                      {
                                                          DLog(@"PageView FINISHED");
                                                      }
                                                  }];
         }];
    }
    
    self.isPageAnimating = NO;
}

- (void) hideLoader
{
    [self.loadingView removeView];
    self.loadingViewTimer = nil;
}

- (void) showLoader
{
//    NSLog(@"\n\n\n SHOWING LOADER!!\n\n\n");
    [self.loadingView setHidden:NO];
    self.loadingViewTimer = nil;
    self.loadingViewTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_TO_REMOVE_LOADING
                                                             target:self
                                                           selector:@selector(hideLoader)
                                                           userInfo:nil
                                                            repeats:NO];
}

#pragma mark - Page manager delegate methods

/**
  This method get invoked when PxePlayerPageManager navigates the page .
  @param NSArray, pages are the number of required pages for caching
  @see PxePlayerPageManager
  @see PxePlayerPageManagerDelegate
 */
- (void) pagesAdded:(NSArray*)pages
{
    //preload the new pages for display
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    DLog(@"\n\nADDING PAGES \n\n");
    for (NSString *page in pages)
    {
        PxePlayerPageContentViewController *contentController = [self.pagesContainer objectForKey:page];
        
        [self resetContentForController:&contentController pageUrl:page]; //PXEPL-7005 for 8.x
        
        if(!contentController)
        {
            contentController = [[PxePlayerPageContentViewController alloc] initWithPage:page
                                                                               withFrame:self.pxePageViewController.view.bounds
                                                                             andDelegate:self];
            if(page)
            {
                [self.pagesContainer setObject:contentController forKey:page];
            }
        }
    }
    DLog(@"pagesAdded: %@", pages);
    DLog(@"PagesContainer: %@", [self.pagesContainer allKeys]);
    // Remove expired pages
    // 1. Get array of existing pages in pagesContainer
    // 2. Check if existingPage is in  pages array you just created and if not, remove from pagesContainer
    // 3. I have no idea what that last part is
    NSArray *existPages = [self.pagesContainer allKeys];
    DLog(@"existingPages: %@", existPages);
    for (NSString *existPage in existPages)
    {
        NSInteger pageIndex = [pages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                               {
                                   return [(NSString*)obj isEqualToString:existPage];
                               }];
        DLog(@"      PageIndex: %ld", (long)pageIndex);
        if(pageIndex == NSNotFound)
        {
            DLog(@"!!!!!!!REMOVING OBJECT!!!!!!! %@", existPage);
            
            [self.pagesContainer removeObjectForKey:existPage];
        }
    }
    DLog(@"filteredPages: %@", [self.pagesContainer allKeys]);
    //TODO: WHAT IS THIS FOR?
    // It seems to add pages into memory but why is it necessary?
    // Is it reflective of the poor implementation of the page view controller?
//    NSArray *allKeys = [self.pagesContainer allKeys];
//    for (NSString *key in allKeys)
//    {
//        PxePlayerPageContentViewController *contentController = [self.pagesContainer objectForKey:key];
//        [operationQueue addOperationWithBlock:^{
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                //Not sure why we need this. contentController should only be aware of it's page
//                //contentController.currentPage = [[self pageManager] getCurrentPage];
//                [contentController view];
//            }];
//        }];
//    }
}

/**
 Work-around - resetting content if webView has been previously set - bug for iOS 8.x
 */
-(void) resetContentForController:(PxePlayerPageContentViewController**)contentController pageUrl:(NSString*)page
{
    if (*contentController && [*contentController pageContent] && [page isEqualToString:[self.pageManager getVirtualPage]] &&
        (SYSTEM_VERSION_LESS_THAN(@"9.0") || self.isPageRefreshing)) //Debug PXEPL-7005, and only for current page, and only for iOS 8.x, or - page refresh PXEPL-7126
    {
        DLog(@"About to reset content for page \n%@\n with existing web view", page);
        
        [self.pagesContainer removeObjectForKey:[*contentController getPageRelativeURL]];
        *contentController = nil;
    }
}

/**
  This method get invoked when PxePlayerPageManager downloaded the any page . here it checks whether downloaded page as a current page if yes than it's start rendering downloaded content to the screen
  @param NSString, page is a reference of pageURL has been downloaded.
  @see PxePlayerPageManagerDelegate
  @see PxePlayerPageManager
 */
- (void) pageDownloaded:(NSString*)page
{
    NSArray *viewControllers = (NSArray*)[self.pxePageViewController viewControllers];
    NSInteger srchIndx = [viewControllers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        if(![obj isKindOfClass:[PxePlayerPageContentViewController class]])
        {
            return NO;
        }
        
        return [[(PxePlayerPageContentViewController*)obj getPageRelativeURL] isEqualToString:page];
    }];
    
    if (srchIndx != NSNotFound)
    {   //current page
        [viewControllers[srchIndx] loadPage];
    }
    else
    {  //cached page
        PxePlayerPageContentViewController *contentController = [self.pagesContainer objectForKey:page];
        [contentController loadPage];
    }
}

/**
  This method get invoked when PxePlayerPageManager download failed on any page . broadcasting the message of page download failed that could be invoked by any external class by adding observers
  @param NSError, error contains the error information about download faild.
  @see PxePlayerPageManagerDelegate
  @see PxePlayerPageManager
 */
- (void) pageDownloadFailed:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                        object:error.localizedDescription
                                                      userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Page download failed",@"Page download failed")}];
}

/**
  This method get invoked when PxePlayerPageManager download failed on initial pages . broadcasting the message of page download failed that could be invoked by any external class by adding observers
  @param NSError, error contains the error information about download faild.
  @see PxePlayerPageManagerDelegate
  @see PxePlayerPageManager
 */
- (void) contentsDownloadFailed:(NSError *)error
{
    if(![self.loadingView isHidden])
    {
        [self.loadingView removeView];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                        object:error.localizedDescription
                                                      userInfo:@{ NSLocalizedDescriptionKey:NSLocalizedString(@"Content download failed",@"Content download failed")}];
}

/**
  This method get invoked when PxePlayerPageManager downloaded first initial pages successfully.
  @see PxePlayerPageManagerDelegate
  @see PxePlayerPageManager
 */
- (void) contentsDownloadSuccess
{
    [self initializePages];
}


#pragma mark - Pagesview delegate methods

- (void) pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    DLog(@"pageViewController: %@", pageViewController);
    self.isPageAnimating = YES;
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController
       viewControllerBeforeViewController:(UIViewController *)viewController
{
    DLog(@"pageViewController: %@", pageViewController);
    UIViewController *contentController = nil;
    
    if(self.isPageAnimating || (!self.pageViewOptions.shouldAllowPageSwipe) || ![self isSwipeToAdjacentPageFromPage:pageViewController toPreviousPage:YES])
    {
        return  contentController;
    }
    
    NSString *prevPage = [self.pageManager prevPage];
    if (prevPage)
    {
        contentController = [self.pagesContainer objectForKey:prevPage];
        if(!contentController)
        {
            contentController = [[PxePlayerPageContentViewController alloc] initWithPage:prevPage withFrame:self.pxePageViewController.view.bounds andDelegate:self];
            [self.pagesContainer setObject:contentController forKey:prevPage];
        }
    }
    
    return contentController;
}

- (BOOL) isSwipeToAdjacentPageFromPage:(UIPageViewController *)pageViewController
                        toPreviousPage:(BOOL)isPreviousPage
{
    BOOL result = YES;
    DLog(@"GESTURE RECOGNIZER: %@", pageViewController.gestureRecognizers);
    for (UIGestureRecognizer *gestureRecognizer in pageViewController.gestureRecognizers)
    {
        if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
        {
            DLog(@"Swipe!");
        }
        
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        {
            CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:pageViewController.view];
            DLog(@"###Coordinate velocity - x:%f, y:%f ###", velocity.x, velocity.y);
            result = [self isSwipeToAdjacentPageForVelocity:velocity toPreviousPage:isPreviousPage];
        }
    }
    
    return result;
}

- (BOOL) isSwipeToAdjacentPageForVelocity:(CGPoint)velocity
                           toPreviousPage:(BOOL)isPreviousPage
{
    BOOL result = NO;
    
    if (isPreviousPage)
    { //before ViewController
        if (velocity.x > 0 && velocity.x > fabs(velocity.y))
        { //is the drag from left to right and horizontal?
            result = YES;
        }
    }
    else
    { //after ViewController
        if (velocity.x < 0 && fabs(velocity.x) > fabs(velocity.y))
        { //is the drag from right to left and horizontal?
            result = YES;
        }
    }
    return result;
}

- (UIViewController *) pageViewController: (UIPageViewController *)pageViewController
        viewControllerAfterViewController:(UIViewController *)viewController
{
    DLog(@"pageViewController: %@", pageViewController);
    UIViewController *contentController = nil;
    
    if(self.isPageAnimating || (!self.pageViewOptions.shouldAllowPageSwipe) || ![self isSwipeToAdjacentPageFromPage:pageViewController toPreviousPage:NO])
    {
        DLog(@"in this crazy conditional");
        return  contentController;
    }
    
    NSString *nextPage = [self.pageManager nextPage];
    if (nextPage)
    {
        contentController = [self.pagesContainer objectForKey:nextPage];
        if(!contentController)
        {
            contentController = [[PxePlayerPageContentViewController alloc] initWithPage:nextPage withFrame:self.pxePageViewController.view.bounds andDelegate:self];
            [self.pagesContainer setObject:contentController forKey:nextPage];
        }
    }
    return contentController;
}

- (void) pageViewController:(UIPageViewController *)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    DLog(@"pageViewController:didFinishAnimating %@", pageViewController);
    if(completed)
    {
        [self.pageManager pageDidLoad];
        
        if ([[self delegate] respondsToSelector:@selector(updatePageViewUI:orLastPage:andPageNumber:)]) {
            [[self delegate] updatePageViewUI:[self hasPrevious]
                                   orLastPage:[self hasNext]
                                andPageNumber:[self getCurrentPageNumber]];
        }
        [self notifyForPageChange];
    }
    
    self.isPageAnimating = NO;
}


#pragma mark - Page Content delegate methods

/**
  Navigate to the particular page by using pageUrl and should show the highlights in the page
  @param NSString, pageUrl is a reference to jump to the particular page
  @see PxePlayerPageContentViewController
 */

- (BOOL) loadPageWithRelativeURL:(NSString*)relativeURL
{
    NSString *curPage = [self.pageManager gotoPageByPageURL:relativeURL];
    NSError *curPageError;
    if(curPage) {
        [self setCurrentPage:curPage andPageId:nil withHighlights:nil error:&curPageError];
        return YES;
    }
    else {
        NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"Page not available",@"Page not available") };
        curPageError = [PxePlayerError errorForCode:PxePlayerNavigationError errorDetail:errorDict];
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_NOT_FOUND object:relativeURL userInfo:errorDict ];
    }
    
    return NO;
}

/**
  Checking if the particular page has available to render
  @param NSString, pageUrl as a paramenter to check that page has found on database
 */
- (BOOL) isPageAvailable:(NSString*)relativeURL
{
    return ([self.pageManager gotoPageByPageURL:relativeURL] == nil) ? NO : YES;
}

/**
  User can load the external link from book on internal browser
  @param NSString, relativeURL is a link to open in browser
 */
- (void) loadBrowserWithURL:(NSString *)relativeURL
                    forType:(NSString*)type
                 asLightbox:(BOOL)lightbox
{
    DLog(@"RelativeURL: %@", relativeURL);
    NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:kDataBundleName ofType:@"bundle"]];
    [resourceBundle load];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PxeReaderStoryboard" bundle:resourceBundle];
    
    if(!self.lightBox)
    {
        // Only open one instance of lightbox
        self.lightBox = [sb instantiateViewControllerWithIdentifier:@"LIGHTBOX"];
        [self.lightBox setIsLightbox:lightbox];
        self.lightBox.boxInfo = @{@"type": @"gadget",@"contentUrl":relativeURL,@"fileType":type};
        self.lightBox.delegate = self;
        [self presentViewController:self.lightBox animated:YES completion:nil];
    }
}

- (void) loadBrowserWithDictionary:(NSDictionary*)dict asLightbox:(BOOL)lightbox
{
    NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:kDataBundleName ofType:@"bundle"]];
    [resourceBundle load];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PxeReaderStoryboard" bundle:resourceBundle];
    
    if(!self.lightBox)
    {
        // Only open one instance of lightbox
        self.lightBox = [sb instantiateViewControllerWithIdentifier:@"LIGHTBOX"];
        [self.lightBox setIsLightbox:lightbox];
        self.lightBox.boxInfo = dict;
        self.lightBox.delegate = self;
        [self presentViewController:self.lightBox animated:YES completion:nil];
    }
    
}

- (void) displayMoreInfoVC:(PXEPlayerMoreInfoViewController *)moreInfoVC
{
    if(!self.moreInfo)
    {
        // Only open one instance of MORE INFO
        self.moreInfo = moreInfoVC;
        self.moreInfo.delegate = self;
        [self presentViewController:self.moreInfo animated:YES completion:nil];
    }
}

/**
  This method get invoked when page content rendered on to the screen
  @param NSString, loadedPage is a reference of loaded page
 */

- (void) pageContentDidLoad:(NSString*)loadedPage
{
    DLog(@"loadedPage: %@", loadedPage);
    NSString *curPage = [self.pageManager getVirtualPage];
    DLog(@"curPage: %@", curPage);
    if([curPage isEqualToString:loadedPage])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_LOADED object:nil userInfo:@{PXEPLAYER_LOADED_PAGE : loadedPage}];
        [self notifyForPageChange];
       
        //TODO: See if there is a way to illiminate this - BT
        PxePlayerPageContentViewController *contentVC = [self getContentViewController];
       // NSLog(@"\n\n\n%@\n%@\n\n\n",[[self pageManager] getCurrentPage],[self.pageManager getVirtualPage]);
        
        if(![self.loadingView isHidden])
        {
            [self.loadingView removeView];
        }
        if (![contentVC.view superview] )
        {
            //TODO: set datasource of viewcontroller but not both
            [self.pxePageViewController.view addSubview:contentVC.view];
        }
        else
        {
            DLog(@"%@ SubViews: %lu",self.pxePageViewController.view, (unsigned long)[[self.pxePageViewController.view subviews] count]);
            //TODO: Figure out why this would ever happen.
            if([[self.pxePageViewController.view subviews] count] > 1)
            {
                [[[self.pxePageViewController.view subviews] objectAtIndex:1] removeFromSuperview];
            }
        }
    }
}

/**
  This method get invoked when page content currently rendering on to the screen
  @param NSString, loadingPage is a reference of currently loading page
 */
-(void)pageContentLoading:(NSString*)loadingPage
{
    NSString *curPage = [self.pageManager getVirtualPage];
    
    if([curPage isEqualToString:loadingPage])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_LOADING object:nil userInfo:@{PXEPLAYER_LOADED_PAGE : loadingPage}];
    }
}

- (NSString*) getCurrentPageTitle
{
   return [self.pageManager getCurrentPageTitle];
}

- (NSString*) getCurrentPageId
{
    return [self.pageManager getCurrentPageId];
}

- (NSString *) getCurrentContextId
{
    return self.dataInterface.contextId;
}

- (PxePlayerDataInterface *)getCurrentDataInterface
{
    // Make sure assetId is correct
    NSString *curPage = [self.pageManager getVirtualPage];
    DLog(@"curPage: %@", curPage);
    NSString *assetId = [[PxePlayerDataManager sharedInstance] getAssetForPage:curPage contextId:self.dataInterface.contextId];
    if (assetId)
    {
        self.dataInterface.assetId = assetId;
    }
    
    DLog(@"dataInterface.assetId: %@", self.dataInterface.assetId)
    return self.dataInterface;
}

/**
  This method get invoked when page content loading failed
  @param NSString, pageURL is a reference of failed page
 */
-(void)pageLoadFailed:(NSString*)pageURL
{
    [self.loadingView removeView];
    NSString *curPage = [self.pageManager getVirtualPage];
    if([curPage isEqualToString:pageURL])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED object:nil userInfo:@{PXEPLAYER_FAILED_PAGE : pageURL}];
    }
}

-(void) refreshPageWithUrl:(NSString*)url //Line 1870
{
    DLog(@"Refreshing page with url: %@", url);
    
    self.isPageRefreshing = YES;
    
    NSError *refreshError;
    [self gotoPageWithPageURL:url error:&refreshError];
    
    if (refreshError)
    {
        [self reportRefreshPageErrorForCode:PxePlayerNavigationError];
        self.isPageRefreshing = NO;
    }
}

-(void) reportRefreshPageErrorForCode:(PxePlayerErrorCode)errorCode
{
    NSError *pageError = [PxePlayerError errorForCode:errorCode];
    NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Unable to refresh current page.",@"Unable to refresh current page"),
                                NSUnderlyingErrorKey : pageError};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                        object:nil
                                                      userInfo:errorDict];
}

-(void)annotateState:(BOOL)canShow
{
    [[PxePlayer sharedInstance] setAnnotateState:canShow];
    
    NSString *curPage = [self.pageManager getVirtualPage];
    PxePlayerPageContentViewController *contentController = [self.pagesContainer objectForKey:curPage];
    [contentController  annotateState];
}

/**
  Customise the font size of the pages in the book
  @param int, fontSize is a reference to set the size of the font to be applied on the page text's
 */
-(void)setBookPageFontSize:(NSInteger)fontSize
{
    DLog(@"incoming font size: %ld", (long)fontSize);
    [self setPageFontSize:fontSize];

    PxePlayerPageContentViewController *contentVC = [self getContentViewController];
    if(contentVC)
    {
        [contentVC updateFont];
    }
    
    PxePlayerPageContentViewController *nextContentVC = [self getNextContentViewController];
    if(nextContentVC)
    {
        [nextContentVC updateFont];
    }
    PxePlayerPageContentViewController *prevContentVC = [self getPreviousContentViewController];
    if(prevContentVC)
    {
        [prevContentVC updateFont];
    }
}

/**
  Customise the theme of the pages in the book
  @param NSString, theme is a reference to set the theme of the pages in book, example sepia,night-mode etc ...
  @see PxePlayerPageContentViewController
 */
-(void)setBookPageTheme:(NSString*)theme
{
    [self setPageTheme:theme];

    PxePlayerPageContentViewController *contentVC = [self getContentViewController];
    if(contentVC)
    {
        [contentVC updateTheme];
    }
    
    PxePlayerPageContentViewController *nextContentVC = [self getNextContentViewController];
    if(nextContentVC)
    {
        [nextContentVC updateTheme];
    }
    PxePlayerPageContentViewController *prevContentVC = [self getPreviousContentViewController];
    if(prevContentVC)
    {
        [prevContentVC updateTheme];
    }
}

/**
  Set the annotation label to rendered on the screen
  @param NSString, label is a reference to jump to the particular page
  @see PxePlayerPageContentViewController
 */
-(void)setAnnotationLabel:(NSString*)label
{
    NSString * pageUrl = [self.pageManager getVirtualPage];
    
    NSArray *viewControllers = (NSArray*)[self.pxePageViewController viewControllers];
    if([viewControllers count])
    {
        NSInteger srchIndx = [viewControllers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [[(PxePlayerPageContentViewController*)obj getPageRelativeURL] isEqualToString:pageUrl];
        }];
        
        if (srchIndx != NSNotFound)
        {
            PxePlayerPageContentViewController *contentController = viewControllers[srchIndx];
            [contentController setAnnotationLabel:label];
        }
    }
}

/**
  Returns the auto scale property value of UIWebView which renders the page text
  @return NSUInteger, scalePageToFit property value
 */
-(BOOL)scalePageToFit
{
    return self.scalePage;
}

- (PxePlayerPageContentViewController *)getContentViewController
{
    NSString *curPage = [self.pageManager getCurrentPage];
    return [self.pagesContainer objectForKey:curPage];
}

- (PxePlayerPageContentViewController *)getNextContentViewController
{
    NSString *nextPage = [self.pageManager nextPage];
    return [self.pagesContainer objectForKey:nextPage];
}

- (PxePlayerPageContentViewController *)getPreviousContentViewController
{
    NSString *prevPage = [self.pageManager nextPage];
    return [self.pagesContainer objectForKey:prevPage];
}

- (void) lightboxDidClose
{
    self.lightBox.delegate = nil;
    self.lightBox = nil;
}

- (void) moreInfoDidClose
{
    self.moreInfo.delegate = nil;
    self.moreInfo = nil;
}

- (BOOL) appSupportsPrintPages
{
    DLog(@"self.pageViewOptions.printPageSupport: %@", self.pageViewOptions.printPageSupport?@"YES":@"NO");
    return self.pageViewOptions.printPageSupport;
}

- (PxePlayerLabelProvider *) getLabelProvider
{
    return self.pageViewOptions.labelProvider;
}

- (void) setLabelProvider:(PxePlayerLabelProvider *)labelProvider
{
    self.pageViewOptions.labelProvider = labelProvider;
}

-(NSString*)getPageTheme
{
    DLog(@"getPageTheme %@", self.pageViewOptions.bookPageTheme);
    return self.pageViewOptions.bookPageTheme;
}

-(void)setPageTheme:(NSString*)theme
{
    self.pageViewOptions.bookPageTheme = theme;
    DLog(@"setPageTheme %@", theme);
}

-(NSInteger)getPageFontSize
{
    return (NSInteger)self.pageViewOptions.bookPageFontSize;
}

-(void)setPageFontSize:(NSInteger)fontSize
{
    self.pageViewOptions.bookPageFontSize = fontSize;
    DLog(@"setting FontSize: %ld", (long)fontSize);
    DLog(@"bookPageFontSize: %ld", (long)self.pageViewOptions.bookPageFontSize);
}

- (NSMutableArray*) getHostWhiteList
{
    return self.pageViewOptions.hostWhiteList;
}

- (NSMutableArray*) getHostExternalList
{
    return self.pageViewOptions.hostExternalList;
}

-(BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
    DLog(@"PageViewAccessibility Scroll: %ld", (long)direction);
    NSError *scrollError;
    if (direction == UIAccessibilityScrollDirectionRight)
    {
        //Previous Page
        DLog(@"accessibilityScroll: Previous PAGE");
        [self scrollPageToDirection:NO error:&scrollError];
        return YES;
    }
    else if (direction == UIAccessibilityScrollDirectionLeft)
    {
        //Next Page
        DLog(@"accessibilityScroll: Next PAGE");
        [self scrollPageToDirection:YES error:&scrollError];
        return YES;
    }
    if (scrollError)
    {
        DLog(@"accessibilityScroll: ERROR: %@", scrollError);
    }
    
    return NO;
}

@end

