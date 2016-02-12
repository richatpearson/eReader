//
//  ViewController.h
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/19/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerDownloadManagerDelegate.h"
#import "PxeReaderSampleAppBookShelfCell.h"

@interface PxeReaderSampleBookShelfViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate, PxePlayerDownloadManagerDelegate, BookShelfCellDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *bookCollectionsView;
/**
 *  Sample book paths
 */
@property (strong,nonatomic) NSArray *hardCodedBooks;

@end

