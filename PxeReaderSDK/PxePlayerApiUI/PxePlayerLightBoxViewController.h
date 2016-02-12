//
//  PxePlayerLightBoxViewController.h
//  PxePlayerApi
//
//  Created by Satyanarayana SVV on 1/9/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PXE_MEDIA_TYPE          @"type"
#define PXE_MEDIA_TYPE_IMAGE    @"image"
#define PXE_MEDIA_URL_PATH      @"contentUrl"
#define PXE_MEDIA_TITLE         @"title"
#define PXE_MEDIA_CAPTION       @"caption"
#define PXE_MEDIA_ERROR         @"error"
#define PXE_MEDIA_FILE_TYPE     @"fileType"

@protocol PxePlayerLightboxDelegate <NSObject>

@optional
- (void) lightboxDidClose;

@end

/**
 Simple class to display image, gadget and external URL's in the lightbox view
 */
@interface PxePlayerLightBoxViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

/**
 Denotes if view should open as lightbox or internal browser
 */
@property BOOL isLightbox;

/**
  NSDictionary object which holds the necessary object information to render into the screen
 */
@property (nonatomic, strong) NSDictionary *boxInfo;

/**
 
 */
@property (nonatomic, weak) id<PxePlayerLightboxDelegate> delegate;

/**
 
 */
@property (nonatomic, strong) NSString *bundlePath;

/**
 
 */
@property (nonatomic, assign) BOOL lightBoxConfigured;

- (IBAction) showMoreCaption;

// GETS
- (UIWebView *) getLightBoxWebView;
- (UIProgressView *) getProgressView;

@end
