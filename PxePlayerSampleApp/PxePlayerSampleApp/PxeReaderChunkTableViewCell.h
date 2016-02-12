//
//  PxeReaderChunkTableViewCell.h
//  PxePlayerSampleApp
//
//  Created by Richard on 6/30/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerManifestItem.h"
#import "PxePlayerDownloadManager.h"

@class PxeReaderChunkTableViewCell;

@protocol PxeReaderChunkTableViewCellDelegate <NSObject>

- (void) updateDownloadStatusForCell:(PxeReaderChunkTableViewCell*)cell;
@end

@interface PxeReaderChunkTableViewCell : UITableViewCell <PxePlayerDownloadManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *chunkId;
@property (strong, nonatomic) IBOutlet UISwitch *downloadSwitch;
@property (strong, nonatomic) IBOutlet UIButton *deleteChunkButton;

@property (nonatomic, strong) PxePlayerManifestItem *manifestChunk;
@property (strong, nonatomic) IBOutlet UIProgressView *chunkProgress;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;

@property (strong, nonatomic) PxePlayerDataInterface *dataInterface;
@property (nonatomic, assign) NSInteger rowInTable;

@property (nonatomic, assign) id<PxeReaderChunkTableViewCellDelegate> delegate;

@end
