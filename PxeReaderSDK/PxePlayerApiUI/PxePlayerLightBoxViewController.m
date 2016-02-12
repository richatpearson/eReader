//
//  PxePlayerLightBoxViewController.m
//  PxePlayerApi
//
//  Created by Satyanarayana SVV on 1/9/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerLightBoxViewController.h"
#import "PxePlayer.h"
#import "PxePlayerRestConnector.h"
#import "HMCache.h"
#import "NSString+Extension.h"
#import "PXEPlayerCookieManager.h"
#import "PXEPlayerMacro.h"
#import "Reachability.h"

@interface PxePlayerLightBoxViewController ()
/**
 Button for going to next page in history
 */
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
/**
 Button for going back in history
 */
@property (weak, nonatomic) IBOutlet UIButton *backButton;
/***
 Button for refreshing uiwebview page
 */
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
/***
 Button that closed uiwebview
 */
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

/**
 Main background view
 */
@property (weak, nonatomic) IBOutlet UIView *mainView;

/**
 Label to display the information about image or gadget
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/**
 Label to display the title of the image or gadget
 */
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;

/**
 Label to display the title of the image or gadget
 */
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
/***
 Button that closed uiwebview
 */
@property (weak, nonatomic) IBOutlet UIButton *showMoreButton;

/**
 UIImageView to display the image in lightbox
 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/**
 UIWebView to load the gadget or external URL's in lightbox view
 */
@property (weak, nonatomic) IBOutlet UIWebView *wView;

/**

 */
@property (weak, nonatomic) IBOutlet UIView *lightboxHeaderBG;

/**
 
 */
@property (weak, nonatomic) IBOutlet UIView *lightboxFooterBG;

/**
 
 */
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) UITapGestureRecognizer *webTapRecognizer;

@property (strong, nonatomic) UITapGestureRecognizer *imageTapRecognizer;

@property(nonatomic, weak) NSTimer *progressTimer;

@end

@implementation PxePlayerLightBoxViewController
{
    CGRect footerFrame;
    
    BOOL timerBool;
}

#pragma mark - Self methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wView.delegate = self;
    self.progressView.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.bundlePath)
    {
        self.bundlePath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],@"PxeReaderResources.bundle"];
    }
    footerFrame = _lightboxFooterBG.frame;
    
    _titleLabel.text = @"";
    _captionLabel.text = @"";
    _captionTextView.text = @"";
    
    _titleLabel.hidden = YES;
    _captionLabel.alpha = 1.0f;
    _captionTextView.alpha = 0.0f;
    
    _captionTextView.textContainer.lineFragmentPadding = 0;
    _captionTextView.textContainerInset = UIEdgeInsetsZero;

    if(self.isLightbox)
    {
        self.lightBoxConfigured = [self configureLightBox];
    }
    else
    {
        self.lightBoxConfigured = [self configureInternalBrowser];
    }
}

- (BOOL) configureLightBox
{
    BOOL success = NO;
    
    // Lightbox Properties
    [_mainView setBackgroundColor:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.8f]];
    
    [_refreshButton setHidden:YES];
    [_backButton setHidden:YES];
    [_nextButton setHidden:YES];
    [_showMoreButton setHidden:YES];
    
    [_lightboxHeaderBG setBackgroundColor:[UIColor blackColor]];
    [_lightboxFooterBG setBackgroundColor:[UIColor blackColor]];
    
    [_closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"close-wht.png"]]
                            forState:UIControlStateNormal];
    
    self.wView.scalesPageToFit = YES;
    self.wView.contentMode = UIViewContentModeScaleAspectFit;
    self.wView.backgroundColor = [UIColor clearColor];
    
    self.webTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleWebTapFrom:)];
    [self.wView addGestureRecognizer:self.webTapRecognizer];
    self.webTapRecognizer.delegate = self;
    
    self.imageView.hidden = NO;
    self.imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTapFrom:)];
    [self.imageView addGestureRecognizer:self.imageTapRecognizer];
    self.imageTapRecognizer.delegate = self;
    self.imageView.userInteractionEnabled = YES;
    
    if (_refreshButton.hidden && _backButton.hidden && _nextButton.hidden && _showMoreButton.hidden)
    {
        if (_lightboxFooterBG.backgroundColor == [UIColor blackColor] && _lightboxHeaderBG.backgroundColor == [UIColor blackColor])
        {
            if (self.wView.backgroundColor == [UIColor clearColor])
            {
                success = YES;
            }
        }
        
    }
    
    return success;
}

