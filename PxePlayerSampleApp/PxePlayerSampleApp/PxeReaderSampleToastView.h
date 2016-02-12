//
//  PxeReaderSampleToastView.h
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 7/9/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PxeReaderSampleToastView : UIView

@property (strong, nonatomic) NSString *text;

+ (void)showToastInParentView:(UIView *)parentView
                     withText:(NSString *)text
                withDuration:(float)duration;

@end
