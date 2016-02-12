//
//  PxePlayerPageManager.m
//  PxePlayerApi
//
//  Created by Saro Bear on 18/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#define INITIAL_DOWNLOAD_COUNT 5
#define PAGE_DOWNLOAD_LENGTH 1
#define MAX_HISTORY_COUNT 10

#define NCX_NAVMAP @"navMap"
#define NCX_NAVPOINT @"navPoint"
#define NCX_ID @"id"
#define NCX_NAV_LABEL @"navLabel"
#define NCX_NAV_TEXT @"text"
#define NCX_NAV_TITLE @"title"
#define NCX_PLAYORDER @"playOrder"
#define NCX_TEXT @"text"
#define NCX_CONTENT @"content"
#define NCX_SRC @"src"


#import "PxePlayerDataManager.h"
#import "PxeContext.h"
#import "PxeListPage.h"
#import "PxePlayerPageManager.h"
#import "PxePlayerPageOperations.h"
#import "PxePlayerInterface.h"
#import "PxePlayerSearchURLsQuery.h"
#import "PxePlayerUIConstants.h"
#import "NSString+Extension.h"
#import "PxePlayer.h"
#import "PxePlayerToc.h"
#import "HMCache.h"
#import "PXEPlayerMacro.h"
#import "PxePrintPage.h"
#import "Reachability.h"
#import "PxePlayerError.h"

/**
  PxePlayerPageManager class extension where private variables and methods to be declared
  @see PxePlayerOperationQueueDelegate
 */

@interface PxePlayerPageManager () <PxePlayerOperationQueueDelegate>

/**
  Bool value which sets the book has custom playlist or not
 */
@property (nonatomic, assign) BOOL  isPlaylist;

/**
  NSInteger value which set the total number of pages in the book
 */
@property (nonatomic, assign) NSInteger totalPages;

/**
  NSInteger which hold the current page index
 */
@property (nonatomic, assign) NSInteger currentPage;

/**
  NSInteger which hold the current transition page index
 */
@property (nonatomic, assign) NSInteger virtualCurrentPage;

/**
  NSString value which holds the toc NCX URL
 */
@property (nonatomic, strong) NSString          *tocUrl;

/**
  NSMutableArray which holds the array of pages that user navigated that user can undo the navigation
 */
@property (nonatomic, strong) NSMutableArray    *histories;

/**
  NSArray , array of  URL's which used to be render custom playlist from the book
 */
@property (nonatomic, strong) NSArray           *customPlaylist;

/**
  PxePlayerPageOperations are download queue which holds the array of page URL's to download sequentially 
  @see PxePlayerPageOperations
  @see PxePlayerPageOperation
 */
@property (nonatomic, strong) PxePlayerPageOperations   *pageOperations;

@end


/**
  PxePlayerPageManager class implementation where all methods should be defined
 */
@implementation PxePlayerPageManager

#pragma mark - Private methods
- (void) initializePages
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    //load the custom pages
    if(self.isPlaylist)
    {
        //delete the existing playlist
        NSArray *playlist = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeListPage class])
                                                   withSortKey:@"pageIndex"
                                                     ascending:YES withPredicate:nil
                                                    fetchLimit:0
                                                    resultType:NSManagedObjectResultType];
        for (NSManagedObject *object in playlist)
        {
            [[dataManager getObjectContext] deleteObject:object];
        }
        
        //start inserting the new playlist
        NSInteger pageNo = 1;
        for (NSString *pageURL in self.customPlaylist)
        {
            //insert the custom pages
            PxeListPage *page = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeListPage class])
                                                                    inManagedObjectContext:[dataManager getObjectContext]];
            
            NSArray *urlCom = [pageURL componentsSeparatedByString:@"#"];
            NSString *urlTag = @"";
            if([urlCom count] > 1) {
                urlTag = urlCom[1];
            }
            
            page.pageURL   = urlCom[0];
            page.pageIndex = [NSNumber numberWithInteger:pageNo];
            page.urlTag    = urlTag;
            
            if(![dataManager save]) {
                NSLog(@"Error inserting the data in core data...");
            }
            ++pageNo;
        }
        
        self.totalPages = [self.customPlaylist count];
        self.customPlaylist = nil;
    }
    else
    {
        self.totalPages = [dataManager fetchMaxValue:NSStringFromClass([PxePageDetail class])
                                            property:@"pageNumber"
                                        forContextId:self.delegate.getCurrentContextId];
    }
    
    DLog(@"total pages %ld", (long)self.totalPages);
    
    //initialise the page operation queue
    self.pageOperations = [[PxePlayerPageOperations alloc] init];
    [self.pageOperations setDelegate:self];
    
    [self insertOperations];
    
    if([[self delegate] respondsToSelector:@selector(contentsDownloadSuccess)])
    {
        [[self delegate] contentsDownloadSuccess];
    }
}

