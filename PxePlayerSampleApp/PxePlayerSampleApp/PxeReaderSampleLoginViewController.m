//
//  PxePlayerSampleLoginViewController.m
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/19/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderSampleLoginViewController.h"
#import "PxePlayer.h"
#import "PxePlayerUser.h"
#import "PxePlayerEnvironmentContext.h"
#import "PxeReaderResetTokensViewController.h"

#include <stdlib.h>

@interface PxeReaderSampleLoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;

@end

@implementation PxeReaderSampleLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int rand = arc4random_uniform(3);
    
    UIImage *tagImage;
    if (rand == 0) {
        tagImage = [UIImage imageNamed: @"Always_Learning _ENG_W.png"];
    } else if (rand == 1) {
        tagImage = [UIImage imageNamed: @"Always_Learning _FRA_W.png"];
    } else {
        tagImage = [UIImage imageNamed: @"Always_Learning_POL_W.png"];
    }
    NSLog(@"Random Number For tagImage: %d", rand);
    self.tagLine.image = tagImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    PxePlayerEnvironmentContext *environmentContext = [[PxePlayerEnvironmentContext alloc] initWithWebAPIEndpoint:@"https://paperapi-qa.stg-openclass.com/"
                                                                                             searchServerEndpoint:@"https://dragonfly-qa.stg-openclass.com/"
                                                                                              pxeServicesEndpoint:@"https://pxe-sdk-qa.stg-openclass.com/"
                                                                                                   pxeSDKEndpoint:@"https://pxe-sdk-qa.stg-openclass.com/"];
    NSError* error;
    BOOL success = [[PxePlayer sharedInstance] updatePxeEnvironment:environmentContext error:&error];
    if (success)
    {
        if ([segue.identifier isEqualToString:@"horizonalSlider"]) {
            PxePlayerUser *ppu = [PxePlayerUser new];
            ppu.identityId = self.username.text;
            ppu.authToken = @"ST-37518-ayY2m0tQYBnln4h2AIJG-b3-rumba-int-01-03";
        
            [[PxePlayer sharedInstance] setCurrentUser:ppu];
        }
        else if ([segue.identifier isEqualToString:@"resetTokens"]) {
            
            PxeReaderResetTokensViewController *resetTokensVS = segue.destinationViewController;
            resetTokensVS.username = self.username.text;
            resetTokensVS.password = self.password.text;
        }
    } else {
        NSLog(@"Error Updating PxePlayerEnvironemnt: %@", error);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)resetTokens:(id)sender {
    
    [self performSegueWithIdentifier:@"resetTokens" sender:self];
}

@end
