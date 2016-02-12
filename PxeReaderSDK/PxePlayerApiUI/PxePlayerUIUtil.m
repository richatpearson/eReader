//
//  NTUtil.m
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerUIUtil.h"
#import "PxePlayerUIConstants.h"

#define kDefaultFont [UIFont systemFontOfSize:12]
#define kDefaultBgColor [UIColor clearColor]
#define kDefaultTextColor [UIColor blackColor]

@implementation PxePlayerUIUtil

+(UILabel*)createLabelWithTitle:(NSString*)title frame:(CGRect)frame {
    
    return [self createLabelWithTitle:title frame:frame alignment:NSTextAlignmentLeft
                             withFont:kDefaultFont backGroundColor:kDefaultBgColor
                            textColor:kDefaultTextColor];
}

+(UILabel*)createLabelWithTitle:(NSString*)title frame:(CGRect)frame alignment:(NSTextAlignment)alignment {
    
    return [self createLabelWithTitle:title frame:frame alignment:alignment
                             withFont:[UIFont systemFontOfSize:12] backGroundColor:[UIColor clearColor]
                            textColor:[UIColor blackColor]];    
}

+(UILabel*)createLabelWithTitle:(NSString*)title frame:(CGRect)frame alignment:(NSTextAlignment)alignment
                       withFont:(UIFont*)font backGroundColor:(UIColor*)bgColor textColor:(UIColor*)textColor {
    
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = bgColor;
    label.textColor = textColor;
    label.textAlignment = alignment;
    label.text = title;
    label.font = font;
    return label;
}

+(UIBarButtonItem*)createBarButtonItemFixedSpaceWithTarget:(id)target action:(SEL)action width:(CGFloat)width{
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:target action:action];
    barItem.width = width;
    return barItem;
}

+(UIButton*)createButtonWithBackgroundImage:(NSString*)imageName andText:(NSString*)text {
    UIImage* image = [UIImage imageNamed:BUNDLE_FILE(imageName)];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    UIButton* btn = [self createButtonWithFrame:CGRectMake(0.0f, 0.0f, width, height) title:text type:UIButtonTypeCustom];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    
    return btn;
}

+(UIButton*)createButtonWithImage:(UIImage*)image
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    UIButton *button = [self createButtonWithFrame:CGRectMake(0.0f, 0.0f, width, height) type:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    
    return button;
}

+(UIButton*)createButtonWithFrame:(CGRect)frame type:(UIButtonType)type
{
    return [self createButtonWithFrame:frame title:@"" type:type];
}

+(UIButton*)createButtonWithFrame:(CGRect)frame title:(NSString*)title type:(UIButtonType)type
{
    UIButton *button = [UIButton buttonWithType:type];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    
    return button;
}


+(UITextField*)createTextFieldWithFrame:(CGRect)frame text:(NSString*)text placeHolder:(NSString*)placeHolder borderStyle:(UITextBorderStyle)borderStyle
{
    return [self createTextFieldWithFrame:frame text:text placeHolder:placeHolder borderStyle:borderStyle secure:NO];
}

+(UITextField*)createTextFieldWithFrame:(CGRect)frame text:(NSString*)text placeHolder:(NSString*)placeHolder borderStyle:(UITextBorderStyle)borderStyle secure:(BOOL)isSecure
{
    return [self createTextFieldWithFrame:frame text:text placeHolder:placeHolder borderStyle:borderStyle autoCorrection:UITextAutocorrectionTypeNo autoCapitalization:UITextAutocapitalizationTypeNone secure:isSecure];
}

+(UITextField*)createTextFieldWithFrame:(CGRect)frame text:(NSString*)text placeHolder:(NSString*)placeHolder borderStyle:(UITextBorderStyle)borderStyle autoCorrection:(NSInteger)autoCorrection autoCapitalization:(NSInteger)autoCapitalization secure:(BOOL)isSecure
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.text = text;
    textField.placeholder = placeHolder;
    textField.borderStyle = borderStyle;
    textField.autocorrectionType = autoCorrection;
    textField.autocapitalizationType = autoCapitalization;
    textField.secureTextEntry = isSecure;
    
    return textField;
}

+(UIImageView*)createImageViewWithFileName:(NSString*)fileName
{
    UIImage *image = [UIImage imageNamed:BUNDLE_FILE(fileName)];
    return [[UIImageView alloc] initWithImage:image];    
}

+(UIImageView*)createImageViewWithFileName:(NSString*)fileName frame:(CGRect)frame contentMode:(UIViewContentMode)contentMode
{
    UIImage *image = [UIImage imageNamed:BUNDLE_FILE(fileName)];
    
    return [self createImageViewWithImage:image frame:frame backgroundColor:[UIColor clearColor] contentMode:contentMode];
}

+(UIImageView*)createImageViewWithImage:(UIImage*)image frame:(CGRect)frame backgroundColor:(UIColor*)p_color contentMode:(UIViewContentMode)contentMode
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:frame];
    [imageView setBackgroundColor:p_color];
    [imageView setContentMode:contentMode];
    
    return imageView;
}

+(UIImage*)getLine:(CGSize)size withColor:(CGColorRef)color
{
    UIImage *lineImage = nil;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, size.height * 0.5f);
    CGContextMoveToPoint(context, 0.0f, size.height * 0.25f);
    CGContextAddLineToPoint(context, size.width, 0.0f);
    CGContextStrokePath(context);
    lineImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return lineImage;
}


@end
