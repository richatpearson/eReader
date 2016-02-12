//
//  ViewController.m
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/19/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderSampleBookShelfViewController.h"
#import "PxeReaderSampleViewController.h"
#import "Reachability.h"
#import "PxePlayer.h"
#import "PxePlayerDataInterface.h"
#import "PxeReaderSampleDownloadManagerViewController.h"
#import "PxePlayerDownloadManager.h"
#import "PxePlayerDownloadContext.h"
#import "PxePlayerBook.h"
#import "AppDelegate.h"
#import "PxePlayerAlertView.h"

#define PATH_OF_DOCUMENT [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define pxeContentURL @"https://content.openclass.com/eps/pearson-reader/api/item/"

@interface PxeReaderSampleBookShelfViewController ()

@property (strong,nonatomic) PxePlayerBook *currentBook;
@property (strong,nonatomic) NSString *onlineBaseURL;
@property (strong,nonatomic) NSString *offlineBaseURL;
@property (nonatomic,strong) NSString *contextTitle;
@property (nonatomic,strong) NSString *contextId;
@property (nonatomic,strong) NSString *tocPath;
@property (nonatomic,strong) NSDictionary *selectedBook;

@end

@implementation PxeReaderSampleBookShelfViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set Up download manager
    [[PxePlayerDownloadManager sharedInstance] setDelegate:self];
    
    NSLog(@"BACKLINK.HTML: %@", [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"backlinking" ofType:@"html" inDirectory:@"OPS"]]);
    NSLog(@"ONLINE URL: %@", [NSString stringWithFormat:@"file://%@/",[[NSBundle mainBundle] resourcePath]]);
    self.hardCodedBooks = @[
                            @{@"image": @"neff8309_01_bkcvrlg.jpg",
                              @"title":@"Changing Planet, NCX, Shared N&H",
                              @"epuburl":[NSString stringWithFormat:@"%@9d156801-1289-4b74-902e-ea82e2eeb502/1/file/archive/A_Changing_Planet.epub",pxeContentURL],
                              @"onlineurl": [NSString stringWithFormat:@"%@9d156801-1289-4b74-902e-ea82e2eeb502/1/file/A_Changing_Planet",pxeContentURL],
                              @"contextId":@"4PM49REXEKT",
                              @"tocpath":@"OPS/toc.ncx",
                              @"annotationShare":@"true",
                              @"printPageSupport":@"false",
                              @"removeDuplicatePages":@"true"},
                            
                            @{@"image": @"red_notebook.jpg",
                              @"title":@"NotebookEvent Book",
                              @"epuburl":@"",
                              @"onlineurl": @"http://pxe-sdk-qa.stg-openclass.com/books/Hibbeler219",
                              @"contextId":@"2ISCZ6TWNNY",
                              @"tocpath":@"OPS/toc.ncx",
                              @"annotationShare":@"true",
                              @"printPageSupport":@"false",
                              @"removeDuplicatePages":@"true"},
                            
                            @{@"image": @"USHistoryTexas.jpg",
                              @"title":@"QA - United States History: 1877 to Present Texas",
                              @"epuburl":@"",
                              @"contextId":@"4GI8RZ8MXF9",
                              @"tocpath":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/418e8000-b923-11e5-8f64-2355963df11a/1/file/9780133329629_hsus16_se_tx_pxe_oxy_pxe_basic_1/OPS/xhtml/toc.xhtml",
                              @"onlineurl":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/418e8000-b923-11e5-8f64-2355963df11a/1/file/9780133329629_hsus16_se_tx_pxe_oxy_pxe_basic_1",
                              @"annotationShare":@"false",
                              @"printPageSupport":@"false",
                              @"removeDuplicatePages":@"true",
                              @"useDefaultFontAndTheme":@"false",
                              @"indexId":@"81a78f29407f118628675f0f07410557"},
                            
                            @{@"image": @"nutrition.jpg",
                              @"title":@"FINAL SCIENCE QA Nutrition: From Science to You",
                              @"epuburl":@"",
                              @"contextId":@"BWM61G20BQ-REV",
                              @"tocpath":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/d0bd64b7-3974-4fea-8222-908ab347b80d/100/file/blake3_071015pr_nosvg/OPS/toc.xhtml",
                              @"annotationShare":@"false",
                              @"printPageSupport":@"false",
                              @"removeDuplicatePages":@"true",
                              @"useDefaultFontAndTheme":@"false"},
                            
                            @{@"image": @"AccessToHealth.png",
                              @"title":@"SCIENCE QA: Access to health",
                              @"epuburl":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/d8c65f1c-12e6-4ede-91e4-8bc2a12b74f0/1/file/archive/donatelleATH14-062415.epub",
                              @"contextId":@"9YC3XNUOYAF",
                              @"tocpath":@"https://content.stg-openclass.com/eps/pearson-reader/api/item/d8c65f1c-12e6-4ede-91e4-8bc2a12b74f0/1/file/donatelleATH14-062415/OPS/toc.xhtml",
                              @"annotationShare":@"false",
                              @"printPageSupport":@"true",
                              @"removeDuplicatePages":@"true"},
                            
                            @{@"image": @"ciccarelli.jpg",
                              @"title":@"Ciccarelli, XHTML, Not Shared N&H",
                              @"epuburl":@"",
                              @"contextId":@"25L5R4DH2Y1",
                              @"tocpath":[NSString stringWithFormat:@"%@5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/toc.xhtml",pxeContentURL],
                              @"annotationShare":@"false",
                          
                              @"printPageSupport":@"false",
                              @"removeDuplicatePages":@"true"},
                            
                            @{@"image": @"humanAnatomy.jpg",
                              @"title":@"SCIENCE QA: Human Anatomy and Physiology 1e",
                              @"epuburl":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/03e64843-c917-40b9-9e84-0c031b93b81e/1/file/archive/amerman1_pr625b.epub",
                              @"contextId":@"9ZETMUDO500",
                              @"tocpath":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/03e64843-c917-40b9-9e84-0c031b93b81e/1/file/amerman1_pr625b/OPS/toc.xhtml",
                              @"annotationShare":@"false",
                              @"printPageSupport":@"true",
                              @"removeDuplicatePages":@"true",
                              @"useDefaultFontAndTheme":@"false"},
                            
                            @{@"image": @"ciccarelli.jpg",
                              @"title":@"Ciccarelli, MasterP, Shared N&H",
                              @"epuburl":@"",
                              @"onlineurl": [NSString stringWithFormat:@"%@5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13",pxeContentURL],
                              @"contextId":@"25L5R4DH2Y2",
                              @"annotationShare":@"true",
                              @"printPageSupport":@"false",
                              @"masterPlaylist":@[
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_introduction.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_01.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_02.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_03.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_04.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_05.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_06.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_07.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_summary.xhtml",
                                                    @"https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/chapter-01/ch1_introduction.xhtml"
                                                    ]
                              },
                            
                            @{@"image": @"backlinking.jpg",
                              @"title":@"Backlinking, MasterP, No N&H",
                              @"epuburl":@"",
                              @"onlineurl": [NSString stringWithFormat:@"file://%@/",[[NSBundle mainBundle] resourcePath]],
                              @"contextId":@"1234567890",
                              @"annotationShare":@"false",
                              @"showAnnotate":@"false",
                              @"printPageSupport":@"false",
                              @"masterPlaylist":@[
                                      [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"backlinking" ofType:@"html" inDirectory:@"OPS"]]
                                                ]
                              },
                            
                            @{@"image":@"racialandethnicgroups14e.jpg",
                              @"title":@"QA TEST TOC FFMac Racial and Ethnic Groups",
                              @"epuburl":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/991feb26-d9ab-42e1-b7f6-3d1ee2ffd3a5/100/file/archive/schaefer-raeg-14e_v5.epub",
                              @"tocpath":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/f0ed1a1d-25a4-463a-992d-9bc89f7cc93a/100/file/schaefer-raeg-14e_v5/OPS/xhtml/toc.xhtml",
                              @"contextId":@"9T6GGYCVQ87-REV",
                              @"tocpath":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/991feb26-d9ab-42e1-b7f6-3d1ee2ffd3a5/100/file/schaefer-raeg-14e_v5/OPS/xhtml/toc.xhtml",
                              @"annotationShare":@"false"},
                            
                            @{@"image":@"racialandethnicgroups14e.jpg",
                              @"title":@"The other Racial and Ethnic Groups",
                              @"epuburl":@"",
                              @"contextId":@"8XRMXJQI1Q6-REV",
                              @"tocpath":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/f0ed1a1d-25a4-463a-992d-9bc89f7cc93a/100/file/schaefer-raeg-14e_v5/OPS/xhtml/toc.xhtml",
                              @"annotationShare":@"false"},
                            
                            @{@"image":@"MyHealth.png",
                              @"title":@"Double-byte Language Test",
                              @"epuburl":@"http://content.stg-openclass.com/eps/pearson-reader/api/item/8eef7e53-ff04-46f7-bfaf-ef6d8c2629b7/1/file/archive/China_Japan_Korea_26Aug.epub",
                              @"contextId":@"16CFR5Y5JDE",
                              @"tocpath":@"https://content.stg-openclass.com/eps/pearson-reader/api/item/8eef7e53-ff04-46f7-bfaf-ef6d8c2629b7/1/file/China_Japan_Korea_26Aug/OPS/toc.xhtml",
                              @"annotationShare":@"false"},
                            
                            @{@"image": @"humanResources.jpg",
                              @"title":@"Dressler Fundamentals",
                              @"epuburl":@"https://content.stg-openclass.com/eps/pearson-reader/api/item/7a03a153-4295-49c8-9eba-9b09ca509d85/1/file/archive/PXEPL-5026.epub",
                              @"onlineurl":@"https://content.stg-openclass.com/eps/pearson-reader/api/item/7a03a153-4295-49c8-9eba-9b09ca509d85/1/file/PXEPL-5026",
                              @"contextId":@"96CQLOJHL7L-REV",
                              @"tocpath":@"OPS/toc.ncx",
                              @"annotationShare":@"true",
                              @"printPageSupport":@"false",
                              @"removeDuplicatePages":@"true"}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.hardCodedBooks count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cvCell";
    
    [collectionView registerClass:[PxeReaderSampleAppBookShelfCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    NSUInteger row = [indexPath row];
    NSLog(@"cellForItemAtIndex: %lu", (unsigned long)row);
    PxeReaderSampleAppBookShelfCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[PxeReaderSampleAppBookShelfCell alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    }
    
    cell.delegate = self;
    
    UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    recognizer.delegate = self;
    [cell addGestureRecognizer:recognizer];
    
    [cell buildWith:self.hardCodedBooks[row] forRow:row];
    
    return cell;
}

#pragma mark -event handlers
- (void)handleSingleTapFrom:(UITapGestureRecognizer *) recognizer
{
    CGPoint tapLocation = [recognizer locationInView:self.bookCollectionsView];
    NSIndexPath *indexPath = [self.bookCollectionsView indexPathForItemAtPoint:tapLocation];
    long row = (long)indexPath.row;
    NSLog(@"handleSingleTapFrom click %ld",(long)indexPath.row);
    
    NSDictionary *bookInfo = [self.hardCodedBooks objectAtIndex:row];
    
    PxeReaderSampleAppBookShelfCell *cell = [self getCellForContextId:bookInfo[@"contextId"]];
    
    if (cell.enabled)
    {
        self.contextTitle = bookInfo[@"contextTitle"];
        self.contextId = bookInfo[@"contextId"];
        self.onlineBaseURL =  bookInfo[@"onlineurl"];
        self.offlineBaseURL = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:bookInfo[@"contextId"]] stringByAppendingPathExtension:@"epub"];
        
        self.currentBook = [[PxePlayerBook alloc] init];
        self.currentBook.title = bookInfo[@"title"];
        self.currentBook.bookUUID =bookInfo[@"contextId"];
        
        self.selectedBook = [self.hardCodedBooks objectAtIndex:row];
        
        NSLog(@"SELECTED BOOK ContextID: %@", bookInfo[@"contextId"]);
        
        NSString *tocPath = bookInfo[@"tocPath"];
        if ([tocPath rangeOfString:@".ncx"].location != NSNotFound)
        {
            self.tocPath = [NSString stringWithFormat:@"%@/OPS/toc.ncx", self.onlineBaseURL];
        }
        
        [self performSegueWithIdentifier:@"bookSegue" sender:self];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"bookSegue"])
    {
        PxeReaderSampleViewController * vc = segue.destinationViewController;
        vc.dataInterface = [self buildDataInterfaceForSelectedBook];
        vc.pageUrls = nil;
        [vc setCurrentBook:self.currentBook];
        vc.bookData = self.selectedBook;
    }
    else if([[segue identifier] isEqualToString:@"downloadSegue"])
    {
        //set book stuff
        PxeReaderSampleDownloadManagerViewController * dvc = segue.destinationViewController;
        dvc.selectedBook = self.selectedBook;
        dvc.dataInterface = [self buildDataInterfaceForSelectedBook];
    }
}

