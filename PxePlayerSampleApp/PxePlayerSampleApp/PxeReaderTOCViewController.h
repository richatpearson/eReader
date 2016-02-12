//
//  PxeReaderTOCViewController.h
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 9/8/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxeReaderTOCPageViewController.h"
#import "PxeReaderTOCPageContentViewController.h"

@protocol tocDelegate <NSObject>

- (void) tocSelectionEventWithURI:(NSString*)uri;

@end

@interface PxeReaderTOCViewController : UIViewController <UIPageViewControllerDataSource, tocContentDelegate>

@property (strong, nonatomic) PxeReaderTOCPageViewController *pageViewController;

@property (strong, nonatomic) NSMutableArray *tocParents;

@property (strong, nonatomic) NSString *currentParentId;

@property (weak, nonatomic) id<tocDelegate> delegate;

@property (nonatomic, assign) NSUInteger pageIndex;

@property (nonatomic, strong) NSString *displayTitle;

- (id) initWithInitialParentId:(NSString*)parentId
                  displayTitle:(NSString*)displayTitle;

@end
