//
//  PxePlayerNotesHighlights.h
//  PxeReader
//
//  Created by Mason, Darren J on 9/17/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerPagesWebView.h"
#import "PxePlayerNotesHighlightsDelegate.h"

@interface PxePlayerNotesHighlights : UIView <UITextViewDelegate>

@property (nonatomic, weak) PxePlayerPagesWebView *webView;

@property (nonatomic, weak) id<PxePlayerNotesHighlightsDelegate> delegate;

@property (nonatomic, strong) UIView *modalWindow;
@property (nonatomic, strong) UIView *highLightPopUp;
@property (nonatomic, strong) UILabel *saving;
@property (nonatomic, strong) UITextView *notesView;
@property (nonatomic, strong) UIButton *shareable;
@property (nonatomic, strong) UIView *colorPanel;
@property (nonatomic, strong) UIButton *share;
@property (nonatomic, strong) UITextField *mathML;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIView *parentView;

@property (nonatomic, strong) UIView *warningView;
@property (nonatomic, strong) UILabel *warningTitle;
@property (nonatomic, strong) UIImageView *warningIconView;

- (id)initWithSuperView:(PxePlayerPagesWebView*)view
            withMessage:(NSString*) message
               andEvent:(NSString*)event;

-(void)setUIOnAnnotateAdd:(NSString*)jsonString;

-(void)resizeWindow:(BOOL)isPortrait;

@end
