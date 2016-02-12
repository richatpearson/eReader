//
//  PxeReaderViewController.m
//  PxePlayerApp
//
//  Created by Satyanarayana SVV on 10/30/13.
//  Copyright (c) 2013 HappiestMinds. All rights reserved.
//

#import "PxeReaderSampleViewController.h"
#import "PxePlayerUIKit.h"
#import "PxePlayerKit.h"
#import "PxePlayer.h"
#import "Reachability.h"
#import "PxeReaderBookmarkListViewController.h"
#import "PxeReaderGlossaryViewController.h"
#import "PxeReaderSearchViewController.h"
#import "PxePlayerAnnotationsTypes.h"
#import "PxeReaderSamplePageControlViewController.h"
#import "PxePlayerPageViewOptions.h"
#import "PxePlayerUIEvents.h"
#import "PxePlayerUIConstants.h"
#import "PxePlayerLoadingView.h"
#import "PxeReaderSampleToastView.h"
#import "PxeReaderTOCViewController.h"

@interface PxeReaderSampleViewController () <PxePlayerPageViewDelegate>

    @property (nonatomic, strong) PxePlayer* pxePlayer;
    @property (nonatomic, strong) NSString *pageUrl;

    @property (nonatomic, strong) PxePlayerPageViewController *pageViewController;
    @property (nonatomic, strong) PxePlayerLoadingView *loadingView;

    @property (nonatomic, strong) PxeReaderSampleToolbarViewController *toolbarViewController;
    @property (nonatomic, strong) PxeReaderSamplePageControlViewController *pageControlController;

    @property (nonatomic, strong) PxeReaderMasterPopoverViewController *currentPopover;

    @property (nonatomic, strong) PxeReaderAnnotationsViewController *annotationsVC;

    /**
     Menu View Controller
     */
    @property (nonatomic, strong) PxeReaderSampleMenuViewController *menuViewController;
    /**
     Popover for fontsthemes
     */
    @property (nonatomic, strong) UIPopoverController *fontsThemesPopover;

@end

enum ALERT_TAGS
{
    ADD_BOOKMARK_TAG,
    EDIT_BOOKMARK_TAG,
    DELETE_BOOKMARK_TAG,
    BOOKMARK_NO_TITLE_TAG,
    ERROR_TAG,
};

enum
{
    PXE_READER_PAGE_NAV_LEFT,
    PXE_READER_PAGE_NAV_RIGHT,
};


@implementation PxeReaderSampleViewController


#pragma mark -Private methods

- (void) showError:(NSString*)error withTitle:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, @"Attention") message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil];
    [alert show];
}

-(void)showError:(NSString*)error withTag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention", @"Alert title") message:error delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil];
    alert.tag = ERROR_TAG;
    [alert show];
}

//this is called from the PxePlayerPageContentViewController when the page loads
-(void)receiveLoadNotifications:(NSNotification*)notification
{
    NSDictionary *dic = (NSDictionary*)notification.userInfo;
    self.pageUrl = dic[PXEPLAYER_LOADED_PAGE];
    NSLog(@"receiveLoadNotifications: %@", dic);
    NSLog(@"self.pageURL: %@", self.pageUrl);
    [self.pxePlayer checkBookmarkWithURL:self.pageUrl withCompletionHandler:^(PxePlayerCheckBookmark *bookmarkStatus, NSError *error)
     {
         NSLog(@"bookmarkStatus: %@", bookmarkStatus);
         NSLog(@"bookmark self.pageURL: %@", self.pageUrl);
         
         if ([bookmarkStatus.forPageUrl isEqualToString:self.pageUrl])
         {
             if([bookmarkStatus.isBookmarked boolValue])
             {
                 [self.toolbarViewController setBookmarked:YES];
                 NSLog(@"BOOKMARK SYMBOL IN TOOLBAR SHOULD BE WHITE.");
             }
             else
             {
                 [self.toolbarViewController setBookmarked:NO];
             }
         }
         
     }];
    
    [self.pxePlayer getAnnotationsForPage:self.pageUrl withCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error)
     {
         if(!error)
         {
             NSDictionary *annotations = [[annotationsTypes combinedAnnotationsByURI] contentsAnnotations];
             if (annotations && [annotations count] > 0)
             {
                 NSLog(@"ANNOTATIONS FOR PAGE: %@", self.pageUrl);
                 NSLog(@"Annotations: %@", annotations);
             }
         }
         else
         {
             //Pop up alert
             PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Annotations Error", @"Error Retrieving Annotations") message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil, nil];
             [alert setDelegate:self];
             [alert setAlertViewStyle:UIAlertViewStyleDefault];
             [alert show];
         }
     }];
}

