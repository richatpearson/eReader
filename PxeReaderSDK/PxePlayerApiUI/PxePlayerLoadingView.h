//
//  PxePlayerLoadingView.h
//  PxePlayerApi
//
//  Created by Satyanarayana on 15/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LOADING_BORDER_SHOWN @"loadingBorder"
#define LOADING_BORDER_COLOR @"loadingBorderColor"
#define LOADING_BORDER_RADIUS @"loadingBorderRadius"
#define LOADING_BORDER_WIDTH @"loadingBorderWidth"
#define LOADING_BG_COLOR @"loadingColor"
#define LOADING_OPACITY @"loadingOpacity"

#define LOADING_TEXT_COLOR @"loadingTextColor"
#define LOADING_TEXT @"loadingText"

@interface PxePlayerLoadingView : UIView

/**
 This method creates and adds a loading view for covering the provided aSuperview.
 @param UIView, aSuperview the superview that will be covered by the loading view
 @return id, returns the constructed view, already added as a subview of the aSuperview
 */
+ (id)loadingViewInView:(UIView *)aSuperview;

/**
 *  Same as loadingViewInView only allows for border
 *
 *  @param aSuperview
 *  @param hasBorder
 *
 *  @return UIView
 */
+ (id)loadingViewInView:(UIView *)aSuperview withOptions:(NSDictionary*)options;

/**
 This method would be called to remove the loading view from the super view
 */
- (void)removeView;

@end
