//
//  PxeReaderViewController.h
//  PxePlayerApp
//
//  Created by Satyanarayana SVV on 10/30/13.
//  Copyright (c) 2013 HappiestMinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxePlayerDataInterface.h"
#import "PxePlayerBook.h"
#import "PxeReaderSampleToolbarViewController.h"
#import "PxeReaderAnnotationsViewController.h"
#import "PxeReaderBookmarkListViewController.h"
#import "PxeReaderSearchViewController.h"
#import "PxeReaderSamplePageControlViewController.h"
#import "PxePlayerLabelProvider.h"
#import "PxeReaderTOCViewController.h"
#import "PxePlayerSampleFontThemeViewController.h"
#import "PxeReaderSampleMenuViewController.h"

@interface PxeReaderSampleViewController : UIViewController <PxeReaderToolbarDelegate,
                                                             PxeReaderMenuDelegate,
                                                             AnnotationsDelegate,
                                                             BookmarksDelegate,
                                                             PxeReaderSamplePageControlDelegate,
                                                             SearchDelegate,
                                                             PxePlayerLabelProviderDelegate,
                                                             tocDelegate,
                                                             FontsThemesDelegate>

@property (nonatomic, strong) PxePlayerDataInterface *dataInterface;
@property (nonatomic, strong) NSArray* pageUrls;
@property (nonatomic, strong) UIPopoverController *pcController;
@property (nonatomic, strong) PxePlayerBook *currentBook;
@property (nonatomic, strong) NSDictionary *bookData;

@property (nonatomic, strong) PxePlayerSampleFontThemeViewController *fontThemeVC;

@end
