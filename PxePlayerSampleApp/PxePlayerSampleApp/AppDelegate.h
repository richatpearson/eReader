//
//  AppDelegate.h
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/19/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerLabelProvider.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) void(^backgroundTransferCompletionHandler)();

@property (nonatomic, strong) NSString *webAPIEndpoint;
@property (nonatomic, strong) NSString *searchServerEndpoint;
@property (nonatomic, strong) NSString *pxeServicesEndpoint;
@property (nonatomic, strong) NSString *pxeSDKEndpoint;

@end

