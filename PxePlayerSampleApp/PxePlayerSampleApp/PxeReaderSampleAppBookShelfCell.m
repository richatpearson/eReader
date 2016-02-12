//
//  PxeReaderSampleAppBookShelfCell.m
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 8/7/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderSampleAppBookShelfCell.h"
#import "PxePlayerDownloadManager.h"
#import "PxeReaderSampleDownloadManagerViewController.h"
#import "PxePlayer.h"


@interface PxeReaderSampleAppBookShelfCell ()

@property (nonatomic, strong) NSDictionary *book;
@property (nonatomic, assign) NSUInteger row;

@end


@implementation PxeReaderSampleAppBookShelfCell

- (void) buildWith:(NSDictionary *)book forRow:(NSUInteger)row
{
    self.book = book;
    self.row = row;
    
    self.enabled = YES;
    
    NSString *bookTitle = book[@"title"];
    NSString *bookImage = book[@"image"];
    
    float w = self.frame.size.width;
    //    float left = (w - 300) *0.5; //centered
    float left = 0;
    
    if (! self.bookImageView)
    {
        self.bookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, 0, 300, 230)];
        self.bookImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.bookImageView.alpha = 1.0;
        [self addSubview:self.bookImageView];
    }
    
    if (! self.titleLabel)
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bookImageView.frame.size.height + 10, w, 20)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.numberOfLines = 0;
        [self.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self addSubview:self.titleLabel];
    }
    
    [self.bookImageView setImage:[UIImage imageNamed:bookImage]];
    [self.titleLabel setText:bookTitle];
    
    //download icon
    NSString *epubURL = book[@"epuburl"];
    NSLog(@"buildWith: epubURL: %@", epubURL);
    if (![epubURL isEqualToString:@""] || !epubURL)
    {
        if (! self.downloadButton)
        {
            self.downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(30, self.frame.size.height-40, 30, 30)];
            [self.downloadButton addTarget:self action:@selector(downloadBookAssets) forControlEvents:UIControlEventTouchUpInside];
            [self.downloadButton setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            [self.downloadButton setTag:row];
            
            [self addSubview:self.downloadButton];
        }
        
        if (! self.deleteDownloadButton)
        {
            self.deleteDownloadButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40, self.frame.size.height-40, 30, 30)];
            [self.deleteDownloadButton addTarget:self action:@selector(confirmDeleteDownloadedBook) forControlEvents:UIControlEventTouchUpInside];
            [self.deleteDownloadButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
            
            [self addSubview:self.deleteDownloadButton];
        }
        
        if ( ! self.progressView)
        {
            self.progressView = [[ProgressBarView alloc] initWithFrame:CGRectMake(30, self.frame.size.height-40, 30, 30)];
            [self addSubview:self.progressView];
        }
        
        if (! self.statusLabel)
        {
            self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, self.frame.size.height-40, 175, 25)];
            [self.statusLabel setFont:[UIFont systemFontOfSize:10]];
            
            [self addSubview:self.statusLabel];
        }
        
        BOOL fileDownloaded = [[PxePlayerDownloadManager sharedInstance] checkForDownloadedFileByAssetId:self.book[@"contextId"]];
        if (fileDownloaded)
        {
            [self setState:0];
        }
        else
        {
            [self setState:0];
        }
    }
    else
    {
        NSLog(@"buildWith: Setting state to 0");
        [self setState:10];
        //self.downloadButton.hidden = YES;
    }
}

