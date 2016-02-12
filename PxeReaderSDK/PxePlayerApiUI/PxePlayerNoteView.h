//
//  PxePlayerNoteView.h
//  PxeReader
//
//  Created by Richard Rosiak on 9/24/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerAnnotation.h"

#define IPAD_RECT CGRectMake(0, 0, 320.0f, 480.0f)
#define IPAD_SIZE CGSizeMake(320.0f, 480.0f)

@protocol PxePlayerNoteViewDelegate <NSObject>

@required
- (void) closeNote;

- (void) saveAnnotationWithJavaScriptCall:(NSString*)jsCall;

@end

@interface PxePlayerNoteView : UIView <UITextViewDelegate>

@property (nonatomic, weak) id<PxePlayerNoteViewDelegate> delegate;

@property (nonatomic, strong) NSString *currentAnnotationDttm;

- (instancetype) initWithParentFrame:(CGRect)parentFrame
                     isAnnotationNew:(BOOL)isNew
                   annotationMessage:(NSString*)annotationMessage
                   webViewRequestUri:(NSString*)webViewUri;

- (void) adjustSelectionInViewForSize:(CGSize)size;

@end