- (BOOL) configureInternalBrowser
{
    BOOL success = NO;
    
    // Internal Browser Properties
    [_mainView setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    
    [_mainView setBackgroundColor:[UIColor whiteColor]];
    [_refreshButton setHidden:NO];
    [_backButton setHidden:NO];
    [_nextButton setHidden:NO];
    
    [_lightboxHeaderBG setBackgroundColor:[UIColor whiteColor]];
    [_lightboxFooterBG setBackgroundColor:[UIColor whiteColor]];
    
    [_closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"close.png"]]
                            forState:UIControlStateNormal];
    
    [_backButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"previous-page-browser_disabled.png"]] forState:UIControlStateNormal];
    [_nextButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"next-page-browser_disabled.png"]] forState:UIControlStateNormal];
    [_refreshButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"refresh-page.png"]] forState:UIControlStateNormal];
    
    self.wView.scalesPageToFit = YES;
    self.wView.multipleTouchEnabled = YES;
    self.wView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView.hidden = YES;
    
    if (!_refreshButton.hidden && !_backButton.hidden && !_nextButton.hidden && !_showMoreButton.hidden)
    {
        if (_lightboxFooterBG.backgroundColor == [UIColor whiteColor] && _lightboxHeaderBG.backgroundColor == [UIColor whiteColor])
        {
            if (self.wView.contentMode == UIViewContentModeScaleAspectFit)
            {
                success = YES;
            }
        }
        
    }
    
    return success;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![self analyseInfo])
    {
        [self closeEventHandler:nil];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    self.imageView = nil;
    self.titleLabel = nil;
    self.captionLabel = nil;
    self.captionTextView = nil;
    self.boxInfo = nil;
    self.showMoreButton = nil;
    self.progressView = nil;
    
    self.wView = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.wView loadHTMLString:@"about:blank" baseURL:nil];
    if(self.progressTimer)
    {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}

#pragma mark - private methods

- (IBAction)historyBack:(id)sender
{
    [self.wView goBack];
}

- (IBAction)historyNext:(id)sender
{
    [self.wView goForward];
}

- (IBAction)refreshPage:(id)sender
{
    [self.wView reload];
    self.progressView.progress = 0.0;
}

/**
 An event triggered from close button to dismiss the lightbox view
 @param id, sender it would be button from storyboard linked with the action called touch up inside
 */
- (IBAction)closeEventHandler:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate lightboxDidClose];
    }];
}

/**
 This method to be called to load an image from the provided information to light box
 @see [PxePlayerRestConnector responseDataWithURLAsync: withCompletionHandler:]
 */
- (void) loadImage
{
    NSString *mediaURL = [self.boxInfo valueForKey:PXE_MEDIA_URL_PATH];
    if(mediaURL)
    {
        DLog(@"incoming media URL: %@", mediaURL);
        BOOL forOnline = NO;
        if([Reachability isReachable])
        {
            forOnline = YES;
        }
        DLog(@"forOnline: %@", forOnline?@"YES":@"NO");
        mediaURL = [[PxePlayer sharedInstance] prependBaseURL: mediaURL forOnline:forOnline];
        
        DLog(@"updated media URL: %@", mediaURL);
        NSString *key = [mediaURL md5];
        DLog(@"HMCache key: %@", key);
        NSData *data = [HMCache objectForKey:key];
        self.wView.hidden = YES;
        self.imageView.hidden = NO;
        
        if (data)
        {
            self.imageView.image = [UIImage imageWithData:data];
            DLog(@"imageView CACHE Width: %f ::: Height: %f", self.imageView.bounds.size.width, self.imageView.bounds.size.height);
            DLog(@"    image CACHE Width: %f ::: Height: %f", self.imageView.image.size.width, self.imageView.image.size.height);
            [self setImageViewContentMode];
        }
        else
        {
            [PxePlayerRestConnector responseDataWithURLAsync:mediaURL withCompletionHandler:^(id receivedObj, NSError *error)
             {
                 if(!error)
                 {
                     [HMCache setObject:receivedObj forKey:key];
                     self.imageView.image = [UIImage imageWithData:receivedObj];
                     DLog(@"imageView RESPONSE Width: %f ::: Height: %f", self.imageView.image.size.width, self.imageView.image.size.height);
                     [self setImageViewContentMode];
                 }
             }];
        }
    }
    else
    {
        [self closeEventHandler:nil];
    }
}

