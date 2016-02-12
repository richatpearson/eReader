//
//  PxeReaderSampleDownloadManagerViewController.m
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/20/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderSampleDownloadManagerViewController.h"
#import "AppDelegate.h"
#import "PxePlayerAlertView.h"
#import "PxePlayer.h"
#import "Reachability.h"
#import "PxePlayerManifestItem.h"
#import "PxeReaderSampleDownloadTableViewCell.h"
#import "PxePlayerDataManager.h"
#import "PxePlayerLoadingView.h"
#import "PxePlayerError.h"

@interface PxeReaderSampleDownloadManagerViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *bookImageView;
@property (strong, nonatomic) IBOutlet UITableView *assetTable;

@property (strong, nonatomic) PxePlayerDownloadManager *downloadManager;

@property (strong, nonatomic) NSMutableArray *assets;

@property (nonatomic, strong) PxePlayerLoadingView *loadingView;

@end

#define CONVERSION_FACTOR_TO_MB @"1048576"

@implementation PxeReaderSampleDownloadManagerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //make sure the user is set before here
    self.downloadManager = [PxePlayerDownloadManager sharedInstance];
    self.downloadManager.delegate = self;
    
    NSLog(@"SelectedBook: %@", self.selectedBook);
    
    self.bookImageView.image = [UIImage imageNamed:self.selectedBook[@"image"]];
    
    self.assets = [[NSMutableArray alloc] init];
    
    [self getManifestDataForDataInterface:self.dataInterface];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view cell delegate methods
- (void) downloadAssetAtRow:(NSUInteger)row
{
    NSLog(@"Downloading asset at row: %lu", (unsigned long)row);
    if ([Reachability isReachable])
    {
        PxePlayerManifestItem *asset = (PxePlayerManifestItem*)[self.assets objectAtIndex:row];
        self.dataInterface.assetId = asset.assetId;
        NSLog(@"Setting assetId: %@", self.dataInterface.assetId);
        self.dataInterface.ePubURL = asset.fullUrl;
        
        PxePlayerDownloadContext *downloadContext = [self.downloadManager updateWithDataInterface:self.dataInterface];
        [self.downloadManager startOrPauseDownloadRequest:downloadContext];
    }
    else
    {
        [self showOfflineError];
    }
}

- (void) deleteDownloadedAssetAtRow:(NSUInteger)row
{
    PxePlayerManifestItem *asset = (PxePlayerManifestItem*)[self.assets objectAtIndex:row];
    [self.downloadManager deleteDownloadedFileForAssetId:asset.assetId];
    
    PxeReaderSampleDownloadTableViewCell *cell = [self getCellForAssetId:asset.assetId];
    
    [cell setActionState:0];
}

- (IBAction)closeDownloadManager:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utility methods
-(NSString*)formatNumberToPercent:(float)percent
{    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    [numberFormatter setMinimumFractionDigits:2];  //optional
    
    NSNumber *number = [NSNumber numberWithFloat:percent];
    
    return [numberFormatter stringFromNumber:number];
}

#pragma mark - offlineManager Delegate

- (void) updateDownloadRequest:(PxePlayerDownloadContext *)downloadContext
             totalBytesWritten:(int64_t)totalBytesWritten
     totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        // Calculate the progress.
        downloadContext.downloadProgress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        
        PxeReaderSampleDownloadTableViewCell *cell = [self getCellForAssetId:downloadContext.assetId];

        // self.progressbar.progress = downloadContext.downloadProgress;
        cell.progressbar.progress = downloadContext.downloadProgress;
        [cell setActionState:1];
    }];
}

- (void) didFinishFileDownloadRequest:(PxePlayerDownloadContext*)downloadContext
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        PxeReaderSampleDownloadTableViewCell *cell = [self getCellForAssetId:downloadContext.assetId];
        
        [cell setActionState:2];
    }];
}

