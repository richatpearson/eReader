//
//  NTPagesWebView.m
//  NTApi
//
//  Created by Saro Bear on 10/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerPagesWebView.h"
#import "PxePlayer.h"
#import "PxePlayerUIConstants.h"
#import "PXEPlayerMacro.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "PxePlayerNotesHighlights.h"
#import "UIMenuItem+CXAImageSupport.h"
#import "PxePlayerAlertView.h"
#import "PxePlayerNHUtility.h"
#import "NSString+Extension.h"

@interface PxePlayerPagesWebView ()

@property (nonatomic, strong) NSString *annotationMessage;

@property (nonatomic, assign) BOOL willDeleteNewAnnotation;

@end

@implementation PxePlayerPagesWebView

#pragma mark - Self methods

- (id) initWithFrame:(CGRect)frame
  withScalePageToFit:(BOOL)scalePageToFit
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationDidChange:)
                                                     name:PXEPLAYER_DID_WEBVIEW_ROTATE
                                                   object:nil];
        
        // Initialization code
        for (UIView* shadowView in [[[self subviews] objectAtIndex:0] subviews])
        {
            [shadowView setHidden:YES];
        }
        
        // unhide the last view so it is visible again because it has the content
        [[[[[self subviews] objectAtIndex:0] subviews] lastObject] setHidden:NO];
        
        self.backgroundColor = [UIColor clearColor];
        [self setOpaque:NO];
        self.scrollView.showsVerticalScrollIndicator = self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scalesPageToFit = scalePageToFit;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.menuControllerManager = [[PXEPlayerMenuControllerManager alloc] initWithWebView:self];
        [self.menuControllerManager setUpBaseMenuItems];
        self.shouldOpenNoteView = NO;
        self.willDeleteNewAnnotation = NO;
        self.isNoteViewOpen = NO;
        
        DLog(@"self.scalesPageToFit: %@", self.scalesPageToFit?@"YES":@"NO");
        DLog(@"getAnnotateState: %@", [[PxePlayer sharedInstance] getAnnotateState] ?@"YES":@"NO");
    }
    return self;
}

-(void)updateNote:(NSString*)jsonString
{
    DLog(@"jsonString: %@", jsonString);
    self.annotationMessage = jsonString;
    
    if (self.isNoteViewOpen) //update annotationDttm in notes view
    {
        self.noteView.currentAnnotationDttm = [PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage];
    }
    
    if (self.shouldOpenNoteView)
    {
        self.shouldOpenNoteView = NO;
        
        [self showNoteViewToAnnotate];
        DLog("Opened the notes view - set shouldOpenNoteView to NO");
    }
    
    if (self.willDeleteNewAnnotation)
    {
        [self stringByEvaluatingJavaScriptFromString:@"Annotate.instance.removeMobileAnnotation()"];
        self.willDeleteNewAnnotation = NO;
        
        [[PxePlayer sharedInstance] dispatchGAIEventWithCategory:@"annotation"
                                                          action:@"removeMobileAnnotation"
                                                           label:self.request.mainDocumentURL.absoluteString
                                                           value:nil];
    }
}

-(void) respondToAnnotationDataWithMessage:(NSString*)message event:(NSString*)event
{
    DLog(@"message: %@", message);
    
    self.isAnnotationNew = [PxePlayerNHUtility isAnnotationNewForMessage:message];
    self.annotationMessage = message;
    
    if ([PxePlayerNHUtility wasSidebarIconClicked:message])
    {
        [self showNoteViewToAnnotate];
        
        return;
    }
    
    PxePlayerHighlightColor color = [PxePlayerNHUtility parseColorCodeFromAnnotationMessage:self.annotationMessage];
    
    if (color == PxePlayerTurquoiseHighlight) //instructor note
    {
        NSString *noteText = [PxePlayerNHUtility parseNoteTextFromAnnotationMessage:self.annotationMessage];
        
        if ((noteText) && ![noteText isEqualToString:@""])
        {
            [self showNoteViewToAnnotate];
        }
        
        return;
    }
    
    if (!self.shouldOpenNoteView && !self.isNoteViewOpen && ![PxePlayerNHUtility isEventConfirmingDelete:self.annotationMessage])
    {
        DLog(@"shouldOpenNoteView is NO so we can open highlight menu items.");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.menuControllerManager setUpHighlightMenuItemsWithColor:color
                                                            baseMenuPosition:self.baseMenuPosition];
            });
        });
    }
}

- (void) orientationDidChange: (NSNotification *) orientation
{
    if (self.noteView) {
        [self.noteView adjustSelectionInViewForSize:[[[UIApplication sharedApplication] delegate] window].frame.size];
    }
    
    DLog(@"In web view - orientation did change and orientation is %d", [[orientation object] boolValue]);
    
    [UIMenuController sharedMenuController].menuVisible = NO;
    [self disableUserSelection]; //this hides the menu items
}

