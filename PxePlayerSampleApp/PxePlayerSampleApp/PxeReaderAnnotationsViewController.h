//
//  PxeReaderAnnotationsViewController.h
//  PxePlayerApp
//
//  Created by Tomack, Barry on 3/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxeReaderMasterPopoverViewController.h"
#import "PxePlayerAnnotation.h"

@protocol AnnotationsDelegate <NSObject>

@optional

- (void) annotationSelectEventWithAnnotation:(PxePlayerAnnotation*)annotation;

@end

@interface PxeReaderAnnotationsViewController : PxeReaderMasterPopoverViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSDictionary *annotations;

@property (nonatomic, weak) IBOutlet UITableView  *table;

@property (nonatomic, weak) id<AnnotationsDelegate> delegate;

@end