-(void)receiveLoadFailure:(NSNotification*)notification
{
    NSString *loadPageErrorMsg = [notification.userInfo objectForKey:NSLocalizedDescriptionKey];
    NSLog(@"PageLoadError: %@", notification.userInfo);
    if (loadPageErrorMsg)
    {
        //Pop up alert
        PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Page Load Error", @"Page Load Error")
                                                                      message:loadPageErrorMsg
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                            otherButtonTitles:nil, nil];
        [alert setDelegate:self];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
}

#pragma mark - Self methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toolbarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"toolbarId"];
    [self addChildViewController:self.toolbarViewController];
    CGRect r1 = self.toolbarViewController.view.frame;
    r1.origin.x = 0;
    r1.origin.y = 0;
    r1.size.height = 50;
    self.toolbarViewController.view.frame = r1;
    [self.toolbarViewController setToolbarDelegate:self];
    
    self.pageControlController = [self.storyboard instantiateViewControllerWithIdentifier:@"controlId"];
    [self addChildViewController:self.pageControlController];
    CGRect r2 = self.pageControlController.view.frame;
    r2.origin.x = 0;
    r2.origin.y = 0;
    [self.pageControlController setControlDelegate:self];
    self.pageControlController.view.frame = r2;
    
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuId"];
    [self addChildViewController:self.menuViewController];
    self.menuViewController.view.hidden = YES;
    
    self.menuViewController.menuDelegate = self;
    
    [self.view addSubview:self.pageControlController.view];
    [self.view addSubview:self.toolbarViewController.view];
    [self.view addSubview:self.menuViewController.view];
    
    [self showLoaderInParent:YES];
    
    self.pxePlayer = [PxePlayer sharedInstance];
    
    NSLog(@"DataInterface: %@", self.dataInterface);

    [self.pxePlayer updateDataInterface:self.dataInterface onComplete:^(BOOL success, NSError *updateError) {
        NSLog(@"COMING OUT OF THE UPDATE DATA INTERFACE NOW..");
        
        if(success)
        {
            // PageViewOption settings
            PxePlayerPageViewOptions *pageViewOptions = [self buildPageViewOptions];
            
            self.pageViewController = [self.pxePlayer renderWithOptions:pageViewOptions];
            self.pageViewController.delegate = self;
            
            self.pageViewController.view.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-88);
            self.pageViewController.view.frame = CGRectInset(self.pageViewController.view.frame, 0,0);
            [self addChildViewController:self.pageViewController];
            [self.pageViewController didMoveToParentViewController:self];
            [self.view addSubview:self.pageViewController.view];
            
            NSLog(@"RECEIVED NOTIFICATION FOR PXEPLAYER_PAGELOADED: %@", self.pageUrl);
            
            float menuWidth = 65.0;
            float menuHeight = self.pageViewController.view.frame.size.height;
            float menuX = self.view.frame.origin.x + self.view.frame.size.width - menuWidth;
            float menuY = self.pageViewController.view.frame.origin.y;
            
            NSLog(@"MenuWidth: %f", menuWidth);
            NSLog(@"MenuHeight: %f", menuHeight);
            NSLog(@"MenuX: %f", menuX);
            NSLog(@"MenuY: %f", menuY);
            
            CGRect menuRect = CGRectMake(menuX, menuY, menuWidth, menuHeight);
            self.menuViewController.view.frame = menuRect;

        }
        else
        {
            //this is anytime a book doesn't load for what ever reason
            [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_INTERNET_WEAK object:nil userInfo:nil];
            
            PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Failure Loading Book", @"Failure Loading Book")
                                                                          message:updateError.localizedDescription
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                                otherButtonTitles:nil, nil];
            alert.tag = ERROR_TAG;
            [alert setDelegate:self];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
        [self showLoaderInParent:NO];
    }];
}

