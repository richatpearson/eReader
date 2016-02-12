//
//  PxeReaderSampleControllerViewController.h
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/22/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PxeReaderSamplePageControlDelegate <NSObject>

@optional
-(void) rightNavEventHandler:(id)sender;
-(void) leftNavEventHandler:(id)sender;
-(void) jumpPageEventHandler:(id)sender;
-(void) jumpToPrintPageEventHandler:(id)sender;

@end

@interface PxeReaderSamplePageControlViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSObject <PxeReaderSamplePageControlDelegate> *controlDelegate;

- (IBAction)actionEventHandler:(id)sender;

@end
