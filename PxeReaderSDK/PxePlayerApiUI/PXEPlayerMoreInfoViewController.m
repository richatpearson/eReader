//
//  PXEPlayerMoreInfoViewController.m
//  PxeReader
//
//  Created by Tomack, Barry on 11/6/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PXEPlayerMoreInfoViewController.h"
#import "PxePlayerLightBoxViewController.h"
#import "PxePlayerUIConstants.h"
#import "PXEPlayerMacro.h"

@interface PXEPlayerMoreInfoViewController ()

@end

@implementation PXEPlayerMoreInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect viewFrame = CGRectMake(0, 0, 300, 200);
    self.view.frame = viewFrame;
    
    self.webView.delegate = self;
    
    [self viewSetCloseButtonVisibilty];
    [self viewSetTextValues];
}

- (void) viewSetCloseButtonVisibilty
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.closeButton.hidden = YES;
    } else {
        self.closeButton.hidden = NO;
    }
}

- (void) viewSetTextValues
{
    if (self.jsonDict)
    {
        self.titleLabel.text = [self.jsonDict objectForKey:@"term"];
        
        NSString *message = [self.jsonDict objectForKey:@"description"];
        if(message)
        {
            [self.webView loadHTMLString:[self encloseInHTML:message] baseURL:nil];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"More Info";
    
    DLog(@"self.closeButton.hidden = %@", self.closeButton.hidden?@"YES":@"NO");
    DLog(@"self.closeButton.x = %f", self.closeButton.frame.origin.x);
    DLog(@"self.closeButton.y = %f", self.closeButton.frame.origin.y);
}

- (NSString*) encloseInHTML:(NSString*)incoming
{
    NSString *opening = @"<html><head><script type=\"text/javascript\" src=\"https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML\"></script></head><body><span style=\"font-family: sans-serif; font-size: 14px; color:black;\">";
    NSString *closing = @"</span></body></html>";
    
    NSString *html = [NSString stringWithFormat:@"%@%@%@", opening, incoming, closing];
    NSLog(@"html: %@", html);
    return html;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark WebViewDelegate
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSMutableURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog(@"SHOULDSTARTLOADWITHREQUEST: %@ ::: %@ ::: %@", request, request.URL, request.URL.absoluteString);
    NSURL *blankURL = [[NSURL alloc] initWithString:@"about:blank"];
    DLog(@"SHOULDSTARTLOADWITHREQUEST blankURL: %@ ::: %@", blankURL, blankURL.absoluteString);
    NSURL *url = request.URL;
    if ([url isEqual: blankURL])
    {
        return YES;
    }
    
    return NO;
}

#pragma mark popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.titleLabel.text = @"";
}

- (void) dealloc
{
    self.webView.delegate = nil;
}

// IBAction can't be unit tested. Test with UI Automation tool.
- (IBAction) closeMoreInfo
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate moreInfoDidClose];
    }];
}

/* Old code for TextView
 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[message dataUsingEncoding:NSUnicodeStringEncoding]
 options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
 documentAttributes:nil
 error:nil];
 NSRange rangeOfString = NSMakeRange(0, [attributedString length]);
 UIFont *systemFont = [UIFont systemFontOfSize:14.0f];
 [attributedString addAttribute:NSFontAttributeName
 value:systemFont
 range:rangeOfString];
 
 self.messageTextView.attributedText = attributedString;
 [self.messageTextView sizeToFit];
 */


@end
