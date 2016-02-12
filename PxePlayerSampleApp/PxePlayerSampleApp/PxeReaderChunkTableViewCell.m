//
//  PxeReaderChunkTableViewCell.m
//  PxePlayerSampleApp
//
//  Created by Richard on 6/30/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderChunkTableViewCell.h"
#import "PxePlayerDownloadManager.h"
#import "AppDelegate.h"
#import "PxePlayerAlertView.h"
#import "PxePlayer.h"
#import "Reachability.h"

@implementation PxeReaderChunkTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)downloadChunkForOffline:(id)sender {
    
//    NSLog(@"Will download chunk epub with id %@", self.manifestChunk.chunkId);
//    NSLog(@"Download switch is  %@", (self.downloadSwitch.on) ? @"ON" : @"OFF");
//    
//    if ([Reachability isReachable])
//    {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyViewAfterDownload) name:BOOK_DOWNLOAD_COMPLETE_NOTIFICATION object:nil];
//        
//        NSString *chunkDownloadUrl = [NSString stringWithFormat:@"%@%@", self.manifestChunk.baseUrl, self.manifestChunk.epubFileName];
//        NSLog(@"Will downlaod chunk epub with url: %@", chunkDownloadUrl);
//        
//        PxePlayerDownloadManager *downloadManager = [PxePlayerDownloadManager sharedInstance];
//        downloadManager.delegate = self;
//        
//        self.dataInterface.ePubURL = chunkDownloadUrl;
//        [downloadManager updateWithDataInterface:self.dataInterface downloadId:self.manifestChunk.chunkId downloadType:PxePlayerChapter];
//        
//        //TODO: should we create a public method that makes all this easier for clients? They only pass manifestChunk and we do the rest?
//        PxePlayerDownloadContext *ppdc = [downloadManager getDownloadContextWithDownloadId:self.manifestChunk.chunkId];
//        
//        [downloadManager startOrPauseDownloadingSingleFile:ppdc];
//        self.chunkProgress.hidden = NO;
//        self.chunkProgress.progress = 0;
//        
//        
//        /*[[NSOperationQueue mainQueue] addOperationWithBlock:^{
//         if(ppdc.isDownloading)
//         {
//         //self.downloadBookButton.imageView.image = [UIImage imageNamed:@"pause.png"];
//         } else {
//         //self.downloadBookButton.imageView.image = [UIImage imageNamed:@"start.png"];
//         }
//         }];*/
//    }
//    else
//    {
//        PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Currently Offline", @"Currently Offline")
//                                                                      message:NSLocalizedString(@"Can not download book. You are currently offline.", @"Can not download book. You are currently offline.")
//                                                                     delegate:self
//                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
//                                                            otherButtonTitles:nil, nil];
//        [alert setDelegate:self];
//        [alert setAlertViewStyle:UIAlertViewStyleDefault];
//        [alert show];
//    }
}

- (IBAction)deleteChunk:(id)sender {
    
//    PxePlayerDownloadManager *downloadManager = [PxePlayerDownloadManager sharedInstance];
//    downloadManager.delegate = self;
//    
//    if ([downloadManager deleteChunkDownload:self.manifestChunk.epubFileName contextId:self.dataInterface.contextId]) {
//        
//        self.deleteChunkButton.hidden = YES;
//        self.downloadButton.hidden = NO;
//        self.downloadSwitch.on = false;
//        [self.delegate updateDownloadStatusForCell:self]; //false forRow:self.rowInTable];
//    }
//    else {
//        
//        NSLog(@"Failed to delete chapter chunk epub!");
//        PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Database Error", @"Database Error")
//                                                                      message:NSLocalizedString(@"Unable to delete chapter epub file.", @"Unable to delete chapter epub file")
//                                                                     delegate:self
//                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
//                                                            otherButtonTitles:nil, nil];
//        [alert setDelegate:self];
//        [alert setAlertViewStyle:UIAlertViewStyleDefault];
//        [alert show];
//    }
}

#pragma Mark DownloadManager delegate methods

- (void) updateUIElements:(PxePlayerDownloadContext*)ppdc
        totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite atIndex:(int)index {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        // Calculate the progress.
        ppdc.downloadProgress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        
        //example of doing megs of megs
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:1];  //optional
        
        self.chunkProgress.progress = ppdc.downloadProgress;
        //self.progressText.text = [self formatNumberToPercent:ppdc.downloadProgress];
    }];
}

- (void) updateUIElementsFinished:(PxePlayerDownloadManager *)ppdm
                          atIndex:(int)index
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.chunkProgress.hidden = YES;
        self.downloadSwitch.on = true;
        self.downloadButton.hidden = YES;
        self.deleteChunkButton.hidden = NO;
        //self.wasModifiedByActionInCell = YES;
        NSLog(@"Update UI elements done - executing delegate");
        [self.delegate updateDownloadStatusForCell:self]; //:true forRow:self.rowInTable];
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

- (void) notifyViewAfterDownload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BOOK_DOWNLOAD_COMPLETE_NOTIFICATION object:nil];
    NSLog(@"Got notification from download manager");
}

@end