- (PxePlayerPageViewOptions*) buildPageViewOptions
{
    PxePlayerPageViewOptions *pageViewOptions = [PxePlayerPageViewOptions new];
    pageViewOptions.shouldAllowPageSwipe = YES;
    pageViewOptions.transitionStyle = UIPageViewControllerTransitionStylePageCurl;
    pageViewOptions.scalePage = NO;
    pageViewOptions.printPageSupport = [[self.bookData objectForKey:@"printPageSupport"] isEqualToString:@"false"]?NO:YES;
    PxePlayerLabelProvider *labelProvider = [[PxePlayerLabelProvider alloc] initWithDelegate:self];
    pageViewOptions.labelProvider = labelProvider;
    if ([self.bookData objectForKey:@"masterPlaylist"])
    {
        [pageViewOptions addHostToExternalList:@"etext.pearsonxl.com"];
    }
    
    if ([self.bookData objectForKey:@"useDefaultFontAndTheme"])
    {
        pageViewOptions.useDefaultFontAndTheme = [[self.bookData objectForKey:@"useDefaultFontAndTheme"] isEqualToString:@"false"]?NO:YES;
    }
    NSString *optionsTheme;
    NSInteger optionsFontSize;
    // Set and Store Font and Theme User Defaults
    if (pageViewOptions.useDefaultFontAndTheme)
    {
        optionsFontSize = PXEPLAYER_DEFAULT_FONTSIZE;
        optionsTheme = PXEPLAYER_DEFAULT_THEME;
    }
    else
    {
        optionsFontSize = [self retrieveUserDefaultFontSize];
        optionsTheme = [self retrieveUserDefaultTheme];
        
        [self storeUserDefaultFontSize:optionsFontSize];
        [self storeUserDefaultTheme:optionsTheme];
    }
    
    [pageViewOptions setBookPageFontSize:optionsFontSize];
    [pageViewOptions setBookPageTheme:optionsTheme];
    
    return pageViewOptions;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadNotifications:) name:PXEPLAYER_PAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadFailure:) name:PXEPLAYER_PAGE_FAILED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentStartedScrolling:) name:PXE_ContentStartedScrolling object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentStoppedScrolling:) name:PXE_ContentStoppedScrolling object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentScrolling:) name:PXE_ContentScrolling object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationNotifications:) name:PXE_Navigation object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(widgetNotifications:) name:PXE_WidgetEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notebookNotifications:) name:PXE_NotebookEvent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationError:) name:PXEPLAYER_ANNOTATION_MAX_CHAR object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXEPLAYER_PAGE_LOADED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXEPLAYER_PAGE_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXE_ContentStartedScrolling object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXE_ContentStoppedScrolling object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXE_ContentScrolling object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXE_Navigation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXE_WidgetEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXE_NotebookEvent object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXEPLAYER_ANNOTATION_MAX_CHAR object:nil];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)dealloc
{
    self.pxePlayer = nil;
    self.pageViewController = nil;
    self.pageUrl = nil;
}

/**
 An action triggered from the PxeReader to show loading view on implemented view controller view
 @param BOOL, isShow is an boolean value to show/hide loading view
 */