-(void)reDirectToBook
{
    NSDictionary *results = [[PxePlayerDataManager sharedInstance] fetchEntity:@"pageNumber"
                                                                      forModel:NSStringFromClass([PxePageDetail class])
                                                                     withValue:[[PxePlayer sharedInstance] getContextID]
                                                                        andKey:@"context.context_id"
                                                                   withSortKey:@"pageNumber"
                                                                  andAscending:NO];
    
    self.totalPages = [results[@"pageNumber"] integerValue];
    self.isPlaylist = NO;
}

- (void) pushHistory:(NSNumber*)pageNo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_IS_HISTORY object:[NSNumber numberWithBool:YES]];
    
    if(pageNo)
    {
        [self.histories addObject:pageNo];
        //remove the overflowed history
        if([self.histories count] > MAX_HISTORY_COUNT) {
            [self.histories removeObjectAtIndex:0];
        }
    }
}

- (NSNumber*) popHistory
{
    NSNumber *pageNumber = nil;
    NSInteger hisCount = [self.histories count];
    if(hisCount)
    {
        pageNumber = [self.histories lastObject];
        [self.histories removeLastObject];
        --hisCount;
        
        if(!hisCount) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_IS_HISTORY object:[NSNumber numberWithBool:NO]];
        }
    }
    
    return pageNumber;
}

//TODO: It seems kind of stupid do grab a huge data file just to return  a boolean
// Make sure to add -ObjC -all_loads to BuildSettings/Other Linker Flags in your
// project target to get NSString+Extension category to link
- (BOOL) isPageAlreadyDownloaded:(NSString*)page
{
    DLog(@"Checking Cache");
    NSData *data = (NSData*)[HMCache objectForKey:[page md5]];
    
    if(!data)
    {
        return NO;
    }
    return YES;
}


