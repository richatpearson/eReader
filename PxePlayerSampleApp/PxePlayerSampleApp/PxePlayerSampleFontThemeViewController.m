//
//  PxePlayerSampleFontThemeViewController.m
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 11/19/15.
//  Copyright © 2015 Mason, Darren J. All rights reserved.
//

#import "PxePlayerSampleFontThemeViewController.h"

@interface PxePlayerSampleFontThemeViewController ()

@end

@implementation PxePlayerSampleFontThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.closeButton.hidden = YES;
    } else {
        self.closeButton.hidden = NO;;
    }
}

- (void)didReceiveMemoryWarning {
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

- (IBAction)fontDecrease:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeFontSize:)])
    {
        [self.delegate performSelector:@selector(changeFontSize:) withObject:@"decrease"];
    }
}

- (IBAction)fontIncrease:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeFontSize:)])
    {
        [self.delegate performSelector:@selector(changeFontSize:) withObject:@"increase"];
    }
}

- (IBAction)themeDay:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeTheme:)])
    {
        [self.delegate performSelector:@selector(changeTheme:) withObject:@"day"];
    }
}

- (IBAction)themeSepia:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeTheme:)])
    {
        [self.delegate performSelector:@selector(changeTheme:) withObject:@"sepia"];
    }
}

- (IBAction)themeNight:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeTheme:)])
    {
        [self.delegate performSelector:@selector(changeTheme:) withObject:@"night"];
    }
}


- (IBAction)closeFontsThemes:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate fontsThemesDidClose];
    }];
}

#pragma mark popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"popOverDismissed");
}

- (void) dealloc
{
    self.delegate = nil;
}

@end