-(void)showLoaderInParent:(BOOL)isShow
{
    //LOG_FUNCTION_CALL;
    if(isShow)
    {
        if(!self.loadingView)
        {
            self.loadingView = [PxePlayerLoadingView loadingViewInView:self.view];
            self.loadingView.accessibilityLabel = NSLocalizedString(@"Loading", nil);
        }
    }
    else
    {
        if(self.loadingView)
        {
            NSLog(@"loading remove 3");
            [self.loadingView removeView];
        }
        self.loadingView = nil;
    }
}
#pragma mark - Events
-(void)bookshelfEventHandler:(id)sender
{
    if (self.pcController)
    {
        [self.pcController dismissPopoverAnimated:YES];
    } else {
        [self dismissCurrentPopover];
    }
    [self.pageViewController cleanPageViewContent];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addBookmarkTitle
{
    NSLog(@"ENTERING BOOKMARK TITLE");
    //Pop up asking to enter bookmark title
    PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Bookmark Title", @"Bookmark  name")
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel title")
                                                        otherButtonTitles:NSLocalizedString(@"Add", @"Add title"), nil];
    alert.tag = ADD_BOOKMARK_TAG;
    [alert setDelegate:self];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

-(void)addBookmark:(NSString*)title
{
    NSLog(@"ADD BOOKMARK: title");
    //initiate AddBookmark web-service call
    __unsafe_unretained PxeReaderSampleViewController *SELF = self;
    [self.pxePlayer addBookmarkWithTitle:title andURL:self.pageUrl withCompletionHandler:^(PxePlayerBookmark *bookmark, NSError *error)
     {
         if(error)
         {
             [SELF showError:[error localizedDescription] withTitle:NSLocalizedString(@"Bookmark Error", @"Bookmark Error")];
         }
         else
         {
             //update the bookmark image
             [SELF setBookmarked:YES];
         }
     }];
}

-(void)deleteBookmark
{
    //initiate deleteBookmark web-service call
    [self.pxePlayer deleteBookmarkWithURL:self.pageUrl withCompletionHandler:^(PxePlayerBookmark *bookmark, NSError *error)
     {
         if (error)
         {
             [self showError:[error localizedDescription] withTitle:@"Error message"];
         }
         else
         {
             //update the bookmark image
             [self setBookmarked:NO];
         }
     }];
}

-(void)setBookmarked:(BOOL)isBookmarked
{
    if(isBookmarked)
    {
        [self.toolbarViewController setBookmarked:YES];
    }
    else
    {
        [self.toolbarViewController setBookmarked:NO];
    }
}

#pragma mark - Toolbar Delegates
-(void)bookmarkEventHandler:(id)sender
{
    [self.pxePlayer checkBookmarkWithURL:self.pageUrl
                   withCompletionHandler:^(PxePlayerCheckBookmark *bookmarkStatus, NSError *error)
     {
         if(error)
         {
             [self showError:error.localizedDescription withTitle:@"Error"];
         }
         else
         {
             NSLog(@"bookmarkStatus.forPageUrl: %@", bookmarkStatus.forPageUrl);
             NSLog(@"self.pageUrl: %@", self.pageUrl);
             if ([bookmarkStatus.forPageUrl isEqualToString:self.pageUrl])
             {
                 NSLog(@"bookmarkStatus.isBookmarked: %@", bookmarkStatus.isBookmarked);
                 if([bookmarkStatus.isBookmarked boolValue])
                 {
                     //add bookmark
                     [self deleteBookmark];
                 }
                 else {
                     //delete bookmark
                     [self addBookmarkTitle];
                 }
             }
         }
     }];
}

-(void)bookmarksEventHandler:(id)sender
{
    //load bookmarks
    [self showLoader];
    [[PxePlayer sharedInstance] getBookmarksWithCompletionHandler:^(PxePlayerBookmarks *bookmarks, NSError *error)
    {
        if(!error && bookmarks.bookmarks.count > 0)
        {
            PxeReaderBookmarkListViewController *bVC = [[PxeReaderBookmarkListViewController alloc] init];
            bVC.bookmarks = bookmarks.bookmarks;
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,40,320,440) style:UITableViewStylePlain];
            //Remember to set the table view delegate and data provider
            tableView.delegate = bVC;
            tableView.dataSource = bVC;
            bVC.table = tableView;
            bVC.delegate = self;
            
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
                self.pcController=[[UIPopoverController alloc] initWithContentViewController:bVC];
                
                [self.pcController presentPopoverFromRect:[self getRelativeRectFromMenuButton:(UIButton *)sender]
                                                   inView:self.view
                                 permittedArrowDirections:UIPopoverArrowDirectionRight
                                                 animated:YES];
            }
            else
            {
                self.currentPopover = bVC;
                [self presentViewController:bVC animated:YES completion:nil];
            }
            
            for(PxePlayerBookmark *bookmark in bookmarks.bookmarks)
            {
                NSLog(@"BOOKMARK: %@",bookmark);
            }
            
        }else{
            
            //Pop up asking to enter bookmark title
            PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"No Bookmarks", @"No Bookmarks Found")
                                                                          message:NSLocalizedString(@"No Bookmarks found for this book.", @"No Bookmarks found for this book.")
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                                otherButtonTitles:nil, nil];
            [alert setDelegate:self];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
            
        }
        [self hideLoader];
    }];
}

- (void) bookmarkSelectEventWithURI:(NSString *)uri
{
    NSLog(@"bookmarkSelectEventWithURI: %@", uri);
    if(self.pageViewController)
    {
        NSError *bookmarkError;
        [self.pageViewController gotoPageWithPageURL:uri error:&bookmarkError];
    }
}

-(void)annotationsEventHandler:(id)sender
{
    //load annotations
    [self showLoader];
    [[PxePlayer sharedInstance] getAnnotationsWithCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error) {
        if(!error)
        {
            NSDictionary *annotations = [[annotationsTypes combinedAnnotationsByURI] contentsAnnotations];
            NSLog(@"Annotations: %@", annotations);
            if (annotations && [annotations count] > 0)
            {
                self.annotationsVC = [[PxeReaderAnnotationsViewController alloc] init];
                self.annotationsVC.annotations = annotations;
                self.annotationsVC.delegate = self;
                UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,40,320,440) style:UITableViewStylePlain];
                //Remember to set the table view delegate and data provider
                tableView.delegate = self.annotationsVC;
                tableView.dataSource = self.annotationsVC;
                self.annotationsVC.table = tableView;
                if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                {
                    self.pcController=[[UIPopoverController alloc] initWithContentViewController:self.annotationsVC];
                    
                    [self.pcController presentPopoverFromRect:[self getRelativeRectFromMenuButton:(UIButton *)sender]
                                                       inView:self.view
                                     permittedArrowDirections:UIPopoverArrowDirectionRight
                                                     animated:YES];
                }
                else{
                    [self presentViewController:self.annotationsVC animated:YES completion:nil];
                }
            }
            else
            {
                //Pop up alert
                PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"No Annotations", @"No Annotations")
                                                                              message:NSLocalizedString(@"No Annotations found for this book.", @"No Annotations found for this book.")
                                                                             delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                                    otherButtonTitles:nil, nil];
                [alert setDelegate:self];
                [alert setAlertViewStyle:UIAlertViewStyleDefault];
                [alert show];
            }
        } else {
            //Pop up alert
            PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Annotations Error", @"Error Retrieving Annotations") message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil, nil];
            [alert setDelegate:self];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
        [self hideLoader];
    }];
}