- (void) setState:(NSInteger)state
{
    // State based on PxePlayerDownloadStatus
    NSLog(@"SETTING STATE: %lu", (unsigned long)state);
    switch (state)
    {
        case 0:
            // Download Pending
            self.progressView.hidden = YES;
            [self.progressView resetProgresslayer];
            self.statusLabel.text = @"";
            
            self.bookImageView.alpha = 1.0;
            self.enabled = YES;
            
            self.downloadButton.hidden = NO;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO 0");
            break;
        case 1:
            // Download Paused
            self.progressView.hidden = NO;
            self.statusLabel.text = @"Paused";
            
            self.bookImageView.alpha = 0.5;
            self.enabled = YES;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO 1");
            break;
        case 2:
            // Download ePub in progress
            self.progressView.hidden = NO;
            self.statusLabel.text = @"Downloading ePub...";
            
            self.bookImageView.alpha = 0.5;
            self.enabled = NO;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO 2");
            break;
        case 3:
            // Download TOC in progress
            self.progressView.hidden = NO;
            self.statusLabel.text = @"Processing TOC...";
            
            self.bookImageView.alpha = 0.5;
            self.enabled = NO;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO 3");
            break;
        case 4:
            // Download MetaData in progress
            self.progressView.hidden = NO;
            self.statusLabel.text = @"Processing TOC...";
            
            self.bookImageView.alpha = 0.5;
            self.enabled = NO;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO 4");
            break;
        case 5:
            // Download PXE JS SDK
            self.progressView.hidden = NO;
            self.statusLabel.text = @"Downloading PXE JS SDK";
            
            self.bookImageView.alpha = 1.0;
            self.enabled = YES;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO 5");
            break;
        case 6:
            // Download Status Update
            self.progressView.hidden = NO;
            self.statusLabel.text = @"Updating Download Status";
            
            self.bookImageView.alpha = 1.0;
            self.enabled = YES;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO 6");
            break;
        case 7:
            // Download Complete
            self.progressView.hidden = YES;
            self.statusLabel.text = @"Download completed";
            
            self.bookImageView.alpha = 1.0;
            self.enabled = YES;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = NO;
            NSLog(@"SETTING CELL STATE TO 6");
            break;
        case 8:
            // Download Error
            self.progressView.hidden = NO;
            self.statusLabel.text = @"Error downloading";
            
            self.bookImageView.alpha = 1.0;
            self.enabled = YES;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO 7");
            break;
        default:
            self.progressView.hidden = YES;
            [self.progressView resetProgresslayer];
            self.statusLabel.text = @"";
            
            self.bookImageView.alpha = 1.0;
            self.enabled = YES;
            
            self.downloadButton.hidden = YES;
            self.deleteDownloadButton.hidden = YES;
            NSLog(@"SETTING CELL STATE TO DEFAULT");
            break;
    }
}

- (void) downloadBookAssets
{
    //PxePlayer *pxePlayer = [PxePlayer sharedInstance];
    
    /*if ([pxePlayer isManifestInStoreForBook:self.book[@"contextId"]]) {
        NSLog(@"We have the manifest! - show VC to downlaod selective chapters");
        [self.delegate enableChapterDownload];
    }
    else
    {
        NSLog(@"We DO NOT have the manifest - start book download!");
        
        [self confirmDownloadBook];
    }*/
    
    //if ([pxePlayer isTOCDownloadedForContext:self.book[@"contextId"]]) {
    //    NSLog(@"We have the TOC! - show VC to downlaod selective chapters");
    [self.delegate enableChapterDownload:self.row];
}

- (void) confirmDownloadBook
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm Download", @"Confirm Download")
                                                    message:NSLocalizedString(@"Do you wish to download this book?", @"Do you wish to download this book?")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                          otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [alertView show];
}

- (void) confirmDeleteDownloadedBook
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm Delete", @"Confirm Delete")
                                                        message:NSLocalizedString(@"Do you wish to delete this downloaded book from your device?", @"Do you wish to delete this downloaded book from your device?")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [alertView show];
    NSLog(@"deleteButton: %@", self.deleteDownloadButton);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Confirm Download
    if ([alertView.title isEqualToString:@"Confirm Download"])
    {
        if (buttonIndex == 1)
        {
            [self downloadBook];
        }
    }
    // Confirm Delete Download
    if ([alertView.title isEqualToString:@"Confirm Delete"])
    {
        if (buttonIndex == 1)
        {
            [self deleteDownloadedBook];
        }
    }
}

- (void) downloadBook
{
    [self setState:0];
    [self.progressView changeProgressStrokeColor:PROGRESS_COLOR];
    
    [self.delegate downloadBook:self.row];
}

- (void) deleteDownloadedBook
{
    NSLog(@"CONTEXT ID: %@", self.book[@"contextId"]);
    PxePlayerDownloadContext *downloadContext = [[PxePlayerDownloadManager sharedInstance] deleteDownloadedFileForAssetId:self.book[@"contextId"]];
    [self setState:downloadContext.downloadStatus];
}

@end
