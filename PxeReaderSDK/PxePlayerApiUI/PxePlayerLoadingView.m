//
//  PxePlayerLoadingView.m
//  PxePlayerApi
//
//  Created by Satyanarayana on 15/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerLoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PxePlayerLoadingView

#pragma mark - public methods
+ (id)loadingViewInView:(UIView *)aSuperview
{
    //default values
    NSDictionary *options=@{LOADING_BORDER_SHOWN:@YES,
                            LOADING_OPACITY : @.85,
                            LOADING_BORDER_COLOR : [UIColor whiteColor],
                            LOADING_BG_COLOR : [UIColor blackColor],
                            LOADING_BORDER_RADIUS : @13,
                            LOADING_BORDER_WIDTH : @8,
                            LOADING_TEXT : NSLocalizedString(@"Loading...", @"Loading"),
                            LOADING_TEXT_COLOR:[UIColor whiteColor]};
    
    return [PxePlayerLoadingView buildViewWithOptions:options inView:aSuperview];
}

+ (id)loadingViewInView:(UIView *)aSuperview withOptions:(NSDictionary*)options
{
    //default values
    options=@{LOADING_BORDER_SHOWN: options[LOADING_BORDER_SHOWN]? options[LOADING_BORDER_SHOWN] : @YES,
                            LOADING_OPACITY : options[LOADING_OPACITY] ? options[LOADING_OPACITY] : @0.85,
                            LOADING_BORDER_COLOR : options[LOADING_BORDER_COLOR] ? options[LOADING_BORDER_COLOR] : [UIColor whiteColor],
                            LOADING_BG_COLOR : options[LOADING_BG_COLOR] ? options[LOADING_BG_COLOR] : [UIColor blackColor],
                            LOADING_BORDER_RADIUS : options[LOADING_BORDER_RADIUS] ? options[LOADING_BORDER_RADIUS] : @13,
                            LOADING_BORDER_WIDTH : options[LOADING_BORDER_WIDTH] ? options[LOADING_BORDER_WIDTH] : @8,
                            LOADING_TEXT :     options[LOADING_TEXT] ? options[LOADING_TEXT] : NSLocalizedString(@"Loading...", @"Loading"),
                            LOADING_TEXT_COLOR:options[LOADING_TEXT_COLOR] ? options[LOADING_TEXT_COLOR] : [UIColor whiteColor]};
    
    return [PxePlayerLoadingView buildViewWithOptions:options inView:aSuperview];
}

- (void)removeView
{
    [self setHidden:YES];
}
#pragma mark - private
+(id) buildViewWithOptions:(NSDictionary*)options inView:(UIView *)aSuperview{
    
    PxePlayerLoadingView *loadingView = [[PxePlayerLoadingView alloc] initWithFrame:[aSuperview bounds]];
    if (!loadingView)
    {
        return nil;
    }
    
    loadingView.layer.borderColor = ((UIColor*)options[LOADING_BORDER_COLOR]).CGColor;//[[UIColor whiteColor] CGColor];
    loadingView.layer.opacity = [options[LOADING_OPACITY]floatValue];//0.85;
    loadingView.backgroundColor = (UIColor*)options[LOADING_BG_COLOR];//[UIColor blackColor];
    loadingView.opaque = NO;
    
    //this might not be wanted
    if([options[LOADING_BORDER_SHOWN] boolValue]){
        loadingView.layer.borderWidth = [options[LOADING_BORDER_WIDTH]floatValue]; //8;
        loadingView.layer.cornerRadius = [options[LOADING_BORDER_RADIUS]floatValue];//13;
    }
    
    
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [aSuperview addSubview:loadingView];
    
    const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
    CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
    
    if(aSuperview.bounds.size.height < (DEFAULT_LABEL_HEIGHT * 2.0f)) {
        DEFAULT_LABEL_HEIGHT = 0.0f;
    }
    
    CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:labelFrame];
    loadingLabel.text = options[LOADING_TEXT];  //NSLocalizedString(@"Loading...", @"Loading");
    loadingLabel.textColor = (UIColor*)options[LOADING_TEXT_COLOR]; //[UIColor whiteColor];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [loadingView addSubview:loadingLabel];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingView addSubview:activityIndicatorView];
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [activityIndicatorView startAnimating];
    
    CGFloat totalHeight = loadingLabel.frame.size.height + activityIndicatorView.frame.size.height;
    labelFrame.origin.x = floor(0.5 * (loadingView.frame.size.width - DEFAULT_LABEL_WIDTH));
    labelFrame.origin.y = floor(0.5 * (loadingView.frame.size.height - totalHeight));
    loadingLabel.frame = labelFrame;
    
    CGRect activityIndicatorRect = activityIndicatorView.frame;
    activityIndicatorRect.origin.x = 0.5 * (loadingView.frame.size.width - activityIndicatorRect.size.width);
    activityIndicatorRect.origin.y = loadingLabel.frame.origin.y + loadingLabel.frame.size.height;
    activityIndicatorView.frame = activityIndicatorRect;
    
    // Set up the fade-in animation
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
    
    
    return loadingView;

}

@end
