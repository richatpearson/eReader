//
//  NTUtil.h
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Class

@interface PxePlayerUIUtil : NSObject

/***************************************
 
 // data UI helpers
 
 ***************************************/

+(UILabel*)createLabelWithTitle:(NSString*)title frame:(CGRect)frame;
+(UILabel*)createLabelWithTitle:(NSString*)title frame:(CGRect)frame alignment:(NSTextAlignment)alignment;
+(UILabel*)createLabelWithTitle:(NSString*)title frame:(CGRect)frame alignment:(NSTextAlignment)alignment
                       withFont:(UIFont*)font backGroundColor:(UIColor*)bgColor textColor:(UIColor*)textColor;
+(UIBarButtonItem*)createBarButtonItemFixedSpaceWithTarget:(id)target action:(SEL)action width:(CGFloat)width;

+(UIButton*)createButtonWithBackgroundImage:(NSString*)imageName andText:(NSString*)text;
+(UIButton*)createButtonWithImage:(UIImage*)image;
+(UIButton*)createButtonWithFrame:(CGRect)frame type:(UIButtonType)type;
+(UIButton*)createButtonWithFrame:(CGRect)frame title:(NSString*)title type:(UIButtonType)type;

+(UITextField*)createTextFieldWithFrame:(CGRect)frame text:(NSString*)text placeHolder:(NSString*)placeHolder borderStyle:(UITextBorderStyle)borderStyle;
+(UITextField*)createTextFieldWithFrame:(CGRect)frame text:(NSString*)text placeHolder:(NSString*)placeHolder borderStyle:(UITextBorderStyle)borderStyle secure:(BOOL)isSecure;
+(UITextField*)createTextFieldWithFrame:(CGRect)frame text:(NSString*)text placeHolder:(NSString*)placeHolder borderStyle:(UITextBorderStyle)borderStyle autoCorrection:(NSInteger)autoCorrection autoCapitalization:(NSInteger)autoCapitalization secure:(BOOL)isSecure;
+(UIImageView*)createImageViewWithFileName:(NSString*)fileName;
+(UIImageView*)createImageViewWithFileName:(NSString*)fileName frame:(CGRect)frame contentMode:(UIViewContentMode)contentMode;
+(UIImageView*)createImageViewWithImage:(UIImage*)image frame:(CGRect)frame backgroundColor:(UIColor*)p_color contentMode:(UIViewContentMode)contentMode;

/***************************************
    // graphics rendering helpers
 
 ***************************************/
 
+(UIImage*)getLine:(CGSize)size withColor:(CGColorRef)color;

@end