// Calculate the length of the number of operations everytime user jumps new page
- (void) insertOperations
{
    //get next page
    NSInteger startIndex = self.virtualCurrentPage - PAGE_DOWNLOAD_LENGTH;
    NSInteger endIndex = self.virtualCurrentPage   + PAGE_DOWNLOAD_LENGTH;
    
    DLog(@"self.virtualCurrentPage: %ld", (long)self.virtualCurrentPage);
    
    DLog(@"startIndex: %ld", (long)startIndex);
    DLog(@"endIndex: %ld", (long)endIndex);
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSArray *pagesRange = nil;
    DLog(@"\nFETCHING PAGES: >>>>>>>>>> \n");
    if(self.isPlaylist)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((pageIndex >= %d) AND (pageIndex <= %d))", startIndex, endIndex, self.delegate.getCurrentContextId];
        pagesRange = [dataManager fetchEntities:@[@"pageURL"]
                                       forModel:NSStringFromClass([PxeListPage class])
                                  withPredicate:predicate
                                     resultType:NSDictionaryResultType
                                    withSortKey:@"pageIndex"
                                   andAscending:YES
                                     fetchLimit:0
                                     andGroupBy:nil];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((pageNumber >= %d) AND (pageNumber <= %d)) AND context.context_id = %@", startIndex, endIndex, self.delegate.getCurrentContextId];
        pagesRange = [dataManager fetchEntities:@[@"pageURL"]
                                       forModel:NSStringFromClass([PxePageDetail class])
                                  withPredicate:predicate
                                     resultType:NSDictionaryResultType
                                    withSortKey:@"pageNumber"
                                   andAscending:YES
                                     fetchLimit:0
                                     andGroupBy:nil];
    }
    
    NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *pages = [[NSMutableArray alloc] initWithCapacity:3];
    NSInteger highPriorityIndex = 1;
    for (NSDictionary *pageDic in pagesRange)
    {
        NSString *page = pageDic[@"pageURL"];
        if(page)
        {
            if(![pages containsObject:page])
            {
                [pages addObject:page];
                //TODO: Uncomment this when offline is working again
//                if(![self isPageAlreadyDownloaded:page])
//                {
                    DLog(@"...adding operation for page");
                    [operations addObject:page];
//                }
            }
        }
    }
    DLog(@"\n\nPAGES: %@\n", pages);
    //send the added pages to the delegate pages display controller
    if(self.delegate && [[self delegate] respondsToSelector:@selector(pagesAdded:)])
    {
        [[self delegate] pagesAdded:pages];
    }
    
    //add the filtered operations
    if([operations count])
    {
        [self.pageOperations addOperations:operations
                         withPriorityIndex:highPriorityIndex
                             dataInterface:[self.delegate getCurrentDataInterface]
                                 authToken:nil
                                    userId:nil];
    }
}

#pragma mark - Self methods

- (id) initWithDelegate:(id)delegate
{
    self = [super init];
    
    if(self)
    {
        self.virtualCurrentPage = self.currentPage = 1;
        self.isPlaylist = NO;
        self.histories = [[NSMutableArray alloc] initWithCapacity:MAX_HISTORY_COUNT];
        self.delegate = delegate;
    }
    
    return self;
}

- (id) initWithNCXUrl:(NSString*)url
   withCustomPlaylist:(NSArray*)urls
          andDelegate:(id)delegate
{
    self = [self initWithDelegate:delegate];
    
    if (self)
    {
        self.tocUrl = url;
        
        if(urls)
        {
            self.isPlaylist = YES;
            self.customPlaylist = [NSArray arrayWithArray:urls];
        }
        //TODO: This can't be a good thing
        // Calling from the end of the PxePlayerPageViewController viewDidLoad: doesn't work so well
        // Calling the method straight without a delay doesn't work at all
        [self performSelector:@selector(initializePages) withObject:nil afterDelay:0.1f];
//        [self downloadToc];
    }
    
    return self;
}

-(id)initWithMasterPlaylist:(NSArray*)masterurls withCustomPlaylist:(NSArray*)urls andDelegate:(id)delegate
{
    self = [self initWithDelegate:delegate];    
    
    if (self)
    {
        PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
        
        //TODO: This is kind of weird. Why delete it and create a new one
        //check book already found in the DB if yes than delete it
        PxePageDetail *pageDetail = [dataManager fetchEntity:@"context.context_id"
                                                 forModel:NSStringFromClass([PxePageDetail class])
                                                withValue:self.delegate.getCurrentContextId];
        if(pageDetail)
        {
            [[dataManager getObjectContext] deleteObject:pageDetail];
        }
        
        if(urls)
        {
            self.isPlaylist = YES;
            self.customPlaylist = [NSArray arrayWithArray:urls];
        }
        
        //TODO: Look into this...This is never a good idea to add delays just because something else is processing
        [self performSelector:@selector(initializePages) withObject:nil afterDelay:0.1f];
    }
    
    return self;
}

-(void)dealloc
{
    DLog(@"page manager deallocated...");
    
    self.tocUrl = nil;
    self.pageOperations = nil;
    self.histories = nil;
}

#pragma mark - Public methods

