//
//  PxeReaderResetTokensViewController.m
//  PxePlayerSampleApp
//
//  Created by Richard on 7/23/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderResetTokensViewController.h"
#import "PxePlayerRestConnector.h"
#import "PxePlayerUser.h"
#import "PxePlayerDataInterface.h"
#import "PxePlayerEnvironmentContext.h"
#import "PxeReaderSampleLoginViewController.h"

@interface PxeReaderResetTokensViewController ()

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) PxePlayerUser *pxeUser;
@property (nonatomic, strong) PxePlayer *pxePlayer;

@end

#define LAS_APIKEY @"ba09cf335cebdf1c48f565422ab3fcab"

@implementation PxeReaderResetTokensViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"username is: %@ and password is: %@", self.username, self.password);
    
    if (!self.username || !self.password || [self.username isEqualToString:@""] || [self.password isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"Login Error" message:@"Both username and password must be provided."];
        
        return;
    }
                                             
    PxePlayerEnvironmentContext *environmentContext = [[PxePlayerEnvironmentContext alloc] initWithWebAPIEndpoint:@"http://pxe-sdk.stg-openclass.com/"
                                                                                             searchServerEndpoint:@"http://dragonfly.stg-openclass.com/"
                                                                                              pxeServicesEndpoint:@"http://pxe-sdk.stg-openclass.com/"
                                                                                                   pxeSDKEndpoint:@"http://pxe-sdk.stg-openclass.com/"
                                                                                                  environmentType:PxePlayerQAEnv];
    
    self.pxeUser = [PxePlayerUser new];
    self.pxePlayer = [PxePlayer sharedInstance];
    NSError* error;
    BOOL success = [self.pxePlayer updatePxeEnvironment:environmentContext error:&error];
    
    if (success) { //login
        [self loginRevelUsername:self.username password:self.password];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginRevelUsername:(NSString*)username password:(NSString*)password
{
    NSURLRequest *loginRequest = [self buildNetworkRequestForLoginWithUsername:username andPassword:password];
    
    CompletionHandler loginCompletionHandler = ^(id userAuthData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                if (userAuthData) {
                    NSError* error;
                    NSDictionary *userAuthDict = [NSJSONSerialization JSONObjectWithData:userAuthData
                                                                                 options:kNilOptions
                                                                                   error:&error];
                    NSLog(@"Login response dict is %@", userAuthDict.description);
                    
                    self.authToken = [userAuthDict valueForKey:@"token"];
                    
                    if (!self.pxeUser.authToken) {
                        self.pxeUser.identityId = username;
                        self.pxeUser.authToken = [userAuthDict valueForKey:@"token"];
                        
                        [self.pxePlayer setCurrentUser:self.pxeUser];
                        [self.pxePlayer updateDataInterface:[self createDataInterface] onComplete:^(BOOL success, NSError *error) {
                            
                            NSLog(@"Back in call back - Success is %@", (success)?@"YES":@"NO");
                            [self updateUIElements];
                        }];
                    }
                    else {
                        [self.pxePlayer resetAuthToken:self.authToken];
                        [self.pxePlayer resetLearningContext:[self createLearningContext]];
                        
                        [self updateUIElements];
                    }
                }
                else{
                    NSLog(@"Received no data from login API...");
                }
            }
            else {
                //error condition
                NSLog(@"Received error from login API - %@", error.description);
                
                [self showAlertViewWithTitle:@"Login Error" message:@"Invalid login. Please try again."];
            }
        });
    };
    
    [PxePlayerRestConnector performNetworkCallWithRequest:loginRequest andCompletionHandler:loginCompletionHandler];
}

-(NSURLRequest*) buildNetworkRequestForLoginWithUsername:(NSString*)username
                                             andPassword:(NSString*)password
{
    NSURL *url = [NSURL URLWithString:@"http://las.stg-openclass.com/las-api/api/users/login"]; //auth API for Revel
    
    NSString *postString = [NSString stringWithFormat:@"{\"j_username\":\"%@\",\"j_password\":\"%@\"}", username, password];
    NSLog(@"postString is %@", postString);
    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:LAS_APIKEY forHTTPHeaderField:@"X-apiKey"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

- (PxePlayerDataInterface*) createDataInterface
{
    PxePlayerDataInterface* dataInterface = [[PxePlayerDataInterface alloc] init];
    
    dataInterface.authToken = self.pxeUser.authToken;
    dataInterface.learningContext = [self createLearningContext];
    dataInterface.contextId = @"555a576ae4b0c45f14172578";
    dataInterface.tocPath = @"/OPS/toc.ncx";
    dataInterface.onlineBaseURL = @"https://revel-stg.pearson.com/eps/sanvan/api/item/b24b022b-f37a-4b3e-80f7-1cbe688c8b4b/1/file/henslin_writing_space_prod_test03302015";
    dataInterface.afterCrossRefBehaviour = @"continue";
    
    return  dataInterface;
}

- (NSString*) createLearningContext
{
    NSDictionary *learningDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"1234", @"courseId",
                                  @"bookCat", @"bookCategory",
                                  @"102030", @"assetId",
                                  LAS_APIKEY, @"lasApiKey",
                                  self.authToken, @"lasAuthToken",
                                  @"stg", @"environment",
                                  nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:learningDict
                                                       options:0
                                                         error:nil];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void) updateUIElements
{
    self.authTokenView.text = self.pxePlayer.currentUser.authToken;
    self.learningContextView.text = [self.pxePlayer getLearningContext];
}

- (IBAction)refreshToken:(id)sender {
    
    [self loginRevelUsername:self.username password:self.password];
}

- (IBAction)goBackToLogin:(id)sender {
    
    PxeReaderSampleLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PxeReaderSampleLoginViewController"];
    [self presentViewController:loginVC animated:NO completion:nil];
}

- (void) showAlertViewWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", title)
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

@end
