//
//  PxeReaderTOCPageContentViewController.h
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 9/8/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol tocContentDelegate <NSObject>

- (void) moveForwardToBranchWithID:(NSString*)parentId;
- (void) moveBackward;
- (void) tocSelectionEventWithURI:(NSString*)uri;

@end

@interface PxeReaderTOCPageContentViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView  *pagesTable;
@property (nonatomic, weak) IBOutlet UIButton  *backButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSArray *pagesArray;

@property (nonatomic, assign) NSUInteger pagesIndex;

@property (nonatomic, weak) id<tocContentDelegate> delegate;

@property (nonatomic, strong) NSString *displayTitle;

- (IBAction)backToParent:(id)sender;

- (IBAction)drillDown:(id)sender;

@end