- (void) setImageViewContentMode
{
    self.imageView.contentMode = UIViewContentModeCenter;
    if (self.imageView.bounds.size.width  < self.imageView.image.size.width ||
        self.imageView.bounds.size.height < self.imageView.image.size.height)
    {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

/**
 This method to be called to load a gadget or external URL from the provided information to light box
 @see UIWebView
 */
- (void) loadGadget
{
    self.imageView.hidden = YES;
    self.wView.hidden = NO;
    
    self.wView.backgroundColor = [UIColor clearColor];
    [self.wView setOpaque:NO];
    
    NSString *mediaURL = [self.boxInfo valueForKey:PXE_MEDIA_URL_PATH];
    DLog(@"mediaURL: %@", mediaURL);
    if(mediaURL)
    {
        BOOL forOnline = NO;
        
        if ([mediaURL rangeOfString:@"http:/"].location != NSNotFound || [mediaURL rangeOfString:@"https:/"].location != NSNotFound)
        {
            forOnline = YES;
        } else if ([Reachability isReachable])
        {
            forOnline = YES;
        }
        
        if(forOnline)
        {
            [self loadMediaWithUrl:mediaURL];
        }
        else
        {
            [self loadLocalMediaWithPath:mediaURL];
        }
    }
    else
    {
        [self closeEventHandler:nil];
    }
}

-(void) loadMediaWithUrl:(NSString*)url
{
    url = [[PxePlayer sharedInstance] prependBaseURL: url forOnline:YES];
    //set cookie headers
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setAllHTTPHeaderFields:[PXEPlayerCookieManager getRequestHeaders]];
    
    [self.wView loadRequest:request];
}

-(void) loadLocalMediaWithPath:(NSString*)path
{
    NSString *fileType = [self.boxInfo valueForKey:PXE_MEDIA_FILE_TYPE];
    
    if ([fileType isEqualToString:PXE_MEDIA_TYPE_IMAGE])
    {
        path = [NSString stringWithFormat:@"<img src=\"file://%@\"/>", path];
        [self.wView loadHTMLString:path  baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    }
}

/**
 This method to be called to analyse the provided information to render into the lightbox
 @return BOOL, returns the boolean value as true if provided information are expected else returns the false
 */
- (BOOL) analyseInfo
{
    NSString *mediaType = [self.boxInfo valueForKey:PXE_MEDIA_TYPE];
    
    if(!mediaType)
    {
        return NO;
    }
    
    [_titleLabel setText:[self.boxInfo valueForKey:PXE_MEDIA_TITLE]];
    
    NSString *captionText = [self filterCaption:[self.boxInfo valueForKey:PXE_MEDIA_CAPTION]];
    
    [_captionLabel setText:captionText];
    [_captionTextView setText:captionText];
    
    _captionLabel.alpha = 1.0f;
    _captionTextView.alpha = 0.0f;
    
    _captionTextView.textColor = [UIColor whiteColor];
    
    _captionTextView.textContainer.lineFragmentPadding = 0;
    _captionTextView.textContainerInset = UIEdgeInsetsZero;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = -0.38;
    
    NSDictionary *attrsDictionary =
  @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14.0f],
     NSParagraphStyleAttributeName: paragraphStyle,
     NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    _captionTextView.attributedText = [[NSAttributedString alloc] initWithString:_captionTextView.text attributes:attrsDictionary];
    
    _showMoreButton.hidden = ![self captionLabelIsTruncated];
    
    if(![mediaType caseInsensitiveCompare:PXE_MEDIA_TYPE_IMAGE])
    {
        [self loadImage];
    }
    else {
        [self loadGadget];
    }
    
    return YES;
}

- (BOOL) captionLabelIsTruncated
{
    CGSize sizeOfText = [_captionLabel.text boundingRectWithSize:CGSizeMake(_captionLabel.bounds.size.width, CGFLOAT_MAX)
                                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                      attributes:@{ NSFontAttributeName : _captionLabel.font }
                                                         context: nil].size;
    
    if (_captionLabel.frame.size.height < ceilf(sizeOfText.height))
    {
        return YES;
    }
    return NO;
}

- (void) showMoreCaption
{
    if ([_showMoreButton.titleLabel.text isEqualToString:@"Show More..."])
    {
        _captionLabel.alpha = 0.0f;
        _captionTextView.alpha = 1.0f;
        _captionTextView.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.8f];
        
        CGRect newFooterFrame = CGRectMake(footerFrame.origin.x, (footerFrame.origin.y - (200.0-footerFrame.size.height)), footerFrame.size.width, 200.0); //
        _lightboxFooterBG.frame = newFooterFrame;
        
        [_showMoreButton setTitle:@"Show Less..." forState:UIControlStateNormal];
    }
    else
    {
        _captionLabel.alpha = 1.0f;
        _captionTextView.alpha = 0.0f;
        _captionTextView.textColor = [UIColor whiteColor];
        
        _lightboxFooterBG.frame = footerFrame;
        
        [_showMoreButton setTitle:@"Show More..." forState:UIControlStateNormal];
    }
}

