//
//  PxeReaderBookmarkListViewController.h
//  PxePlayerApp
//
//  Created by Mason, Darren J on 3/10/15.
//  Copyright (c) 2015 HappiestMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxeReaderMasterPopoverViewController.h"

@protocol BookmarksDelegate <NSObject>

@optional

- (void) bookmarkSelectEventWithURI:(NSString*)uri;

@end

@interface PxeReaderBookmarkListViewController : PxeReaderMasterPopoverViewController <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong) NSMutableArray *bookmarks;
@property (nonatomic, strong) IBOutlet UITableView  *table;

@property (nonatomic, weak) id<BookmarksDelegate> delegate;

@end
