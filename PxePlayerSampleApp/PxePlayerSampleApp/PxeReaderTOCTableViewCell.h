//
//  PxeReaderTOCTableViewCell.h
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 9/9/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PxeReaderTOCTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *cellLabel;
@property (nonatomic, weak) IBOutlet UIImageView *cellDownloaded;
@property (nonatomic, weak) IBOutlet UIButton *cellDisclosure;

@end