- (void) annotationSelectEventWithAnnotation:(PxePlayerAnnotation*)annotation
{
    NSLog(@"annotationSelectEventWithURI: %@ and annot id: %@", annotation.uri, annotation.annotationDttm);
    if (self.pageViewController)
    {
        [[self.annotationsVC presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        
        [self.pageViewController jumpToAnnotation:annotation];
    }
}

-(void)glossaryEventHandler:(id)sender
{
    [self showLoader];
    [[PxePlayer sharedInstance] getGlossaryWithCompletionHandler:^(NSArray *array, NSError *error) {
        if(!error)
        {
            if ([array count] > 0)
            {
                PxeReaderGlossaryViewController *gvc = [[PxeReaderGlossaryViewController alloc] init];
                [gvc buildGlossary:array];
                UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,40,320,440) style:UITableViewStylePlain];
                //Remember to set the table view delegate and data provider
                tableView.delegate = gvc;
                tableView.dataSource = gvc;
                gvc.table = tableView;
                if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                {
                    self.pcController=[[UIPopoverController alloc] initWithContentViewController:gvc];
                    
                    [self.pcController presentPopoverFromRect:[self getRelativeRectFromMenuButton:(UIButton *)sender]
                                                       inView:self.view
                                     permittedArrowDirections:UIPopoverArrowDirectionRight
                                                     animated:YES];
                }
                else{
                    [self presentViewController:gvc animated:YES completion:nil];
                }
            }
            else
            {
                //Pop up alert
                PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"No Glossary", @"No Glossary")
                                                                              message:NSLocalizedString(@"No glossary terms found for this book.", @"No glossary terms found for this book.")
                                                                             delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                                    otherButtonTitles:nil, nil];
                [alert setDelegate:self];
                [alert setAlertViewStyle:UIAlertViewStyleDefault];
                [alert show];
            }
        }
        else
        {
            //Pop up alert
            PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Glossary Error", @"Glossary Error")
                                                                          message:error.localizedDescription
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                                otherButtonTitles:nil, nil];
            [alert setDelegate:self];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
        [self hideLoader];
    }];
}


-(void)searchEventHandler:(id)sender
{
    NSLog(@"SEARCHING...");
    PxeReaderSearchViewController *svc = [[PxeReaderSearchViewController alloc] init];
    svc.delegate = self;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.pcController=[[UIPopoverController alloc] initWithContentViewController:svc];
        
        [self.pcController presentPopoverFromRect:[self getRelativeRectFromMenuButton:(UIButton *)sender]
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionRight
                                         animated:YES];
    }
    else{
        [self presentViewController:svc animated:YES completion:nil];
    }
}

- (void) searchSelectEventWithURI:(NSString *)uri andHighlights:(NSArray*)highlights
{
    NSLog(@"searchSelectEventWithURI: %@", uri);
    NSLog(@"highlights: %@", highlights);
    if(self.pageViewController)
    {
        NSError *goToPageError;
        [self.pageViewController gotoPageWithPageURL:uri andHighlightLabels:highlights error:&goToPageError];
    }
}

- (void) tocEventHandler:(id)sender
{
    NSLog(@"SHOW TOC"); 
    
    PxeReaderTOCViewController *toc =[[PxeReaderTOCViewController alloc] initWithInitialParentId:@"root"
                                                                                    displayTitle:@"Table of Contents"];
    toc.delegate = self;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.pcController=[[UIPopoverController alloc] initWithContentViewController:toc];
        
        [self.pcController presentPopoverFromRect:[self getRelativeRectFromMenuButton:(UIButton *)sender]
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionRight
                                         animated:YES];
    }
    else
    {
        [self presentViewController:toc animated:YES completion:nil];
    }
}

- (void) tocSelectionEventWithURI:(NSString*)uri
{
    NSLog(@"GOT THE URI: %@", uri);
    if(self.pageViewController)
    {
        NSError *gotoError;
        [self.pageViewController gotoPageWithPageURL:uri error:&gotoError];
        if (gotoError)
        {
            NSLog(@"gotoError: %@", gotoError);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Jumping to page error"
                                                            message:gotoError.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void) customBasketEventHandler:(id)sender
{
    NSLog(@"SHOW CustomBasket");
    
    PxeReaderTOCViewController *customBasket =[[PxeReaderTOCViewController alloc] initWithInitialParentId:@"root"
                                                                                             displayTitle:@"Custom Basket"];
    customBasket.delegate = self;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.pcController=[[UIPopoverController alloc] initWithContentViewController:customBasket];
        
        [self.pcController presentPopoverFromRect:[self getRelativeRectFromMenuButton:(UIButton *)sender]
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionRight
                                         animated:YES];
    }
    else
    {
        [self presentViewController:customBasket animated:YES completion:nil];
    }
}



- (void) menuEventHandler:(id)sender
{
    self.menuViewController.view.hidden = NO;
    
    if (self.pageViewController.view.frame.origin.x >= 0)
    {
        CGRect newFrame = self.pageViewController.view.frame;
        newFrame.origin.x -= 65;
        
        // Add view to the right of this view
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.pageViewController.view.frame = newFrame;
                         }];
    }
    else
    {
        CGRect newFrame = self.pageViewController.view.frame;
        newFrame.origin.x = 0;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.pageViewController.view.frame = newFrame;
                         }];
    }
    
}