- (PxePlayerDataInterface *) buildDataInterfaceForBookAtIndex:(NSUInteger)idx
{
    PxePlayerDataInterface *dataInterface = [PxePlayerDataInterface new];
    
    NSDictionary *bookAtIndex = [self.hardCodedBooks objectAtIndex:idx];
    
    if ([bookAtIndex objectForKey:@"masterPlaylist"])
    {
        NSLog(@"buildDataInterfaceForMasterPlaylist");
        [self buildDataInterfaceForMasterPlaylist:dataInterface forBook:bookAtIndex];
    } else {
        NSLog(@"buildDataInterfaceForTOC");
        [self buildDataInterfaceForTOC:dataInterface forBook:bookAtIndex];
    }
    
    return dataInterface;
}

- (PxePlayerDataInterface *) buildDataInterfaceForSelectedBook
{
    PxePlayerDataInterface *dataInterface = [PxePlayerDataInterface new];
    dataInterface.clientApp = PxePlayerSampleApp;
    
    if ([self.selectedBook objectForKey:@"masterPlaylist"])
    {
        NSLog(@"buildDataInterfaceForMasterPlaylist");
        [self buildDataInterfaceForMasterPlaylist:dataInterface forBook:self.selectedBook];
    } else {
        NSLog(@"buildDataInterfaceForTOC");
        [self buildDataInterfaceForTOC:dataInterface forBook:self.selectedBook];
    }
    
    return dataInterface;
}


