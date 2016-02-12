//
//  PxeReaderSampleDownloadTableViewCell.m
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 8/7/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderSampleDownloadTableViewCell.h"
#import "PxePlayerDownloadManager.h"

@implementation PxeReaderSampleDownloadTableViewCell

- (void) setAssetId:(NSString *)assetIdStr
{
    _assetId = assetIdStr;
    
    BOOL fileExists = [[PxePlayerDownloadManager sharedInstance] checkForDownloadedFileByAssetId:_assetId];
    
    if (fileExists)
    {
        [self setActionState:2];
    }
    else
    {
        [self setActionState:0];
    }
}

- (void) setActionState:(NSInteger)state
{
    if (state == 0)
    {
        [self.actionButton setImage:[UIImage imageNamed: @"start.png"] forState:UIControlStateNormal];
        
        self.progressbar.progress = 0;
        self.progressbar.hidden = YES;
        _isDownloaded = NO;
    }
    if (state == 1)
    {
        [self.actionButton setImage:[UIImage imageNamed: @"pause.png"] forState:UIControlStateNormal];
        self.progressbar.hidden = NO;
        self.progressbar.progressTintColor = [UIColor blueColor];
        _isDownloaded = NO;
    }
    if (state == 2)
    {
        NSLog(@"%@ has been downloaded", self.assetNameLabel.text);
        [self.actionButton setImage:[UIImage imageNamed: @"trash_21.png"] forState:UIControlStateNormal];
        self.progressbar.hidden = NO;
        self.progressbar.progress = 1.0;
        self.progressbar.progressTintColor = [UIColor greenColor];
        _isDownloaded = YES;
    }
    if (state == 3) //for paused state
    {
        [self.actionButton setImage:[UIImage imageNamed: @"start.png"] forState:UIControlStateNormal];
        self.progressbar.hidden = NO;
        self.progressbar.progressTintColor = [UIColor blueColor];
        _isDownloaded = NO;
    }
}
- (IBAction)downloadAsset:(id)sender
{
    NSLog(@"Download status for %@ is %d", self.assetNameLabel.text, self.isDownloaded);
    if (self.isDownloaded)
    {
        [self.delegate deleteDownloadedAssetAtRow:self.row];
    }
    else
    {
        [self.delegate downloadAssetAtRow:self.row];
    }
}

@end
