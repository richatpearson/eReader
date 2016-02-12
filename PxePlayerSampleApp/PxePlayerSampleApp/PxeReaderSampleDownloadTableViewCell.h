//
//  PxeReaderSampleDownloadTableViewCell.h
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 8/7/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadTableCellDelegate <NSObject>

- (void) downloadAssetAtRow:(NSUInteger)row;
- (void) deleteDownloadedAssetAtRow:(NSUInteger)row;

@end

@interface PxeReaderSampleDownloadTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIProgressView *progressbar;
@property (strong, nonatomic) IBOutlet UILabel *assetNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *assetSizeLabel;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;

@property (strong, nonatomic, setter=setAssetId:) NSString *assetId;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) BOOL isDownloaded;

@property (nonatomic, weak) id<DownloadTableCellDelegate> delegate;

- (void) setActionState:(NSInteger)state;

@end
