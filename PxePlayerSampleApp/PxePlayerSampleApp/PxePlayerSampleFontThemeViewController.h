//
//  PxePlayerSampleFontThemeViewController.h
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 11/19/15.
//  Copyright © 2015 Mason, Darren J. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FontsThemesDelegate <NSObject>

@optional

- (void) fontsThemesDidClose;

- (void) changeFontSize:(NSString *)direction;
- (void) changeTheme:(NSString *)theme;

@end

@interface PxePlayerSampleFontThemeViewController : UIViewController <UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)fontDecrease:(id)sender;
- (IBAction)fontIncrease:(id)sender;


- (IBAction)themeDay:(id)sender;
- (IBAction)themeSepia:(id)sender;
- (IBAction)themeNight:(id)sender;

- (IBAction)closeFontsThemes:(id)sender;

@property (weak, nonatomic) id<FontsThemesDelegate> delegate;

@end