- (PxePlayerDataInterface *) buildDataInterfaceForTOC:(PxePlayerDataInterface*)dataInterface forBook:(NSDictionary*)bookDict
{
    NSLog(@"In buildDataInterfaceForTOC - tocPath in bookDict is: %@\n and current DI toc path is: %@",[bookDict objectForKey:@"tocpath"], dataInterface.tocPath);
    dataInterface.contextTitle = [bookDict objectForKey:@"title"];
    dataInterface.contextId = [bookDict objectForKey:@"contextId"];
    dataInterface.assetId = [bookDict objectForKey:@"contextId"];
    dataInterface.ePubURL = [bookDict objectForKey:@"epuburl"];
    dataInterface.onlineBaseURL = [bookDict objectForKey:@"onlineurl"];
    dataInterface.offlineBaseURL = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:[bookDict objectForKey:@"contextId"]] stringByAppendingPathExtension:@"epub"];
    dataInterface.tocPath = [bookDict objectForKey:@"tocpath"];
    dataInterface.identityId = [[PxePlayer sharedInstance] currentUser].identityId;//@"nextext_qauser1";//@"DemoTest";
    dataInterface.masterPlaylist = nil;
    dataInterface.authToken = [[PxePlayer sharedInstance] currentUser].authToken;// @"ST-4317-TF0dxzcSq7LLdVOLrbpd-b3-rumba-int-01-02";
    dataInterface.afterCrossRefBehaviour = @"continue"; //or "stop"
    dataInterface.indexId = [bookDict objectForKey:@"indexId"];
    
    if ([self.selectedBook objectForKey:@"removeDuplicatePages"])
    {
        dataInterface.removeDuplicatePages = [[bookDict objectForKey:@"removeDuplicatePages"] isEqualToString:@"false"]?NO:YES;
    }
    
    NSLog(@"Now the DI toc path is %@", dataInterface.tocPath);
    
    NSString *showAnnotate = [bookDict objectForKey:@"showAnnotate"];
    if (showAnnotate)
    {
        dataInterface.showAnnotate = [showAnnotate isEqualToString:@"false"]?NO:YES;
    } else {
        dataInterface.showAnnotate = YES;
    }
    dataInterface.annotationsSharable = [[bookDict objectForKey:@"annotationShare"] isEqualToString:@"true"]?YES:NO;
    
    return dataInterface;
}

