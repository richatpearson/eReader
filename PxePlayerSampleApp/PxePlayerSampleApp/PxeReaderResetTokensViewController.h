//
//  PxeReaderResetTokensViewController.h
//  PxePlayerSampleApp
//
//  Created by Richard on 7/23/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayer.h"

@interface PxeReaderResetTokensViewController : UIViewController

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (strong, nonatomic) IBOutlet UITextView *learningContextView;
@property (strong, nonatomic) IBOutlet UITextView *authTokenView;

@end