- (void) highlight:(id)sender
{
    self.isAnnotationNew = YES;
    
    PxePlayerHighlightColor lastColorUsed = (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"lastHighlightUsed"];
    DLog(@"Last color used is %ld", (long)lastColorUsed);
    
    [self saveAnnotationWithJavaScriptCall:[PxePlayerNHUtility buildJSCallForNote:@""
                                                                        colorCode:lastColorUsed
                                                                webViewRequestUri:self.request.URL.absoluteString
                                                                  isAnnotationNew:self.isAnnotationNew
                                                                   annotationDttm:[PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage]]];
    
    [self disableUserSelection];
}

- (void) showColorChoices:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.menuControllerManager setUpColorMenuItemsforBaseMenuPosition:self.baseMenuPosition];
        });
    });
}

- (void) highlightInYellow:(id)sender
{
    NSString *noteText = [PxePlayerNHUtility parseNoteTextFromAnnotationMessage:self.annotationMessage];
    
    [self saveAnnotationWithJavaScriptCall:[PxePlayerNHUtility buildJSCallForNote:noteText
                                                                        colorCode:PxePlayerYellowHighlight
                                                                webViewRequestUri:self.request.URL.absoluteString
                                                                  isAnnotationNew:self.isAnnotationNew
                                                                   annotationDttm:[PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage]]];
    
    [[NSUserDefaults standardUserDefaults] setInteger:PxePlayerYellowHighlight forKey:@"lastHighlightUsed"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.menuControllerManager setUpHighlightMenuItemsWithColor:PxePlayerYellowHighlight baseMenuPosition:self.baseMenuPosition];
        });
    });
}

- (void) highlightInPink:(id)sender
{
    NSString *noteText = [PxePlayerNHUtility parseNoteTextFromAnnotationMessage:self.annotationMessage];
    
    [self saveAnnotationWithJavaScriptCall:[PxePlayerNHUtility buildJSCallForNote:noteText
                                                                        colorCode:PxePlayerPinkHighlight
                                                                webViewRequestUri:self.request.URL.absoluteString
                                                                  isAnnotationNew:self.isAnnotationNew
                                                                   annotationDttm:[PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage]]];
    
    [[NSUserDefaults standardUserDefaults] setInteger:PxePlayerPinkHighlight forKey:@"lastHighlightUsed"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.menuControllerManager setUpHighlightMenuItemsWithColor:PxePlayerPinkHighlight baseMenuPosition:self.baseMenuPosition];
        });
    });
}

- (void) highlightInGreen:(id)sender
{
    NSString *noteText = [PxePlayerNHUtility parseNoteTextFromAnnotationMessage:self.annotationMessage];
    
    [self saveAnnotationWithJavaScriptCall:[PxePlayerNHUtility buildJSCallForNote:noteText
                                                                        colorCode:PxePlayerGreenHighlight
                                                                webViewRequestUri:self.request.URL.absoluteString
                                                                  isAnnotationNew:self.isAnnotationNew
                                                                   annotationDttm:[PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage]]];
    
    [[NSUserDefaults standardUserDefaults] setInteger:PxePlayerGreenHighlight forKey:@"lastHighlightUsed"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.menuControllerManager setUpHighlightMenuItemsWithColor:PxePlayerGreenHighlight baseMenuPosition:self.baseMenuPosition];
        });
    });
}

- (void) highlightInClear:(id)sender
{
    NSString *noteText = [PxePlayerNHUtility parseNoteTextFromAnnotationMessage:self.annotationMessage];
    
    [self saveAnnotationWithJavaScriptCall:[PxePlayerNHUtility buildJSCallForNote:noteText
                                                                        colorCode:PxePlayerClearHighlight
                                                                webViewRequestUri:self.request.URL.absoluteString
                                                                  isAnnotationNew:self.isAnnotationNew
                                                                   annotationDttm:[PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage]]];
    
    [[NSUserDefaults standardUserDefaults] setInteger:PxePlayerClearHighlight forKey:@"lastHighlightUsed"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.menuControllerManager setUpHighlightMenuItemsWithColor:PxePlayerClearHighlight baseMenuPosition:self.baseMenuPosition];
        });
    });
}

- (void) annotate:(id)sender
{
    self.shouldOpenNoteView = YES;
    
    PxePlayerHighlightColor lastColorUsed = (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"lastHighlightUsed"];
    DLog(@"Last color used is %ld", (long)lastColorUsed);
    
    self.isAnnotationNew = YES;
    [self saveAnnotationWithJavaScriptCall:[PxePlayerNHUtility buildJSCallForNote:@""
                                                                        colorCode:lastColorUsed
                                                                webViewRequestUri:self.request.URL.absoluteString
                                                                  isAnnotationNew:self.isAnnotationNew
                                                                   annotationDttm:[PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage]]];
}

- (void) annotateAfterHighlight:(id)sender
{
    [self showNoteViewToAnnotate];
}

