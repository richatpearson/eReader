//
//  ProgressBarView.h
//  circular_progress_bar
//
//  Created by Mason, Darren J on 3/27/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PROGRESS_COLOR [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:33.0/255.0 alpha:1]
#define PROGRESS_FINISH_COLOR [UIColor colorWithRed:92.0/255.0 green:203.0/255.0 blue:33.0/255.0 alpha:1]

@interface ProgressBarView : UIView
/**
 *  simple animation example
 */
-(void)animateProgressView;
/**
 *  Sets the progress of the progress bar
 *
 *  @param endStroke float
 */
-(void)setProgress:(float)endStroke;
/**
 *  Creates the progress bar
 */
-(void)createCustomProgressLayer:(NSDictionary*)options;
/**
 *  Clears the progress bar layer sets the stroke back to start 0
 */
-(void)resetProgresslayer;
/**
 *  Change the progress bar color
 *
 *  @param color UIColor
 */
-(void)changeProgressStrokeColor:(UIColor*)color;
@end

