//
//  PxeReaderSampleMenuViewController.h
//  
//
//  Created by Tomack, Barry on 1/7/16.
//
//

#import <UIKit/UIKit.h>

@protocol PxeReaderMenuDelegate <NSObject>

@optional

-(void)searchEventHandler:(id)sender;
-(void)tocEventHandler:(id)sender;
-(void)annotationsEventHandler:(id)sender;
-(void)bookmarksEventHandler:(id)sender;
-(void)glossaryEventHandler:(id)sender;
-(void)customBasketEventHandler:(id)sender;
-(void)settingsEventHandler:(id)sender;

@end

@interface PxeReaderSampleMenuViewController : UIViewController

@property (nonatomic, strong) id<PxeReaderMenuDelegate> menuDelegate;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *tocButton;
@property (weak, nonatomic) IBOutlet UIButton *annotationsButton;
@property (weak, nonatomic) IBOutlet UIButton *bookmarksButton;
@property (weak, nonatomic) IBOutlet UIButton *glossaryButton;
@property (weak, nonatomic) IBOutlet UIButton *customBasketButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@end