- (CGRect) centerFrameRect:(CGSize)viewFrameSize
{
    float xPos = self.view.frame.origin.x + (self.view.frame.size.width - viewFrameSize.width)/2;
    float yPos = self.view.frame.origin.y + (self.view.frame.size.height - viewFrameSize.height)/2;
    
    return CGRectMake(xPos, yPos, viewFrameSize.width, viewFrameSize.height);
}



#pragma mark - Controls Delegate
-(void)rightNavEventHandler:(id)sender{
    NSLog(@"rightNavEventHandler");
    if(self.pageViewController)
    {
        NSError *pageTurnError;
        [self.pageViewController scrollPageToDirection:PXE_READER_PAGE_NAV_RIGHT error:&pageTurnError];
        NSLog(@"pageTurnError: %@", pageTurnError);
        if (pageTurnError)
        {
            NSLog(@"rightNavEventHandler PAGE TURN ERROR: %@", pageTurnError);
        }
    }
}

-(void)leftNavEventHandler:(id)sender{
    
    if(self.pageViewController)
    {
        NSError *pageTurnError;
        [self.pageViewController scrollPageToDirection:PXE_READER_PAGE_NAV_LEFT error:&pageTurnError];
        NSLog(@"pageTurnError: %@", pageTurnError);
        if (pageTurnError)
        {
            NSLog(@"rightNavEventHandler PAGE TURN ERROR: %@", pageTurnError);
        }
    }
}

