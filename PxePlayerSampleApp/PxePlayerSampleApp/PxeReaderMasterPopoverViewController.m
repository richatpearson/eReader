//
//  PxeReaderMasterPopoverViewController.m
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/20/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderMasterPopoverViewController.h"

@interface PxeReaderMasterPopoverViewController ()

@end

@implementation PxeReaderMasterPopoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *close = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [close addTarget:self
              action:@selector(closeWindow:)
    forControlEvents:UIControlEventTouchUpInside];
    
    [close setTitle:@"Back" forState:UIControlStateNormal];
    [close setTintColor:[UIColor blackColor]];
    close.frame = CGRectMake(0, 0, 60, 40);
    [self.view addSubview:close];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
}

-(void)closeWindow:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