- (void) updateDownloadStatus:(PxePlayerDownloadContext *)downloadContext
{
    PxeReaderSampleDownloadTableViewCell *cell = [self getCellForAssetId:downloadContext.assetId];
    if (downloadContext.downloadStatus == PxePlayerDownloadPaused) {
        [cell setActionState:3];
    }
    else if (downloadContext.downloadStatus == PxePlayerDownloadingEpubFile) {
        [cell setActionState:1];
    }
}

- (PxeReaderSampleDownloadTableViewCell *) getCellForAssetId:(NSString*) assetId
{
    NSUInteger idx = [self findIndexOfAssetForAssetId:assetId];
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    PxeReaderSampleDownloadTableViewCell *cell = (PxeReaderSampleDownloadTableViewCell *)[self.assetTable cellForRowAtIndexPath:idxPath];
    
    return cell;
}

- (NSUInteger) findIndexOfAssetForAssetId:(NSString *)assetId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetId == %@", assetId];
    NSArray *filteredArray = [self.assets filteredArrayUsingPredicate:predicate];
    
    PxePlayerManifestItem *asset = [filteredArray firstObject];
    
    return [self.assets indexOfObject:asset];
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
    PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString([error localizedDescription], [error localizedDescription])
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil, nil];
    [alert setDelegate:self];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert show];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // typically you need know which item the user has selected.
    // this method allows you to keep track of the selection
    NSLog(@"didSelectRowAtIndexPath...");
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete;
}

#pragma mark UITableViewDataSource methods

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"We have %lu assets in data source...", (unsigned long)[self.assets count]);
    return [self.assets count];
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"AssetTableViewCell";
    PxeReaderSampleDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil)
    {
        cell = [[PxeReaderSampleDownloadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    
    cell.delegate = self;
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    NSUInteger row = [indexPath row];
    
    PxePlayerManifestItem *manifestItem = (PxePlayerManifestItem*)[self.assets objectAtIndex:row];
    
    NSLog(@"Loading row in table for asset id: %@ and size of %@", manifestItem.assetId, [manifestItem.size stringValue]);
    
    cell.assetNameLabel.text = manifestItem.title;
    cell.assetSizeLabel.text = (manifestItem.size) ? [self formatSizeInMegabites:manifestItem.size] : nil;
    
    cell.row = row;
    [cell setAssetId:manifestItem.assetId];
    
    return cell;
}

- (NSString*) formatSizeInMegabites:(NSNumber*)size
{
    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithDecimal:[size decimalValue]];
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                             scale:2
                                                                                  raiseOnExactness:NO
                                                                                   raiseOnOverflow:NO
                                                                                  raiseOnUnderflow:NO
                                                                               raiseOnDivideByZero:NO];
    NSDecimalNumber *megs = [decNumber decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:CONVERSION_FACTOR_TO_MB]
                                                    withBehavior:handler];
    
    return [NSString stringWithFormat:@"%@ Mb",[megs stringValue]];
}

#pragma mark Manifest Items

-(void) getManifestDataForDataInterface:(PxePlayerDataInterface*)dataInterface
{
    if ([Reachability isReachable])
    {
        [self showLoader];
        PxePlayer *pxePlayer = [PxePlayer sharedInstance];
        
        [pxePlayer retrieveManifestItemsForDataInterface:dataInterface withCompletionHandler:^(PxePlayerManifest *manifest, NSError *error) {
            
            if (manifest)
            {
                if (error.code == PxePlayerNoManifestFoundInStore) { //the client may check if the manifest comes from Paper API
                    NSLog(@"This manifest is not from store");
                }
                [self.assets addObjectsFromArray:manifest.items];
                NSLog(@"We have %lu assets. Reloading table...", (unsigned long)[self.assets count]);
            }
            else {
                if (error) {
                    NSLog(@"Error is %@", error.description);
                }
            }
            [self.assetTable reloadData];
            [self hideLoader];
        }];
    }
    else
    {
        [self showOfflineError];
    }
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

- (void) showOfflineError
{
    PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Currently Offline", @"Currently Offline")
                                                                  message:NSLocalizedString(@"Can not download asset. You are currently offline.", @"Can not download asset. You are currently offline.")
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                        otherButtonTitles:nil, nil];
    [alert setDelegate:self];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert show];
}

@end