-(void)jumpPageEventHandler:(id)sender{
    
    UITextField *textField = (UITextField*)sender;
    NSString *jumpText = [[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([jumpText length])
    {
        [self.pageViewController jumpToPage:[NSNumber numberWithInteger:[jumpText integerValue]]];
    }
}

-(void)jumpToPrintPageEventHandler:(id)sender
{
    UITextField *textField = (UITextField*)sender;
    NSString *printPageNumber = [[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![printPageNumber isEqualToString:@""])
    {
        [self.pageViewController jumpToPrintPage:printPageNumber onComplete:^(BOOL success, NSNumber *digitalPageNumber, NSString *digitalPageURL) {
            if (success)
            {
                NSString *messageTxt = [NSString stringWithFormat:@"digitalPageNumber: %@, digitalPageURL: %@", digitalPageNumber, digitalPageURL];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Jumping to digital page"
                                                                message:messageTxt
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

#pragma mark - Alertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case ERROR_TAG:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case BOOKMARK_NO_TITLE_TAG:
            break;
        case ADD_BOOKMARK_TAG:
        {
            if(buttonIndex != 0)
            {
                if(![[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
                    //web-service call to add bookmark
                    NSString *trimmedTitle = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [self addBookmark:trimmedTitle];
                }
                else
                {
                    [self showError:nil withTitle:@"Bookmark Title Cannot Be Empty"];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void) dismissCurrentPopover
{
    if (self.currentPopover)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        self.currentPopover = nil;
    }
}

- (void) contentStartedScrolling:(NSNotification*)notification
{
    NSLog(@"STARTED SCROLLING");
}

- (void) contentStoppedScrolling:(NSNotification*)notification
{
    NSDictionary *scrollPositionDict = notification.userInfo;
    NSString *scrollPosition = [scrollPositionDict objectForKey:PXEPLAYER_POSITION];
    if (scrollPosition)
    {
        if ([scrollPosition isEqualToString:PXEPLAYER_TOP])
        {
//            NSLog(@"Started from the bottom now we here: %@", scrollPosition);
            UIView *toolbarView = self.toolbarViewController.view;
            UIToolbar *toolBar = self.toolbarViewController.toolBar;
            
            [UIView animateWithDuration:1.0
                             animations:^{
                                    toolbarView.backgroundColor = [UIColor blueColor];
                                    toolBar.barTintColor = [UIColor blueColor];
                             }
                             completion:^(BOOL finished){
                                 if (finished)
                                 {
                                     [UIView animateWithDuration:1.0
                                                      animations:^{
                                                          toolbarView.backgroundColor = [UIColor blackColor];
                                                          toolBar.barTintColor = [UIColor blackColor];
                                                      }
                                                      completion:NULL];
                                 }
                             }];
        }
        else if ([scrollPosition isEqualToString:PXEPLAYER_BOTTOM])
        {
//            NSLog(@"Started from the top now we here: %@", scrollPosition);
            UIView *controlView = self.pageControlController.view;

            [UIView animateWithDuration:1.0
                             animations:^{
                                 controlView.backgroundColor = [UIColor blueColor];
                             }
                             completion:^(BOOL finished){
                                 if (finished)
                                 {
                                     [UIView animateWithDuration:1.0
                                                      animations:^{
                                                          controlView.backgroundColor = [UIColor blackColor];
                                                      }
                                                      completion:NULL];
                                 }
                             }];
        }
    }
//    NSString *scrollDirection = [scrollPositionDict objectForKey:PXEPLAYER_DIRECTION];
//    NSLog(@"SCROLL DIRECTION: %@", scrollDirection);
}

- (void) contentScrolling:(NSNotification*)notification
{
//    NSDictionary *scrollDict = notification.userInfo;
//    NSString *scrollDirection = [scrollDict objectForKey:PXEPLAYER_DIRECTION];
//    NSLog(@"SCROLL DIRECTION: %@", scrollDirection);
}

- (void) navigationNotifications:(NSNotification *)notification
{
    NSLog(@"navigationNotifications navigationNotifications navigationNotifications navigationNotifications");
    NSLog(@"self.pageControlController.previousButton: %@", self.pageControlController.previousButton);
    
    NSDictionary *navDict = notification.userInfo;
    
    NSString *navPage = [navDict objectForKey:@"navigation"];
    NSLog(@"navPage: %@", navPage);
    if(navPage)
    {
        if ([navPage isEqualToString:PXEPLAYER_FIRSTPAGE])
        {
            self.pageControlController.previousButton.hidden = YES;
            self.pageControlController.nextButton.hidden = NO;
        }
        else if ([navPage isEqualToString:PXEPLAYER_LASTPAGE])
        {
            self.pageControlController.previousButton.hidden = NO;
            self.pageControlController.nextButton.hidden = YES;
        }
        else if ([navPage isEqualToString:PXEPLAYER_MIDDLEPAGE])
        {
            self.pageControlController.previousButton.hidden = NO;
            self.pageControlController.nextButton.hidden = NO;
        }
    }
    
    NSLog(@"self.pageControlController.previousButton: %@", self.pageControlController.previousButton);
    NSLog(@"navigationNotifications navigationNotifications navigationNotifications navigationNotifications");
}

- (void) widgetNotifications:(NSNotification *)notification
{
    NSLog(@"widgetNotification received: %@", notification.userInfo);
    NSDictionary *widgetDict = notification.userInfo;
    NSString *widgetString = [NSString stringWithFormat:@"WidgetEvent: {clientId:%@ "
                                                                        "method: %@ "
                                                                        "msgOrigin: %@ "
                                                                        "page: %@ "
                                                                        "type: %@ }",
                                                                        [widgetDict objectForKey:@"clientId"],
                                                                        [widgetDict objectForKey:@"method"],
                                                                        [widgetDict objectForKey:@"msgOrigin"],
                                                                        [widgetDict objectForKey:@"page"],
                                                                        [widgetDict objectForKey:@"type"]];
    
    [PxeReaderSampleToastView showToastInParentView:self.view withText:widgetString withDuration:1.0];
}

- (void) notebookNotifications:(NSNotification *)notification
{
    NSLog(@"noteBookNotification received: %@", notification.userInfo);
    NSDictionary *notebookDict = notification.userInfo;
    NSString *notebookString = [NSString stringWithFormat:@"NotebookEvent: {msgOrigin: %@, "
                              "page: %@, "
                              "prompts: %@, "
                              "triggeredPromptIndex: %@, "
                              "type: %@}",
                              [notebookDict objectForKey:@"msgOrigin"],
                              [notebookDict objectForKey:@"page"],
                              [notebookDict objectForKey:@"prompts"],
                              [notebookDict objectForKey:@"triggeredPromptIndex"],
                              [notebookDict objectForKey:@"type"]];
    
    [PxeReaderSampleToastView showToastInParentView:self.view withText:notebookString withDuration:1.0];
}

- (void) annotationError:(NSNotification *)notification
{
    NSError *errorInfo = [notification.userInfo objectForKey:PXEPLAYER_ERROR];
    NSString *errorString = errorInfo.localizedDescription;
    
    [self showError:errorString withTitle:@"Attention"];
}

- (void) showLoader
{
    if (!self.loadingView)
    {
        self.loadingView = [PxePlayerLoadingView loadingViewInView:self.view];
    }
    self.loadingView.alpha = 0.25;
    [self.loadingView setHidden:NO];
}

- (void) hideLoader
{
    NSLog(@"hideLoader: %@", self.loadingView);
    if (self.loadingView)
    {
        self.loadingView.alpha = 1.0;
        [self.loadingView setHidden:YES];
    }
}

- (void) searchInProgress
{
    [self showLoader];
}

- (void) searchCompleted
{
    [self hideLoader];
}

#pragma mark FONTS AND THEMES
-(void) settingsEventHandler:(id)sender
{
    if(!self.fontThemeVC)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
        
        self.fontThemeVC = [storyboard instantiateViewControllerWithIdentifier:@"FontsThemes"];
        self.fontThemeVC.delegate = self;
    }

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.pcController=[[UIPopoverController alloc] initWithContentViewController:self.fontThemeVC];
        [self.pcController presentPopoverFromRect:[self getRelativeRectFromMenuButton:(UIButton *)sender]
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionRight
                                         animated:YES];
    }
    else
    {
        [self presentViewController:self.fontThemeVC animated:YES completion:nil];
    }
}

- (void) fontsThemesDidClose
{
    self.fontThemeVC.delegate = nil;
    self.fontThemeVC = nil;
}

- (void) changeFontSize:(NSString*)direction
{
    NSLog(@"changeFontSize: %@", direction);
    if(self.pageViewController)
    {
        NSInteger currentFontSize = [self.pageViewController getPageFontSize];
        NSInteger newFontSize = currentFontSize;
        NSLog(@"currentFontSize: %ld", (long)currentFontSize);
        if ([direction isEqualToString:@"decrease"])
        {
            NSLog(@"DECREASING");
            if (currentFontSize > 10)
            {
                newFontSize = currentFontSize-1;
            }
        }
        if ([direction isEqualToString:@"increase"])
        {
            NSLog(@"INCREASING");
            if (currentFontSize < 28)
            {
                newFontSize = currentFontSize+1;
            }
        }
        NSLog(@"newFontSize: %ld", (long)newFontSize);
        [self.pageViewController setBookPageFontSize:newFontSize];
        [self storeUserDefaultFontSize:newFontSize];
    }
}

- (void) changeTheme:(NSString*)theme
{
    NSLog(@"changeTheme: %@", theme);
    if(self.pageViewController)
    {
        [self.pageViewController setBookPageTheme:theme];
        [self storeUserDefaultTheme:theme];
    }
}

- (void) storeUserDefaultTheme:(NSString*)theme
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:theme forKey:@"theme"];
    [defaults synchronize];
    
    NSLog(@"Theme Data saved");
}

- (void) storeUserDefaultFontSize:(NSInteger)fontSize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:fontSize forKey:@"fontSize"];
    [defaults synchronize];
    
    NSLog(@"Font Data saved: %lu", (long)fontSize);
}

- (NSString*)retrieveUserDefaultTheme
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *theme = [defaults objectForKey:@"theme"];
    if(!theme)
    {
        theme = PXEPLAYER_DEFAULT_THEME;
    }
    return theme;
}

- (NSInteger)retrieveUserDefaultFontSize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger fontSize = PXEPLAYER_DEFAULT_FONTSIZE;;
    if([defaults integerForKey:@"fontSize"])
    {
        NSLog(@"GOT A USER DEFAULT");
        fontSize = (long)[defaults integerForKey:@"fontSize"];
    }
    NSLog(@"retrieveUserDefaultFontSize: %lu", (long)fontSize);
    return fontSize;
}

#pragma mark PxePlayerLabelProviderDelegate
- (NSString *) provideLabelForPageWithPath:(NSString *)relativePath
{
    NSDictionary *pageDetails = [[PxePlayer sharedInstance] getPageDetails:@"pageURL" withValue:relativePath];
    
    NSString *pageTitle = [pageDetails objectForKey:@"pageTitle"];
    
    NSMutableString *customLabel = [NSMutableString new];
    [customLabel appendFormat:@"{"];
    [customLabel appendFormat:@"\"pageTitle\":\"%@\",", pageTitle];
    [customLabel appendFormat:@"\"pageURL\":\"%@\"", relativePath];
    [customLabel appendFormat:@"}"];
    
    NSLog(@"customLabel: %@", customLabel);
    
    return customLabel;
}

- (CGRect) getRelativeRectFromMenuButton:(UIButton*) menuButton
{
    CGPoint buttonCenter = CGPointMake(menuButton.bounds.origin.x, (menuButton.bounds.size.height/2 - 18));
    
    CGPoint p = [menuButton convertPoint:buttonCenter toView:self.view];
    
    return CGRectMake(p.x, p.y, menuButton.bounds.size.width, menuButton.bounds.size.height);
}

@end
