//
//  ProgressBarView.m
//  circular_progress_bar
//
//  Created by Mason, Darren J on 3/27/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "ProgressBarView.h"

@interface ProgressBarView()
    @property (nonatomic,retain) CAShapeLayer *progressLayer;
@end

@implementation ProgressBarView

#pragma mark - init methods
/**
 *  Call when you want to set the frame size
 *
 *  @param frame CGRect
 *
 *  @return ProgressBarView
 */
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createProgressLayer];
    }
    
    return self;

}
/**
 *  Called when the storyboard defines the uiview
 *
 *  @param aDecoder NSCoder
 *
 *  @return ProgressBarView
 */
-(id)initWithCoder:(NSCoder *)aDecoder{

    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self createProgressLayer];
    }
    
    return self;
}
#pragma mark - progress set up
-(void)resetProgresslayer{
    _progressLayer.strokeEnd = 0.0;
}

-(void)changeProgressStrokeColor:(UIColor*)color{
    _progressLayer.strokeColor = color.CGColor;
}

-(void)createCustomProgressLayer:(NSDictionary*)layerOptions{

    CGFloat startAngle = -M_PI_2;           //starts at 12 o'clock
    CGFloat endAngle = M_PI * 2 - M_PI_2;   //ends at 12 o'clock
    CGPoint enterPoint = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2); //center point of the uiview with some padding
    int padding = 6;
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:enterPoint radius:CGRectGetWidth(self.frame)/2-padding startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    //create a color gradient for progress
//    CAGradientLayer *gradientMaskLayer = [self gardientMaskTopColor:layerOptions[@"topColor"] andBotomColor:layerOptions[@"bottomColor"]];
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.path = circle.CGPath;
    _progressLayer.backgroundColor = ((UIColor*)layerOptions[@"backgroundColor"]).CGColor;
    if(![layerOptions[@"fillColor"] isEqual:@""])
        _progressLayer.fillColor = ((UIColor*)layerOptions[@"fillColor"]).CGColor;
    else
        _progressLayer.fillColor = nil;
    
    _progressLayer.strokeColor = ((UIColor*)layerOptions[@"strokeColor"]).CGColor;
    _progressLayer.lineWidth = [layerOptions[@"lineWidth"] doubleValue];
    _progressLayer.strokeStart = [layerOptions[@"strokeStart"] doubleValue]; //starting with nothing
    _progressLayer.strokeEnd = [layerOptions[@"strokeEnd"] doubleValue]; //ending with nothing
    _progressLayer.lineCap = layerOptions[@"lineCap"];
    
//    gradientMaskLayer.mask = _progressLayer;
    [self.layer addSublayer:_progressLayer];

}
/**
 *  Sets up the progress layer as a circle the size of this frame
 *  @private
 */
-(void)createProgressLayer{

    NSDictionary *options = @{@"topColor":@"",
                              @"bottomColor":@"",
                              @"backgroundColor":[UIColor greenColor],
                              @"fillColor":@"",
                              @"strokeColor":PROGRESS_COLOR,
                              @"lineWidth":@(2.0),
                              @"strokeStart":@(0.0),
                              @"strokeEnd":@(0.0),
                              @"lineCap":@"round"
                              };
    
    [self createCustomProgressLayer:options];

}
/**
 *  Simple little gradient this one is top lighter than bottom 
 * @optional
 *
 *  @return CAGradientLayer
 */
-(CAGradientLayer*)gardientMaskTopColor:(UIColor*)colorTop andBotomColor:(UIColor*)colorBottom{

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    
    //default colors
    if([colorTop isEqual:@""])
        colorTop = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    if([colorBottom isEqual:@""])
        colorBottom = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
    
    NSArray *colorArray = [NSArray arrayWithObjects:(id)colorTop.CGColor,(id)colorBottom.CGColor, nil];
    
    gradientLayer.colors = colorArray;
    
    return gradientLayer;
}
#pragma mark - public methods

-(void)setProgress:(float)endStroke{
    NSLog(@"setProgress: %f", endStroke);
    NSLog(@"hidden: %@", self.hidden?@"YES":@"NO");
    _progressLayer.strokeEnd = endStroke; //adds a end stroke float each time this is called
}

-(void)animateProgressView{
    
    _progressLayer.strokeEnd = 0.0;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    animation.duration = 1.0;
    animation.delegate = self;
    animation.removedOnCompletion = false;
    animation.additive = true;
    animation.fillMode = kCAFillModeForwards;
    
    [_progressLayer addAnimation:animation forKey:@"strokeEnd"];
 
}

@end