- (PxePlayerDataInterface *) buildDataInterfaceForMasterPlaylist:(PxePlayerDataInterface*)dataInterface forBook:(NSDictionary*)bookDict
{
    dataInterface.contextTitle = [bookDict objectForKey:@"title"];
    dataInterface.contextId = [bookDict objectForKey:@"contextId"];
    dataInterface.assetId = [bookDict objectForKey:@"contextId"];
    dataInterface.ePubURL = [bookDict objectForKey:@"epuburl"];
    dataInterface.onlineBaseURL = [bookDict objectForKey:@"onlineurl"];
    dataInterface.tocPath = nil;
    dataInterface.identityId = [[PxePlayer sharedInstance] currentUser].identityId;//@"nextext_qauser1";//@"DemoTest";
    dataInterface.authToken = [[PxePlayer sharedInstance] currentUser].authToken;// @"ST-4317-TF0dxzcSq7LLdVOLrbpd-b3-rumba-int-01-02";
    dataInterface.afterCrossRefBehaviour = @"continue"; //or "stop"
    dataInterface.offlineBaseURL = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:[bookDict objectForKey:@"contextId"]] stringByAppendingPathExtension:@"epub"];
    dataInterface.showAnnotate = YES;
    dataInterface.annotationsSharable = YES;
    dataInterface.masterPlaylist = [bookDict objectForKey:@"masterPlaylist"];
    
    NSString *showAnnotate = [bookDict objectForKey:@"showAnnotate"];
    if (showAnnotate)
    {
        dataInterface.showAnnotate = [showAnnotate isEqualToString:@"false"]?NO:YES;
    } else {
        dataInterface.showAnnotate = YES;
    }
    dataInterface.annotationsSharable = [[bookDict objectForKey:@"annotationShare"] isEqualToString:@"true"]?YES:NO;
    
    return dataInterface;
}

