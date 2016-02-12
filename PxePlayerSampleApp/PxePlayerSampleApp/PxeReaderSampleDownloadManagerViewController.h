//
//  PxeReaderSampleDownloadManagerViewController.h
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/20/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerDownloadManager.h"
#import "PxePlayerDataInterface.h"
#import "PxeReaderSampleDownloadTableViewCell.h"

@interface PxeReaderSampleDownloadManagerViewController : UIViewController <PxePlayerDownloadManagerDelegate, UITableViewDelegate, UITableViewDataSource, DownloadTableCellDelegate>

@property (strong, nonatomic) NSDictionary *selectedBook;
@property (strong, nonatomic) PxePlayerDataInterface *dataInterface;

@end
