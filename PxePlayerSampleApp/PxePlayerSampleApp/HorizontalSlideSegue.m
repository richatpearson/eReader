//
//  HorizontalSlideSegue.m
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/19/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "HorizontalSlideSegue.h"

@implementation HorizontalSlideSegue

- (void) perform {
    
    UIView *sv = ((UIViewController *)self.sourceViewController).view;
    UIView *dv = ((UIViewController *)self.destinationViewController).view;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    dv.center = CGPointMake(sv.center.x + sv.frame.size.width,
                            dv.center.y);
    [window insertSubview:dv aboveSubview:sv];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         dv.center = CGPointMake(sv.center.x,
                                                 dv.center.y);
                         sv.center = CGPointMake(0 - sv.center.x,
                                                 dv.center.y);
                     }
                     completion:^(BOOL finished){
                         [[self sourceViewController] presentViewController:
                          [self destinationViewController] animated:NO completion:nil];
                     }];
}

@end
