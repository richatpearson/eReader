//
//  PxePlayerSampleToolbarViewController.h
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/19/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PxeReaderToolbarDelegate <NSObject>

@optional

-(void)bookshelfEventHandler:(id)sender;
-(void)bookmarkEventHandler:(id)sender;
-(void)menuEventHandler:(id)sender;

@end

@interface PxeReaderSampleToolbarViewController : UIViewController

@property (nonatomic, strong) id<PxeReaderToolbarDelegate> toolbarDelegate;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *bookshelfBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bookmarkBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;

-(void)setBookmarked:(BOOL)isBookmarked;

@end