- (NSDictionary *) findBookForContextId:(NSString *)contextId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contextId == %@", contextId];
    NSArray *filteredArray = [self.hardCodedBooks filteredArrayUsingPredicate:predicate];
    
    NSDictionary *bookForContext = [filteredArray firstObject];
    
    return bookForContext;
}

- (NSUInteger) findIndexOfBookWithContextId:(NSString *)contextId
{
    return [self.hardCodedBooks indexOfObject:[self findBookForContextId:contextId]];
}

// Delegate methods
- (void) downloadBook:(NSUInteger)row
{
    NSLog(@"Downloaded Book: %lu", (unsigned long)row);
    if ([Reachability isReachable])
    {
        PxePlayerDataInterface *dataInterface = [self buildDataInterfaceForBookAtIndex:row];
        NSLog(@"DataInterface: %@", dataInterface);
        PxePlayerDownloadContext *downloadContext = [[PxePlayerDownloadManager sharedInstance] updateWithDataInterface:dataInterface];
        
        [[PxePlayerDownloadManager sharedInstance] startOrPauseDownloadRequest:downloadContext];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(downloadContext.isDownloading)
            {
                //                [self setActionButtonState:1];
            } else {
                //                [self setActionButtonState:0];
            }
        }];
    }
    else
    {
        PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Currently Offline", @"Currently Offline")
                                                                      message:NSLocalizedString(@"Can not download book. You are currently offline.", @"Can not download book. You are currently offline.")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                            otherButtonTitles:nil, nil];
        [alert setDelegate:self];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
}

- (void) enableChapterDownload:(NSUInteger)row
{
    //PxePlayer *pxePlayer = [PxePlayer sharedInstance];
    //if ([pxePlayer isTOCDownloadedForContext:self.book[@"contextId"]]) {
    //    NSLog(@"We have the TOC! - show VC to downlaod selective chapters");
    //}
    
    self.selectedBook = [self.hardCodedBooks objectAtIndex:row];
    //PxePlayerDataInterface *dataInterface = [self buildDataInterfaceForBookAtIndex:row];
    
    [self performSegueWithIdentifier:@"downloadSegue" sender:self];
}

#pragma mark - DownloadManager Delegate

//- (void) updateUIElements:(PxePlayerDownloadContext *)ppdc
//        totalBytesWritten:(int64_t)totalBytesWritten
//totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
//                  atIndex:(int)index