-(NSString*)getCurrentPageId
{
    DLog(@"self.currentPage: %ld", (long)self.currentPage);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageNumber = %d) AND (context.context_id = %@)", self.virtualCurrentPage, self.delegate.getCurrentContextId];
    
    NSDictionary *results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageId"]
                                                                      forModel:NSStringFromClass([PxePageDetail class])
                                                                 withPredicate:predicate
                                                                   withSortKey:nil
                                                                  andAscending:YES];
    
    NSString *pageId = results[@"pageId"];

    return pageId;
}


-(void)refreshCurrentPage
{
    DLog(@"self.currentPage: %ld", (long)self.currentPage);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageNumber = %d) AND (context.context_id = %@)", self.currentPage, self.delegate.getCurrentContextId];
    
    NSDictionary *results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                                      forModel:NSStringFromClass([PxePageDetail class])
                                                                 withPredicate:predicate
                                                                   withSortKey:nil
                                                                  andAscending:YES];
    
    NSString *page = results[@"pageURL"];
    
    if(page)
    {
        [self.pageOperations addOperation:page
                            dataInterface:[self.delegate getCurrentDataInterface]
                                authToken:nil
                                   userId:nil];
    }
}

-(void)refreshPage:(NSString*)pageId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageId = %@) AND (context.context_id = %@)", pageId, self.delegate.getCurrentContextId];
    
    NSDictionary *results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                                      forModel:NSStringFromClass([PxePageDetail class])
                                                                 withPredicate:predicate
                                                                   withSortKey:nil
                                                                  andAscending:YES];
    
    NSString *page = results[@"pageURL"];
    
    if(page)
    {
        [self.pageOperations addOperation:page
                            dataInterface:[self.delegate getCurrentDataInterface]
                                authToken:nil
                                   userId:nil];
    }
}

-(NSString*)gotoPageByPageNumber:(NSNumber*)pageNumber
{
    
    NSInteger pageNo = [pageNumber integerValue];
    
    self.virtualCurrentPage = pageNo;
    DLog(@"self.currentPage: %ld", (long)self.currentPage);

    NSDictionary *results;
    
    if(self.isPlaylist)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageIndex != %d) AND (pageIndex = %d)", self.currentPage, self.virtualCurrentPage];
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                            forModel:NSStringFromClass([PxeListPage class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageNumber = %d) AND (context.context_id = %@)", pageNo, self.delegate.getCurrentContextId];
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                            forModel:NSStringFromClass([PxePageDetail class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
    }
    
    NSString* page = results[@"pageURL"];
    if(page)
    {        
        [self insertOperations];
    }
    
    return page;
}

-(NSString*)gotoPageByPageId:(NSString*)pageId
{
    DLog(@"self.currentPage: %ld", (long)self.currentPage);
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageId = %@) AND (pageNumber != %d) AND (context.context_id = %@)", pageId, self.currentPage, self.delegate.getCurrentContextId];
    
    NSDictionary *results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL",@"pageNumber"]
                                                                      forModel:NSStringFromClass([PxePageDetail class])
                                                                 withPredicate:predicate
                                                                   withSortKey:nil
                                                                  andAscending:YES];
    
    NSString* page = results[@"pageURL"];
    
    if(page)
    {
        self.virtualCurrentPage = [results[@"pageNumber"] integerValue];
        
        if(self.isPlaylist)
        {
            NSNumber *pageIndex = [dataManager fetchEntity:@"pageIndex"
                                                  forModel:NSStringFromClass([PxeListPage class])
                                                 withValue:page
                                                    andKey:@"pageURL"
                                               withSortKey:nil
                                              andAscending:NO];
            if(!pageIndex)
            {
                [self reDirectToBook];
            }
            else
            {
                self.virtualCurrentPage = [pageIndex integerValue];
            }
        }
        [self insertOperations];
    }
    
    return page;
}

