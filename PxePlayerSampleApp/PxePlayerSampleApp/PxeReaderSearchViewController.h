//
//  PxeReaderSearchViewController.h
//  PxePlayerApp
//
//  Created by Tomack, Barry on 3/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxeReaderMasterPopoverViewController.h"

@class PxePlayerSearchPages;

@protocol SearchDelegate <NSObject>

@optional

- (void) searchSelectEventWithURI:(NSString *)uri andHighlights:(NSArray*)highlights;

- (void) searchInProgress;

- (void) searchCompleted;

@end

@interface PxeReaderSearchViewController : PxeReaderMasterPopoverViewController <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) PxePlayerSearchPages *searchPages;

@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView  *searchTable;

@property (nonatomic, weak) id<SearchDelegate> delegate;

@end