- (void) updateDownloadRequest:(PxePlayerDownloadContext *)downloadContext
             totalBytesWritten:(int64_t)totalBytesWritten
     totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        // Calculate the progress.
        downloadContext.downloadProgress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        
        NSLog(@"INDEX: %lu", (unsigned long)[self findIndexOfBookWithContextId:downloadContext.contextId]);
        NSLog(@"Book: %@ bytesDownloaded: %lld :: totalBytes: %lld", downloadContext.fileTitle, totalBytesWritten, totalBytesExpectedToWrite);
        
        PxeReaderSampleAppBookShelfCell *cell = [self getCellForContextId:downloadContext.contextId];
        
        [cell.progressView setProgress:downloadContext.downloadProgress];
    }];
}

- (PxeReaderSampleAppBookShelfCell *) getCellForContextId:(NSString*) contextId
{
    NSUInteger idx = [self findIndexOfBookWithContextId:contextId];
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
    PxeReaderSampleAppBookShelfCell *cell = (PxeReaderSampleAppBookShelfCell *)[self.bookCollectionsView cellForItemAtIndexPath:idxPath];
    
    return cell;
}

- (void) didFinishFileDownloadRequest:(PxePlayerDownloadContext*)downloadContext
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSUInteger idx = [self findIndexOfBookWithContextId:downloadContext.contextId];
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
        PxeReaderSampleAppBookShelfCell *cell = (PxeReaderSampleAppBookShelfCell *)[self.bookCollectionsView cellForItemAtIndexPath:idxPath];
        NSLog(@"DidFinishDownloadRequest");
        [cell.progressView changeProgressStrokeColor:PROGRESS_FINISH_COLOR];
    }];
}

-(void)didFinishSingleBackgroundSession:(PxePlayerDownloadContext *)downloadContext
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    if (appDelegate.backgroundTransferCompletionHandler != nil)
    {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            // Show a local notification when the download is over.
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = [NSString stringWithFormat:@"%@ download finished successfully.",downloadContext.fileTitle];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            //Add a badge to the app icon.
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        }];
    }
}

- (void) didFinishAllBackgroundSession:(NSArray *)downloadTasks
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if ([downloadTasks count] == 0)
    {
        if (appDelegate.backgroundTransferCompletionHandler != nil)
        {
            // Copy locally the completion handler.
            void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
            
            // Make nil the backgroundTransferCompletionHandler.
            appDelegate.backgroundTransferCompletionHandler = nil;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // Call the completion handler to tell the system that there are no other background transfers.
                completionHandler();
                
                // Show a local notification when all downloads are over.
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertBody = @"ALL Books finished successfully.";
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                
            }];
        }
    }
}

-(void)pxePlayerDownloadManagerDidFailWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
    if ([error.localizedDescription isEqualToString:@"No Bookmark items found."])
    {
        return;
    }
    PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString([error localizedDescription], [error localizedDescription])
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil, nil];
    [alert setDelegate:self];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert show];
}

- (void) updateDownloadStatus:(PxePlayerDownloadContext *)downloadContext
{
    NSLog(@"Updating Download Status: %lu for Context: %@", (unsigned long)downloadContext.downloadStatus, downloadContext.contextId);
    
    PxeReaderSampleAppBookShelfCell *cell = [self getCellForContextId:downloadContext.contextId];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [cell setState:downloadContext.downloadStatus];
        
        switch (downloadContext.downloadStatus)
        {
            case PxePlayerDownloadPending:
                NSLog(@"***********************************************DOWNLOAD PENDING");
                break;
            case PxePlayerDownloadingEpubFile:
                NSLog(@"***********************************************DOWNLOADING EPUB");
                break;
            case PxePlayerDownloadingTOC:
                NSLog(@"***********************************************DOWNLOADING TOC");
                break;
            case PxePlayerDownloadingMetaData:
                NSLog(@"***********************************************DOWNLOADING META DATA");
                break;
            case PxePlayerDownloadCompleted:
                NSLog(@"***********************************************DOWNLOADING COMPLETE");
                break;
            case PxePlayerDownloadError:
                NSLog(@"DOWNLOADING ERROR");
                break;
            default:
                break;
        };
    }];
}

@end
