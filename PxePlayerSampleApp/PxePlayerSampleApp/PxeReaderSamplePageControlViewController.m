//
//  PxeReaderSampleControllerViewController.m
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/22/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderSamplePageControlViewController.h"

enum OPTIONS
{
    TOOLBAR_EVENT_JUMP,
    TOOLBAR_EVENT_LEFT,
    TOOLBAR_EVENT_RIGHT,
    TOOLBAR_PRINT_PAGE_JUMP
};

@interface PxeReaderSamplePageControlViewController ()

@property (strong, nonatomic) IBOutlet UITextField *jumpTo;

@property (strong, nonatomic) IBOutlet UITextField *jumpToPrint;

@end

@implementation PxeReaderSamplePageControlViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"PxeReaderSamplePageControlViewController viewDidLoad .................................................................................");
    self.nextButton.hidden = YES;
    self.previousButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionEventHandler:(id)sender
{
    NSInteger selectedAction = [sender tag];
    
    if(!self.controlDelegate) {
        return;
    }
    
    switch (selectedAction)
    {
        case TOOLBAR_EVENT_JUMP:
            if([self.controlDelegate respondsToSelector:@selector(jumpPageEventHandler:)]){
                [self.controlDelegate jumpPageEventHandler:sender];
            }
            break;
        case TOOLBAR_EVENT_LEFT:
            if([[self controlDelegate] respondsToSelector:@selector(leftNavEventHandler:)]){
                [[self controlDelegate] leftNavEventHandler:sender];
            }
            break;
        case TOOLBAR_EVENT_RIGHT:
            if([[self controlDelegate] respondsToSelector:@selector(rightNavEventHandler:)]){
                [[self controlDelegate] rightNavEventHandler:sender];
            }
            break;
        case TOOLBAR_PRINT_PAGE_JUMP:
            if([self.controlDelegate respondsToSelector:@selector(jumpToPrintPageEventHandler:)]){
                [self.controlDelegate jumpToPrintPageEventHandler:sender];
            }
        default:
            break;
    }
}

@end
