//
//  PXEPlayerMoreInfoViewController.h
//  PxeReader
//
//  Created by Tomack, Barry on 11/6/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@protocol PXEPlayerMoreInfoDelegate <NSObject>

@optional

- (void)loadExternalLink:(NSString*)urlString;

- (void) moreInfoDidClose;

@end

@interface PXEPlayerMoreInfoViewController : GAITrackedViewController <UIPopoverControllerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) id<PXEPlayerMoreInfoDelegate> delegate;

@property (strong, nonatomic) NSDictionary *jsonDict;

- (IBAction) closeMoreInfo;

// Helper methods for unit testing
- (void) viewSetCloseButtonVisibilty;
- (void) viewSetTextValues;

@end