- (void) showNoteViewToAnnotate
{
    if ([Reachability isReachable])
    {
        DLog(@"Show annotation");
        self.isNoteViewOpen = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //iPad device
        {
            NSString *ipadPopoverUrl = [NSString stringWithFormat:@"pxe-frame://oniPadPopover#%@",[self.annotationMessage urlEncodeUsingEncoding:NSUTF8StringEncoding]];
            DLog(@"Encoded iPad popover url is: %@", ipadPopoverUrl);
            
            NSMutableURLRequest *popOverRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:ipadPopoverUrl]];
            [self.delegate webView:self shouldStartLoadWithRequest:popOverRequest navigationType:UIWebViewNavigationTypeOther];
        }
        else //iPhone/iPod device
        {
            UIWindow *baseWindowForNote = [[[UIApplication sharedApplication] delegate] window]; //need cover the entire screen; adding to our web view still shows the top navigation bar
            
            self.noteView = [[PxePlayerNoteView alloc] initWithParentFrame:baseWindowForNote.frame
                                                           isAnnotationNew:self.isAnnotationNew
                                                         annotationMessage:(NSString*)self.annotationMessage
                                                         webViewRequestUri:self.request.URL.absoluteString];
            self.noteView.delegate = self;
            
            [baseWindowForNote addSubview:self.noteView];
        }
        
        [self disableUserSelection];
    }
}

- (void) deleteNote:(id)sender
{
    if ([PxePlayerNHUtility parseNoteTextFromAnnotationMessage:self.annotationMessage].length > 0) //pop up alert only if there is a note
    {
        PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Note", @"Alert title for delete")
                                                                      message:NSLocalizedString(@"This will delete both the note and highlight.", @"Message description")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Delete", @"Delete note and highlight")
                                                            otherButtonTitles:NSLocalizedString(@"Cancel", @"Cancel the delete"), nil];
        
        [alert setDelegate:self];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
    else
    {
        [self doConfirmedDelete];
    }
}

- (void) doConfirmedDelete
{
    DLog(@"Confirmed to delete N&H");
    
    if (self.isAnnotationNew) {
        DLog(@"Deleting a brand new annotation - must save first");
        
        NSString *noteText = [PxePlayerNHUtility parseNoteTextFromAnnotationMessage:self.annotationMessage];
        
        //TODO: need to make sure we still need it
        [self saveAnnotationWithJavaScriptCall:[PxePlayerNHUtility buildJSCallForNote:noteText
                                                                            colorCode:PxePlayerYellowHighlight
                                                                    webViewRequestUri:self.request.URL.absoluteString
                                                                      isAnnotationNew:self.isAnnotationNew
                                                                       annotationDttm:[PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage]]];
        self.willDeleteNewAnnotation = YES;
    }
    else
    {
        NSString *anntDttm = [PxePlayerNHUtility parseAnnotationDttmFromMessage:self.annotationMessage];
        NSString *jsFuncCall = [NSString stringWithFormat:@"Annotate.instance.removeMobileAnnotation({\"annotationDttm\":%@})", anntDttm];
        DLog(@"JS Delete call: %@", jsFuncCall);
        [self stringByEvaluatingJavaScriptFromString:jsFuncCall];
    }
}

- (void) closeNote
{
    self.noteView.delegate = nil;
    [self.noteView removeFromSuperview];
    self.isNoteViewOpen = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //Close iPad popover
    {
        NSString *ipadPopoveCloserUrl = [NSString stringWithFormat:@"pxe-frame://oniPadPopoverClose"];
        
        NSMutableURLRequest *closePopOverRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:ipadPopoveCloserUrl]];
        [self.delegate webView:self shouldStartLoadWithRequest:closePopOverRequest navigationType:UIWebViewNavigationTypeOther];
    }
}

- (void) saveAnnotationWithJavaScriptCall:(NSString*)jsCall
{
    [self stringByEvaluatingJavaScriptFromString:jsCall];
}

- (void)copySelection:(id)sender
{
    NSString *textSelection = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    DLog(@"Copy %@ to UIPasteboard", textSelection);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.persistent = YES;
    [pasteboard setString: textSelection];
    
    [self disableUserSelection];
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if((action == @selector(highlight:) || action == @selector(annotate:) || action == @selector(copySelection:) ||
        action == @selector(annotateAfterHighlight:) || action == @selector(showColorChoices:) || action == @selector(deleteNote:) ||
        action == @selector(highlightInYellow:) || action == @selector(highlightInPink:) || action == @selector(highlightInGreen:) ||
        action == @selector(highlightInClear:)) &&
       [[PxePlayer sharedInstance] getAnnotateState])
    {
        // Only enable UIMenuController if reachable
        // Remove this conditional when syncing is possible and just return YES
        if ([Reachability isReachable])
        {
            return YES;
        } else {
            return NO;
        }
    }
    if (action == @selector(accessibilityViewIsModal))
    {
        return YES;
    }
    return NO;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [super scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    
    if (scale <= self.scrollView.minimumZoomScale)
    {
        [scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
        [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, scrollView.contentSize.height)];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PXEPLAYER_DID_WEBVIEW_ROTATE
                                                  object:nil];
}

- (void) disableUserSelection
{
    self.userInteractionEnabled = NO;
    self.userInteractionEnabled = YES;
}

- (void) removeOrientationChangeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PXEPLAYER_DID_WEBVIEW_ROTATE object:nil];
}

#pragma mark - Alertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        DLog(@"Clicked Delete button in alert view");
        [self doConfirmedDelete];
    }
}

@end