- (NSString*) gotoPageByPageURL:(NSString*)pageURL
{
    DLog(@"self.currentPage: %ld", (long)self.currentPage);
    DLog(@"pageURL: %@", pageURL);
    NSPredicate *predicate;
    NSDictionary *results;
    NSString* page;
    
    if(self.isPlaylist)
    {
        DLog(@"THIS IS A PLAYLIST");
        // This will query the correct list table only if a playlist was used
        predicate = [NSPredicate predicateWithFormat:@"(pageURL ==[c] %@)", pageURL];
//        DLog(@"predicate: %@", predicate);
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL",@"pageIndex"]
                                                            forModel:NSStringFromClass([PxeListPage class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
        DLog(@"RESULTS: %@", results);
        page = results[@"pageURL"];
        DLog(@"PAGE: %@", page);
        if(page)
        {
            DLog(@"WE HAVE A PAGE")
            self.virtualCurrentPage = [results[@"pageIndex"] integerValue];
            if(![results[@"pageIndex"] integerValue])
            {
                [self reDirectToBook];
            }
            [self insertOperations];
        }
    }
    else
    { //this does all the jump to pages like toc and highlight
        DLog(@"NOT A PLAYLIST");
        
        NSString *relPageURL;
        relPageURL = [[PxePlayer sharedInstance] removeBaseUrlFromUrl:pageURL];
        DLog(@"relPageURL: %@", relPageURL);
        relPageURL = [[PxePlayer sharedInstance] formatRelativePathForTOC: relPageURL];
        DLog(@"relPageURL: %@", relPageURL);
        
        NSNumber *pageMustBeDownloaded = [NSNumber numberWithBool:![Reachability isReachable]];
        
        predicate = [NSPredicate predicateWithFormat:@"(pageURL contains[cd] %@) AND  (context.context_id = %@) AND isDownloaded >= %@", relPageURL, self.delegate.getCurrentContextId, pageMustBeDownloaded];
        
        DLog(@"predicate: %@", predicate);
        
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL",@"pageNumber"]
                                                            forModel:NSStringFromClass([PxePageDetail class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
        DLog(@"RESULTS: %@", results);
        page = results[@"pageURL"];
        DLog(@"page: %@", page);
        if(page)
        {
            self.virtualCurrentPage = [results[@"pageNumber"] integerValue];
            DLog(@"self.virtualCurrentPage: %ld", (long)self.virtualCurrentPage);
            [self insertOperations];
        }
        else
        {
            DLog(@"Can't Find Page");
        }
    }

    return page;
}

- (NSInteger) getCurrentPageIndex
{
    return self.currentPage;
}

-(NSString *)getCurrentPageTitle
{
    NSDictionary *results = nil;
    NSString *pageTitle;

    @try {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageNumber = %d) AND (context.context_id = %@)", self.virtualCurrentPage, [[PxePlayer sharedInstance] getContextID]];
        
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageTitle"]
                                                            forModel:NSStringFromClass([PxePageDetail class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
        
        pageTitle = results[@"pageTitle"];
        
    }
    @catch (NSException *exception) {
        NSLog(@"PXE SDK: pageTitle not found in table. Error thrown. %@",[exception debugDescription]);
        pageTitle = @"";
    }
    @finally {
        return pageTitle;
    }
}

-(NSInteger)getCurrentPageNumber
{
    NSInteger pageNumber = self.virtualCurrentPage;
    if(self.isPlaylist)
    {
        PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
        NSString *pageURL = [dataManager fetchEntity:@"pageURL"
                                            forModel:NSStringFromClass([PxeListPage class])
                                           withValue:[NSString stringWithFormat:@"%ld",(long)self.currentPage]
                                              andKey:@"pageIndex"
                                         withSortKey:@"pageIndex"
                                        andAscending:YES][@"pageURL"];
        
        if(pageURL)
        {
            NSNumber *pageNumber = [dataManager fetchEntity:@"pageNumber"
                                                   forModel:NSStringFromClass([PxePageDetail class])
                                                  withValue:pageURL
                                                     andKey:@"pageURL"
                                                withSortKey:@"pageNumber"
                                               andAscending:YES][@"pageNumber"];
            
            return [pageNumber integerValue];
        }
    }
    
    
    return pageNumber;
}

-(NSUInteger)getTotalPagesCount {
    return self.totalPages;
}

-(NSInteger)getVirtualCurrentPageIndex {
    return self.virtualCurrentPage;
}

-(void)updatePageIndex {
    DLog(@"");
    self.currentPage = self.virtualCurrentPage;
}

-(void)pageDidLoad
{
    DLog(@"");
    [self pushHistory:[NSNumber numberWithInteger:[self getCurrentPageNumber]]];
    [self updatePageIndex];
}

-(NSString*)nextPage
{
    self.virtualCurrentPage = self.currentPage;

    NSDictionary *results = nil;
    NSString* page;
    //TODO: Clarify by renaming isCustomPlaylist. Master Playlist uses PxePageDetail
    if(self.isPlaylist)
    {
        ++self.virtualCurrentPage;
        if(self.virtualCurrentPage > self.totalPages)
        {
            self.virtualCurrentPage = self.totalPages;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageIndex != %d) AND (pageIndex = %d)", self.currentPage, self.virtualCurrentPage];
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                            forModel:NSStringFromClass([PxeListPage class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
        page = results[@"pageURL"];
    }
    else
    {
        PxePageDetail *qryPage = [self firstAvailablePageFromCurrentPageNumber:self.currentPage direction:PxePlayerNavNext];
        
        page = qryPage.pageURL;
    }
    
    DLog(@"\n\nGOT THIS PAGE: %@\n\n",page);
    
    if(page) {//this gets the next page and inserts it into the pages array
        [self insertOperations];
    }
    
    return page;
}

-(NSString*)prevPage
{
    self.virtualCurrentPage = self.currentPage;
    
    NSDictionary *results = nil;
    NSString* page;
    
    if(self.isPlaylist)
    {
        --self.virtualCurrentPage;
        if(self.virtualCurrentPage < 1)
        {
            self.virtualCurrentPage = 1;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageIndex != %d) AND (pageIndex = %d)", self.currentPage, self.virtualCurrentPage];
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                            forModel:NSStringFromClass([PxeListPage class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
        page = results[@"pageURL"];
    }
    else
    {
        PxePageDetail *qryPage = [self firstAvailablePageFromCurrentPageNumber:self.currentPage direction:PxePlayerNavPrevious];
        
        page = qryPage.pageURL;
    }
    
    if(page)
    {
        [self insertOperations];
    }
    
    return page;
}

- (NSString*)getPageFromPageNumber:(NSNumber*)pageNum
{
    self.virtualCurrentPage = [pageNum integerValue];
    if(!self.currentPage)
    {
        self.currentPage = 1;
    }
    DLog(@"self.currentPage: %ld", (long)self.currentPage);
    NSDictionary *results = nil;
    
    if(self.isPlaylist)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageIndex != %d) AND (pageIndex = %d)", self.currentPage, self.virtualCurrentPage];
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                            forModel:NSStringFromClass([PxeListPage class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageNumber != %d) AND (pageNumber = %d) AND (context.context_id = %@)", self.currentPage, self.virtualCurrentPage, self.delegate.getCurrentContextId];
        
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                            forModel:NSStringFromClass([PxePageDetail class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
    }
    
    NSString* page = results[@"pageURL"];
    
    if(page)
    {
        [self insertOperations];
    }
    DLog(@"page: %@", page);
    return page;
}

-(NSString*)getVirtualPage
{
    return [self doGetCurrentPage:self.virtualCurrentPage];
}

//does the look up for getVirtualPage and getCurrentPage
-(NSString*)doGetCurrentPage:(NSInteger)pageNumber
{
    NSDictionary *results = nil;
    
    if(self.isPlaylist)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageIndex = %d)", pageNumber];
        
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                            forModel:NSStringFromClass([PxeListPage class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageNumber = %d) AND (context.context_id = %@)", pageNumber, self.delegate.getCurrentContextId];
        
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL"]
                                                            forModel:NSStringFromClass([PxePageDetail class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
    }

    NSString* page = results[@"pageURL"];
    
    return page;
}

-(NSString*)getCurrentPage
{
    return [self doGetCurrentPage:self.currentPage];
}


-(void)resetCurrentPage:(NSString *)page
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageURL = %@) AND (context.context_id = %@)", page, self.delegate.getCurrentContextId];
    
    NSDictionary *results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageNumber"]
                                                                      forModel:NSStringFromClass([PxePageDetail class])
                                                                 withPredicate:predicate
                                                                   withSortKey:nil
                                                                  andAscending:YES];
    
    self.currentPage = [results[@"pageNumber"] integerValue];
}

-(BOOL)isFirstPage
{
    if ([Reachability isReachable])
    {
        if(self.currentPage == 1)
        {
            return YES;
        }
    }
    else
    {
        NSPredicate *pagesPredicate = [NSPredicate predicateWithFormat:@"(context.context_id = %@) AND (isDownloaded = 1)", self.delegate.getCurrentContextId];
        
        PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
        
        NSArray *downloadedPages = [dataManager fetchEntitiesForModel:NSStringFromClass([PxePageDetail class])
                                                          withSortKey:@"pageNumber"
                                                            ascending:YES
                                                        withPredicate:pagesPredicate
                                                           fetchLimit:0
                                                           resultType:NSManagedObjectResultType];
        PxePageDetail *firstPage = [downloadedPages firstObject];
        if(self.currentPage == [firstPage.pageNumber integerValue])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isLastPage
{
    if ([Reachability isReachable])
    {
        if(self.currentPage == self.totalPages)
        {
            return YES;
        }
    }
    else
    {
        NSPredicate *pagesPredicate = [NSPredicate predicateWithFormat:@"(context.context_id = %@) AND (isDownloaded = 1)", self.delegate.getCurrentContextId];
        
        PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
        
        NSArray *downloadedPages = [dataManager fetchEntitiesForModel:NSStringFromClass([PxePageDetail class])
                                                          withSortKey:@"pageNumber"
                                                            ascending:YES
                                                        withPredicate:pagesPredicate
                                                           fetchLimit:0
                                                           resultType:NSManagedObjectResultType];
        PxePageDetail *lastPage = [downloadedPages lastObject];
        if(self.currentPage == [lastPage.pageNumber integerValue])
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) testURLForValidPage:(NSString*)pageURL
{
    NSPredicate *predicate;
    NSDictionary *results;
    NSString* page;
    BOOL validPage = NO;
    
    if(self.isPlaylist)
    {
        DLog(@"THIS IS A PLAYLIST");
        // This will query the correct list table only if a playlist was used
        predicate = [NSPredicate predicateWithFormat:@"(pageURL ==[c] %@)", pageURL];
        
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL",@"pageIndex"]
                                                            forModel:NSStringFromClass([PxeListPage class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
        page = results[@"pageURL"];
        DLog(@"GOT A PAGE: %@", page);
        if(page)
        {
            validPage = YES;
        }
    }else{ //this does all the jump to pages like toc and highlight
        DLog(@"NOT A PLAYLIST");
        // Check if pageURL has an "http" in front of it.
        // This should not happen now that we are saving the absolute path from the TOC
        // TODO: eventually get rid of this conditional and just keep the first part.
        if([pageURL rangeOfString:@"http:/"].location == NSNotFound && [pageURL rangeOfString:@"https:/"].location == NSNotFound)
        {
            if ([pageURL hasPrefix:@"/"] && [pageURL length] > 1)
            {
                pageURL = [pageURL substringFromIndex:1];
            }
            predicate = [NSPredicate predicateWithFormat:@"(pageURL contains[cd] %@) AND  (context.context_id = %@)", pageURL, self.delegate.getCurrentContextId];
        }
        else
        {
            NSString *relPageURL= [[PxePlayer sharedInstance] removeBaseUrlFromUrl:pageURL];
            
            predicate = [NSPredicate predicateWithFormat:@"(pageURL contains[cd] %@) AND  (context.context_id = %@)", relPageURL, self.delegate.getCurrentContextId];
        }
        
        results = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"pageURL",@"pageNumber"]
                                                            forModel:NSStringFromClass([PxePageDetail class])
                                                       withPredicate:predicate
                                                         withSortKey:nil
                                                        andAscending:YES];
        
        page = results[@"pageURL"];
        DLog(@"GOT A PAGE: %@", page);
        if(page)
        {
            validPage = YES;
        }
    }
    DLog(@"validPage: %@", validPage?@"YES":@"NO");
    return validPage;
}

- (PxePrintPage*) getPrintPageFromPrintPageNumber:(NSNumber *)printPageNumber
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pageNumber = %@) AND (page.context.context_id = %@)", printPageNumber, self.delegate.getCurrentContextId];
    DLog(@"predicate: %@", predicate);
    NSArray *printPages = [dataManager fetchEntities:@[@"page"]
                                            forModel:NSStringFromClass([PxePrintPage class])
                                         withSortKey:@"pageNumber"
                                           ascending:YES
                                       withPredicate:predicate
                                          fetchLimit:0
                                          resultType:NSManagedObjectResultType
                                             groupBy:nil];
    if ([printPages count] == 0)
    {
        return nil;
    }
    
    PxePrintPage *printPage = [printPages objectAtIndex:([printPages count]-1)];
    DLog(@"DigitalPage Number: %@", printPage.page.pageNumber);
    
    return printPage;
}

#pragma mark - OperationQueue delegate methods

-(void)OperationFinished:(NSString *)key
{
    if([[self delegate] respondsToSelector:@selector(pageDownloaded:)])
    {
        [[self delegate] pageDownloaded:key];
    }
}

- (PxePageDetail *) firstAvailablePageFromCurrentPageNumber:(NSInteger)currPageNum direction:(PxePlayerNavigationDirection)dir
{
    if (!currPageNum)
    {
        currPageNum = 0;
    }
    DLog(@"[Reachability isReachable]: %@", [Reachability isReachable]?@"YES":@"NO");
    NSNumber *pageMustBeDownloaded = [NSNumber numberWithBool:![Reachability isReachable]];
    DLog(@"pageMustBeDownloaded: %@", pageMustBeDownloaded);
    NSPredicate *pagesPredicate;
    if (dir == PxePlayerNavNext)
    {
        pagesPredicate = [NSPredicate predicateWithFormat:@"(context.context_id = %@) AND (pageNumber > %lu) AND (isDownloaded >= %@)", self.delegate.getCurrentContextId, (long)currPageNum, pageMustBeDownloaded];
    }
    else if (dir == PxePlayerNavPrevious)
    {
        pagesPredicate = [NSPredicate predicateWithFormat:@"(context.context_id = %@) AND (pageNumber < %lu) AND (isDownloaded >= %@)", self.delegate.getCurrentContextId, (long)currPageNum, pageMustBeDownloaded];
    }
    DLog(@"pagesPredicate: %@", pagesPredicate);
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSArray *nextAvailablePage = [dataManager fetchEntitiesForModel:NSStringFromClass([PxePageDetail class])
                                                        withSortKey:@"pageNumber"
                                                          ascending:YES
                                                      withPredicate:pagesPredicate
                                                         fetchLimit:0
                                                         resultType:NSManagedObjectResultType];
    PxePageDetail *foundPage;
    if ([nextAvailablePage count] > 0)
    {
        if (dir == PxePlayerNavNext)
        {
            foundPage = [nextAvailablePage firstObject];
        }
        else if (dir == PxePlayerNavPrevious)
        {
            foundPage = [nextAvailablePage lastObject];
        }
        self.virtualCurrentPage = [foundPage.pageNumber integerValue];
        return foundPage;
    }
    
    return nil;
}

@end