- (void) timerCallback
{
    DLog(@"Timer is running...");
    if (timerBool)
    {
        if (self.progressView.progress >= 1)
        {
            self.progressView.hidden = YES;
            [self.progressTimer invalidate];
            self.progressTimer = nil;
            DLog(@"TimerShouldStop");
        }
        else
        {
            self.progressView.progress += 0.05;
        }
    }
    else
    {
        self.progressView.progress += 0.005;
        if (self.progressView.progress >= 0.95)
        {
            self.progressView.progress = 0.95;
        }
    }
}

#pragma mark webview delegate


- (void) webViewDidStartLoad:(UIWebView *)webView
{
    DLog(@"SHOULD START TIMER");
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0;
    timerBool = NO;
    if (!self.progressTimer)
    {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667
                                                              target:self
                                                            selector:@selector(timerCallback)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    timerBool = YES;
    if([self.wView canGoBack])
    {
        [_backButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"previous-page-browser.png"]] forState:UIControlStateNormal];
    }
    else
    {
        [_backButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"previous-page-browser_disabled.png"]] forState:UIControlStateNormal];
    }
    
    if([self.wView canGoForward])
    {
        [_nextButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"next-page-browser.png"]] forState:UIControlStateNormal];
    }
    else
    {
        [_nextButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"next-page-browser_disabled.png"]] forState:UIControlStateNormal];
    }
    webView.scrollView.delegate = self;
    webView.scrollView.maximumZoomScale = 5;
    webView.scrollView.minimumZoomScale = 1;
    DLog(@"WEB VIEW DID FINISH LOAD><><><><><><><><><><><><><");
}

#pragma mark - UIScrollView Delegate Methods

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.wView.scrollView.maximumZoomScale = 5;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark GestureRecognizer Delegate

- (void) handleWebTapFrom: (UITapGestureRecognizer *)recognizer
{
    DLog(@"recognizer: %@", recognizer);
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        DLog(@"wView has been tapped by the user.")
    }
}

- (void) handleImageTapFrom: (UITapGestureRecognizer *)recognizer
{
    DLog(@"recognizer: %@", recognizer);
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        DLog(@"imageView has been tapped by the user.")
        [self showHideTitleAndCaption];
    }
}

- (void) showHideTitleAndCaption
{
    if (_titleLabel.hidden == YES && _titleLabel.alpha == 1.0f)
    {
        _titleLabel.hidden = NO;
    } else {
        _titleLabel.hidden = YES;
    }
    if (self.lightboxFooterBG.hidden == YES)
    {
        self.lightboxFooterBG.hidden = NO;
        if (self.imageView.hidden == NO)
        {
            [self imageFadeTransitionToFull:NO];
        }
    }
    else
    {
        self.lightboxFooterBG.hidden = YES;
        if (self.imageView.hidden == NO)
        {
            [self imageFadeTransitionToFull:YES];
        }
    }
}

- (void) imageFadeTransitionToFull:(BOOL)toFull
{
    [self.imageView setAlpha:1.0f];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        //fade out
        [self.imageView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        //fade in
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.imageView setAlpha:1.0f];
            if (toFull)
            {
                self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            else
            {
                self.imageView.contentMode = UIViewContentModeCenter;
                if (self.imageView.bounds.size.width < self.imageView.image.size.width ||
                    self.imageView.bounds.size.height < self.imageView.image.size.height)
                {
                    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                }
            }
            
        } completion:nil];
        
    }];
}
     
- (NSString*) filterCaption:(NSString*)captionText
{
    if (captionText)
    {
        NSString *filteredString = [captionText stringByReplacingOccurrencesOfString:@"[ ]+"
                                                                          withString:@" "
                                                                             options:NSRegularExpressionSearch
                                                                               range:NSMakeRange(0, captionText.length)];
        
        filteredString = [filteredString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        return filteredString;
    }
    return captionText;
}

- (UIWebView *) getLightBoxWebView
{
    return self.wView;
}

- (UIProgressView *) getProgressView
{
    return self.progressView;
}

@end
