//
//  PxeReaderGlossaryViewController.h
//  PxePlayerApp
//
//  Created by Tomack, Barry on 3/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxeReaderMasterPopoverViewController.h"

@interface PxeReaderGlossaryViewController : PxeReaderMasterPopoverViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *glossaryDict;
@property (nonatomic, strong) NSArray *sectionArray;
@property (nonatomic, strong) IBOutlet UITableView  *table;

- (void) buildGlossary:(NSArray *)array;

@end
