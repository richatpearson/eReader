//
//  PxeReaderSampleAppBookShelfCell.h
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 8/7/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressBarView.h"
#import "PxePlayerDownloadContext.h"

@class PxeReaderSampleAppBookShelfCell;

@protocol BookShelfCellDelegate <NSObject>

- (void) downloadBook:(NSUInteger)row;
//- (void) deleteDownloadedBook:(NSUInteger)row;
- (void) enableChapterDownload:(NSUInteger)row;

@end

@interface PxeReaderSampleAppBookShelfCell : UICollectionViewCell <UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView *bookImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *deleteDownloadButton;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, strong) PxePlayerDownloadContext *downloadContext;

@property (nonatomic, strong) ProgressBarView *progressView;

@property (nonatomic, weak) id<BookShelfCellDelegate> delegate;

- (void) buildWith:(NSDictionary *)book forRow:(NSUInteger)row;

- (void) setState:(NSInteger)state;

@end
