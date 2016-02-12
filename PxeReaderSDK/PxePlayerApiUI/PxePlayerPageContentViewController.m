//  PxePlayerPageContentViewController.m
//  eRPS
//
//  Created by Saro Bear on 10/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerPageContentViewController.h"
#import "PxePlayerPagesWebView.h"
#import "PxePlayer.h"
#import "PxePlayerRestConnector.h"
#import "PxePlayerUIConstants.h"
#import "HMCache.h"
#import "NSString+Extension.h"
#import "PxePlayerPage.h"
#import "PxePlayerLightBoxViewController.h"
#import "PXEPlayerCookieManager.h"
#import "PXEPlayerMacro.h"
#import "PXEPlayerEnvironment.h"
#import "PxePlayerError.h"
#import "PxePlayerPageViewController.h"
#import "PxePlayerDownloadManager.h"
#import "PxeURLProtocol.h"
#import "Reachability.h"
#import "PxePlayerUIEvents.h"
#import "PxePlayerUIConstants.h"
#import "PxePlayerAnnotationsTypes.h"
#import "PxePlayerAnnotation.h"
#import "PxePlayerAnnotations.h"
#import "PxePlayerLabelProvider.h"

#import "GAIDictionaryBuilder.h"

#define DISABLED @"disabled"

//The below RegEx pattern finds a string that satisfies the following criteria:
//1. It is a link tag <link ... />
//2. It has the following 3 attributes: title, rel and href, plus any additional attributes
//3. The value of the rel attribute must have the string "stylesheet" in it
//4. The value of the href attribute must have the string ".css" in it
//5. The 3 attributes (title, rel and href) can be in any order
#define LINK_THEME_REGEX @"<link[^>]+(?:title=[^>]+()|rel=[^>]*stylesheet[^>]+()|href=[^>]+\\.css[^>]+()){3}\\1\\2\\3>"

#define CENTER_OF_VIEW CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0.0f, 0.0f)

@interface PxePlayerPageContentViewController ()
{
    NSInteger _lastContentOffset;
}
/**
  Bool value which set the status of whether view has been rendered or not
 */
@property (nonatomic, assign) BOOL                      viewDidAppeared;

/**
 Bool value defines the status of whether page has been loaded or not
 */
@property (nonatomic, assign) BOOL                      isPageLoaded;

/**
 CGRect variable to for setting the frame for the content view
 */
@property (nonatomic, assign) CGRect                    contentFrame;

/**
 NSString variable for page url
 */
@property (nonatomic, strong) NSString                  *page;

/**
 NSString variable for page UUID
 */
@property (nonatomic, strong) NSString                  *pageUUID;

/**
 NSArray variable for having the array of highlights label
 */
@property (nonatomic, strong) NSArray                   *highlights;

/**
 Popover for glossary and more info
 */
@property (nonatomic, strong) UIPopoverController *moreInfoPopover;

@property (nonatomic, assign) BOOL isOffline;

@property (nonatomic, strong) UIViewController *modalPopOverVC;

@property (nonatomic, strong) UIPopoverPresentationController *presentationController;

@end

Reachability* internetReachable;

@implementation PxePlayerPageContentViewController


#pragma mark - Private methods

/**
 This method would be called when page has been loaded into the UIWebView
 @see [PxePlayerPageContentViewController gotoURLTag:]
 */
-(void)pageDidLoad
{
    DLog(@"In pageDidLoad for url: %@", [self getPageRelativeURL]);
    // ARC can actually deallocate in the middle of this method executing
    // in iOS 7. Page Loading still needs to be addressed.
    if(self)
    {
        [[self.pageContent stringByEvaluatingJavaScriptFromString:@"pxereader.initWidget()"] boolValue];
        
        if ([self respondsToSelector:@selector(gotoURLTag:)])
        {
            [self performSelector:@selector(gotoURLTag:) withObject:self.pageUUID afterDelay:0.0];
        }
        if([[self delegate] respondsToSelector:@selector(pageContentDidLoad:)])
        {
            //pageContentDidLoad is in the pxeplayerpageviewcontroller.m (the delegate)
            [[self delegate] pageContentDidLoad:self.page];
        }
        [self showSearchHighlightsOnPage];
    }
}

- (NSString*) injectHTML:(NSString*)htmlStr
               withNavId:(NSString*)navID
            relativePath:(NSString*)relativePath
               pageTitle:(NSString*)pageTitle
             isReachable:(BOOL)isReachable
{
//    DLog(@"relativePath: %@", relativePath);
    //Set the page theme by searching for link tags.
    
    htmlStr = [self disableStylesheetsForContent:htmlStr];
    
    BOOL isMath = [[PxePlayer sharedInstance] getEnableMathML];
    NSString *mathML = (isMath ? @"<script type=\"text/javascript\" src=\"https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML\"></script>" : @"");
    
    //*********** BULDING HEADER WITH SCRIPT FOR LOCAL OR REMOTE ****************
    NSString *script = @"";
    if(isReachable)
    {
        script = [self buildRemoteHeaderWithNavId:navID relativePath:relativePath pageTitle:pageTitle andMathML:mathML];
    } else {
        script = [self buildLocalHeaderWithNavId:navID relativePath:relativePath pageTitle:pageTitle andMathML:mathML];
    }
    //***************************************************************************
    
    NSString* learningContext = [[PxePlayer sharedInstance] getLearningContext];
    if (learningContext && learningContext.length)
    {
        NSString* learningContextScript = [NSString stringWithFormat:@"<script type=\"text/javascript\">window.learningContext = %@; window.getLearningContext = function(){return window.learningContext;}</script>\n", learningContext];
        script = [script stringByAppendingString:learningContextScript];
    }
    
    // 07/15/2015 - Instructed to use the full content URL
    // 10/16/2015 - According to W3C standards,  we don't need the anchor tag
    // https://www.w3.org/wiki/HTML/Elements/base
    // href = valid URL potentially surrounded by spaces href = valid URL potentially surrounded by spaces
    // ex.: <base href="http://www.example.com/news/index.html">
    NSString *headBaseURL = [self removeAnchorFromURLString:[self getPageAbsoluteURL]];
    NSString *urlString;
    if ([[self delegate] scalePageToFit])
    {
         urlString = [NSString stringWithFormat:@"<head>\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, minimum-scale=0.5, maximum-scale=1.5, user-scalable=1\">\n<base href=\"%@\"/>%@", headBaseURL, script];
    } else {
        urlString = [NSString stringWithFormat:@"<head>\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0\">\n<base href=\"%@\"/>%@", headBaseURL, script];
    }
    
    NSRange headRange = [htmlStr rangeOfString:@"<head>"];
    if (headRange.location == NSNotFound)
    {
        // <head> tag not required in HTML5
        htmlStr = [htmlStr stringByAppendingString: urlString];
    } else {
        NSString *injectedString = [@"<head>" stringByAppendingString:urlString];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<head>" withString:injectedString];
    }
    // Remove any doble <head><head>
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<head><head>" withString:@"<head>"];
    
    return htmlStr;
}

- (NSString*) disableStylesheetsForContent:(NSString*)pageHtml
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:LINK_THEME_REGEX
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        DLog(@"Unable to create regex for disabling stylesheets");
        return pageHtml;
    }
    
    NSString *currentTheme = [self.delegate getPageTheme];
    NSString *modifiedPage = [NSString stringWithString:pageHtml];
    
    NSArray *matches = [regex matchesInString:pageHtml options:0 range:NSMakeRange(0, [pageHtml length])];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSString *currentMatch = [pageHtml substringWithRange:matchRange];
        
        modifiedPage = [self disableStylesheetLink:currentMatch forCurrentTheme:currentTheme page:modifiedPage];
    }
    
    return modifiedPage;
}

- (NSString*) disableStylesheetLink:(NSString*)stylesheetLink forCurrentTheme:(NSString*)currentTheme page:(NSString*)modifiedPage
{
    if ([currentTheme isEqualToString:DEFAULT_THEME] || [currentTheme isEqualToString:DEFAULT_THEME_2])
    {
        //disable sepia, night
        if ([stylesheetLink rangeOfString:[NSString stringWithFormat:@"title=\"%@\"",SEPIA_THEME]].location != NSNotFound ||
            [stylesheetLink rangeOfString:[NSString stringWithFormat:@"title=\"%@\"",NIGHT_THEME]].location != NSNotFound)
        {
            modifiedPage = [self disableStylesheetLink:stylesheetLink onPage:modifiedPage];
        }
    }
    else if ([currentTheme isEqualToString:SEPIA_THEME])
    {
        //disable default, day, night
        if ([stylesheetLink rangeOfString:[NSString stringWithFormat:@"title=\"%@\"",DEFAULT_THEME_2]].location != NSNotFound ||
            [stylesheetLink rangeOfString:[NSString stringWithFormat:@"title=\"%@\"",DEFAULT_THEME]].location != NSNotFound ||
            [stylesheetLink rangeOfString:[NSString stringWithFormat:@"title=\"%@\"",NIGHT_THEME]].location != NSNotFound)
        {
            modifiedPage = [self disableStylesheetLink:stylesheetLink onPage:modifiedPage];
        }
    }
    else if ([currentTheme isEqualToString:NIGHT_THEME])
    {
        //disable default, day, sepia
        if ([stylesheetLink rangeOfString:[NSString stringWithFormat:@"title=\"%@\"",DEFAULT_THEME_2]].location != NSNotFound ||
            [stylesheetLink rangeOfString:[NSString stringWithFormat:@"title=\"%@\"",DEFAULT_THEME]].location != NSNotFound ||
            [stylesheetLink rangeOfString:[NSString stringWithFormat:@"title=\"%@\"",SEPIA_THEME]].location != NSNotFound)
        {
            modifiedPage = [self disableStylesheetLink:stylesheetLink onPage:modifiedPage];
        }
    }
    
    return modifiedPage;
}

- (NSString*) disableStylesheetLink:(NSString*) stylesheetLink onPage:(NSString*)modifiedPage
{
    NSString *disabledMatch = [stylesheetLink stringByReplacingOccurrencesOfString:@"/>"
                                                                        withString:[NSString stringWithFormat:@"%@/>", DISABLED]];
    
    return [modifiedPage stringByReplacingOccurrencesOfString:stylesheetLink withString:disabledMatch];
}

- (NSString*) buildLocalHeaderWithNavId:(NSString*)navID
                           relativePath:(NSString*)relativePath
                              pageTitle:(NSString*)pageTitle
                              andMathML:(NSString *) mathML
{
    PxePlayerDataInterface *dataInterface = [self.delegate getCurrentDataInterface];
    NSString* localPath = [[dataInterface getBaseURL] stringByDeletingLastPathComponent];
//    DLog(@"localPath: %@", localPath);
//    DLog(@"relativePath: %@", relativePath);
    NSString* jsReaderURL = [NSString stringWithFormat:@"%@/%@/", localPath, READER_SDK_PATH];
//    DLog(@"jsReaderURL: %@", jsReaderURL);
//    DLog(@"Support PrintPage Jump: %@", [self.delegate appSupportsPrintPages]? @"true": @"false");
    NSString *script =  [NSString stringWithFormat:@"\n<style type=\"text/css\">body{font-size: %lupx;}</style>"
                         "<link href=\"%@css/common.css\" rel=\"stylesheet\" />\n"
                         "<script type=\"text/javascript\" src=\"%@js/jquery-2.1.0.min.js\"></script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/jquery-ui-1.10.3.js\"></script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/bootstrap.js\"></script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/bootstrap-modal.js\"></script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/pxereader.js\"></script>\n"
                         "<script type=\"text/javascript\">var $pxe =jQuery.noConflict(true);</script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/pxe.min.js\"></script>\n"
                         "<script type=\"text/javascript\">$pxe(document).ready(function(){"
                         "   pxereader.setOfflineMode(%@);"
                         "   window.pxeContext = window.pxeContext || {};"
                         "   window.pxeContext.enablePrintPage=%@;"
                         "   addAnnotationSupport(\"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", %@, \"%@\")});</script>\n"
                         ,(unsigned long)[self.delegate getPageFontSize],
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         // setOfflineMode - BEGIN
                         ([Reachability isReachable]?@"false":@"true"),
                         // setOfflineMode - BEGIN
                         // printPageJumpSupport - BEGIN
                         ([self.delegate appSupportsPrintPages]? @"true": @"false"),
                         // addAnnotationSupport - BEGIN
                         [[PxePlayer sharedInstance] getIdentityID],
                         [[PxePlayer sharedInstance] getContextID],
                         navID,
                         [[PxePlayer sharedInstance] formatRelativePathForJavascript:relativePath],
                         ([[PxePlayer sharedInstance] getAnnotationsSharable]? @"true": @"false"),
                         [NSString stringWithFormat:@"%@/%@", PATH_OF_DOCUMENT, READER_SDK_PATH],
                         [self getAnnotationLabelForPageWithPath:relativePath],
                         [[PxePlayer sharedInstance] getOnlineBaseURL]
                         // addAnnotationSupport - END
                         ];
    
    return  script;
}

-(NSString*)buildRemoteHeaderWithNavId:(NSString*)navID
                          relativePath:(NSString*)relativePath
                             pageTitle:(NSString*)pageTitle
                             andMathML:(NSString *) mathML
{
//    DLog(@"relativePath: %@", relativePath);
    NSString *pxeServicesURL = [[PxePlayer sharedInstance] getPxeServicesEndpoint];
    NSString* jsReaderURL = [NSString stringWithFormat:@"%@%@/dest/", pxeServicesURL, READER_SDK_PATH];
//    DLog(@"Support PrintPage Jump: %@", [self.delegate appSupportsPrintPages]? @"true": @"false");
    NSString *script =  [NSString stringWithFormat:@"\n<style type=\"text/css\">body{font-size: %lupx;}</style>"
                         "<link href=\"%@css/common.css\" rel=\"stylesheet\" />\n"
                         "<script type=\"text/javascript\" src=\"%@js/jquery-2.1.0.min.js\"></script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/jquery-ui-1.10.3.js\"></script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/bootstrap.js\"></script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/bootstrap-modal.js\"></script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/pxereader.js\"></script>\n"
                         "<script type=\"text/javascript\">var $pxe =jQuery.noConflict(true);</script>\n"
                         "<script type=\"text/javascript\" src=\"%@js/pxe.min.js\"></script>\n"
                         "<script type=\"text/javascript\">$pxe(document).ready(function(){"
                         "   pxereader.setOfflineMode(false);"
                         "   window.pxeContext = window.pxeContext || {};"
                         "   window.pxeContext.enablePrintPage=%@;"
                         "   addAnnotationSupport(\"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", %@, \"%@\")"
                         "});</script>\n"
                         ,(unsigned long)[self.delegate getPageFontSize],
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         jsReaderURL,
                         // printPageJumpSupport - BEGIN
                         ([self.delegate appSupportsPrintPages]? @"true": @"false"),
                         // addAnnotationSupport - BEGIN
                         [[PxePlayer sharedInstance] getIdentityID],
                         [[PxePlayer sharedInstance] getContextID],
                         navID,
                         [[PxePlayer sharedInstance] formatRelativePathForJavascript:relativePath],
                         ([[PxePlayer sharedInstance] getAnnotationsSharable]? @"true": @"false"),
                         [NSString stringWithFormat:@"%@services-api/api", pxeServicesURL],
                         [self getAnnotationLabelForPageWithPath:relativePath],
                         [[PxePlayer sharedInstance] getOnlineBaseURL]
                         // addAnnotationSupport - END
                         ];
    return  script;
}

- (NSString*)getAnnotationLabelForPageWithPath:(NSString*)relativePath
{
    NSString *annotationLabel;
    
    PxePlayerLabelProvider *labelProvider = [self.delegate getLabelProvider];
    if (labelProvider)
    {
        NSString *label = [labelProvider getLabelForPageWithPath:relativePath];
        if (label)
        {
//            DLog(@"GOT THE LABEL: %@", label);
            annotationLabel = label;
        } else {
            annotationLabel = [self defaultLabelForPageWithPath:relativePath];
        }
    } else {
//        DLog(@"Getting DEfault Label Provider");
        annotationLabel = [self defaultLabelForPageWithPath:relativePath];
    }
    
    return annotationLabel;
}

- (NSString *) defaultLabelForPageWithPath:(NSString*)relativePath
{
    NSString *defaultLabel;
    
    NSDictionary *pageDetails = [[PxePlayer sharedInstance] getPageDetails:@"pageURL" containingValue:relativePath];
    
    if (pageDetails)
    {
        NSString *pageTitle = [pageDetails objectForKey:@"pageTitle"];
        defaultLabel = [NSString stringWithFormat:@"\"%@\"", pageTitle];
    }
//    DLog(@"DefaultLabel: %@", defaultLabel);
    if (!defaultLabel || [defaultLabel isEqual:[NSNull null]])
    {
        defaultLabel = @"\"\"";
    }
    return defaultLabel;
}

-(void)annotateState
{
    // void this error
    //"Tried to obtain the web lock from a thread other than the main thread or the web thread. This may be a result of calling to UIKit from a secondary thread. Crashing now..."
    [self performSelectorOnMainThread:@selector(setAnnotationsInWebView) withObject:nil waitUntilDone:YES];
}

- (void) setAnnotationsInWebView
{
    NSString *setEnabled = @"false";
    if ([[PxePlayer sharedInstance] getAnnotateState])
    {
        setEnabled = @"true";
    }
    
    NSString *jsString = [NSString stringWithFormat:@"pxereader.setEnableAnnotation(%@)", setEnabled];
    //TODO: Temporarily forcing to true
//    NSString *jsString = [NSString stringWithFormat:@"pxereader.setEnableAnnotation(%@)", @"true"];
//    DLog(@"jsString: %@", jsString);
    [self.pageContent stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark - Public methods

/**
 This method getting called whenever load or refresh the page and restored the page information to the local cache
 @see UIWebView
 @see HMCache
 */
-(void)loadPage
{
    if(!self.page)return;
    
    if([self isPageDidLoad])
    {
        self.isPageLoaded = NO;
    }
    //TODO: Why does a method about loading a page affect whether the view appeared or not?
    if(self.viewDidAppeared)
    {
        self.viewDidAppeared = NO;
    }
    //else not cached
    if([self.page rangeOfString:@"quiz"].location != NSNotFound)
    {
        //TODO: this should really have something in the page that tells it not to cache the text in a string

        //get the data from somewhere else
        NSString *apiURL = [self getPageAbsoluteURL];
        //go to server and get it.
        [PxePlayerRestConnector responseDataWithURLAsync:apiURL withCompletionHandler:^(id receivedObj, NSError *error)
         {
             //if not cached populate PxePlayerPage with cached data
             PxePlayerPage *pageDetails = [[PxePlayerPage alloc] init];
             if(!error)
             {
                 //for off line this needs to be unencrypted
                 if(![Reachability isReachable])
                 {
                     NSError *readError;
//                     DLog(@"CALLING READPAGE: %@", [self getPageAbsoluteURL]);
                     NSData *pageData = [[PxePlayerDownloadManager sharedInstance] readPage:[self getPageAbsoluteURL]
                                                                              dataInterface:[self.delegate getCurrentDataInterface]
                                                                                      error:&readError];
                     if(!pageData || readError)
                     {
                         NSLog(@"ERROR: %@",readError);
                     } else {
                         pageDetails.contentFile = [[NSString alloc] initWithData:pageData encoding:NSUTF8StringEncoding];
                     }
                 }
                 else
                 {
                     pageDetails.contentFile = [[NSString alloc] initWithData:receivedObj encoding:NSUTF8StringEncoding];
//                     DLog(@"contentFile: %@", pageDetails.contentFile);
                 }
             }
             [self finalizeLoadPage:pageDetails withRelativePath:[self getPageRelativeURL]];
         }];
    }
    else
    {
        //if cached populate PxePlayerPage with cached data
        PxePlayerPage *pageDetails;
        if(![Reachability isReachable])
        {
            //assume its offline here and just get the data from the local file
            NSError *readError;
            //this can't use extra stuff at the end of a url like #data-uuid-498e293e642447c0b79d42d9cba61cb7
            NSURL *fullRootURL = [NSURL URLWithString:[self getPageAbsoluteURL]];
            NSString *rootURL = [fullRootURL path];
//            DLog(@"CALLING READPAGE: %@", rootURL);
            NSData *pageData = [[PxePlayerDownloadManager sharedInstance] readPage:rootURL
                                                                     dataInterface:[self.delegate getCurrentDataInterface]
                                                                             error:&readError];
            
            if(!pageData || readError)
            {
                NSLog(@"ERROR: %@", readError);
            }
            pageDetails = [[PxePlayerPage alloc] init];
            pageDetails.contentFile = [[NSString alloc] initWithData:pageData encoding:NSUTF8StringEncoding];
//            DLog(@"contentFile: %@", pageDetails.contentFile);
        }
        else
        {
//            DLog(@"self.page: %@", self.page);
            if ([self.page rangeOfString:@"file:/"].location != NSNotFound)
            {
                //Local File from resources (added for Backlinking HTML tests)
                NSError *readError;
                NSURL *fullRootURL = [NSURL URLWithString:self.page];
                NSString *localHTML = [NSString stringWithContentsOfURL:fullRootURL encoding:NSUTF8StringEncoding error:&readError];
                if(!localHTML || readError)
                {
                    DLog(@"ERROR: %@", readError);
                }
                else
                {
//                    DLog(@"localHTML: %@", localHTML);
                }
                pageDetails = [[PxePlayerPage alloc] init];
                pageDetails.contentFile = localHTML;
            } else {
                NSData *data = (NSData*)[HMCache objectForKey:[self.page md5]];
                if(data)
                {
                    pageDetails = (PxePlayerPage*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
                } else {
                    NSLog(@"NO DATA PRINT: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                }
            }
        }
        
        [self finalizeLoadPage:pageDetails withRelativePath:[self getPageRelativeURL]];
    }
    self.isOffline = ![Reachability isReachable];
//    DLog(@"isReachable: %@", [Reachability isReachable]?@"YES":@"NO");
//    DLog(@"isOffline: %@", self.isOffline?@"YES":@"NO");
    [self performSelectorOnMainThread:@selector(setJavascriptOfflineMode) withObject:nil waitUntilDone:YES];
    [self annotateState];
}
/**
 called from loadPage as the final step as one condition is async and one is not.
 */
- (void) finalizeLoadPage:(PxePlayerPage *)pageDetails withRelativePath:(NSString*)relativePath
{
//    DLog(@"relativePath: %@", relativePath);
    if([[self delegate] respondsToSelector:@selector(pageContentLoading:)])
    {
        [[self delegate] pageContentLoading:self.page];
        pageDetails.title = [[self delegate] getCurrentPageTitle];
        pageDetails.pageId = [[self delegate] getCurrentPageId];
    }
    
    if ([pageDetails.contentFile length] > 0)
    {
        [self.pageContent loadHTMLString:[self injectHTML:pageDetails.contentFile
                                                withNavId:pageDetails.pageId
                                             relativePath:relativePath
                                                pageTitle:pageDetails.title
                                              isReachable:[Reachability isReachable]]
                                 baseURL:[NSURL URLWithString:[self getPageAbsoluteURL]]];
//        DLog(@"getPageAbsoluteURL: %@", [self getPageAbsoluteURL]);
        
    }
    self.viewDidAppeared = YES;
    [self performSelectorOnMainThread:@selector(updateFontAndTheme) withObject:nil waitUntilDone:YES];
}

- (void) updateFontAndTheme
{
    DLog(@"called this");
    [self updateFont];
    [self updateTheme];
}

/**
 This method getting called whenever page needs to navigate to the specific titles in the page
 @param NSString, urlTag is an id to navigate to the title with in the page
 @see UIWebView
 */

-(void)gotoURLTag:(NSString*)urlTag
{
    // TODO: Seems to cause the page to load twice
    self.pageUUID = urlTag;
    if(self.pageUUID)
    {
        BOOL forOnline = NO;
        if([Reachability isReachable])
        {
            forOnline = YES;
        }
        NSString *fullURL = [[PxePlayer sharedInstance] prependBaseURL:[NSString stringWithFormat:@"%@#%@",self.page,self.pageUUID] forOnline:forOnline];
//        DLog(@"fullURL: %@", fullURL);
        [self.pageContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"location.href = '%@'",fullURL]];
    }
}

/**
 This method getting called to set the page id of the loaded page
 @param pageId, pageId need to be set
 */
-(void)setPageId:(NSString *)pageId
{
    self.pageUUID  = pageId;
}

/**
 This method getting called to retrieve the page absolute URL.
 MUST NOT HAVE SLASH AT END
 @see [PxePlayer getNCXURL]
 @return NSString, returns the page's absolute URL
 */
-(NSString*)getPageAbsoluteURL
{
    NSString *absoluteURL;
    if([Reachability isReachable])
    {
        absoluteURL = [[PxePlayer sharedInstance] prependBaseURL:self.page forOnline:YES];
    }
    else
    {
        PxePlayerDataInterface *dataInterface = [self.delegate getCurrentDataInterface];
        absoluteURL = [NSString stringWithFormat:@"%@%@", dataInterface.getBaseURL, self.page];
    }
    
//    DLog(@"absoluteURL: %@", absoluteURL);
    return absoluteURL;
}

/**
 This method getting called to retrieve the page relative URL
 @return NSString, returns the page's relative URL
 */
-(NSString*)getPageRelativeURL
{
    return [[PxePlayer sharedInstance] removeBaseUrlFromUrl: self.page];
}

/**
 Experimenting for best way to fill in href of <base> tag
 */
- (NSString*) getHeadBaseURLFromAbsoluteURL
{
    NSString *baseURLStr = [self removeAnchorFromURLString:[self getPageAbsoluteURL]];
    NSURL *absoluteURL = [[NSURL URLWithString:baseURLStr] URLByDeletingLastPathComponent];
    baseURLStr = [absoluteURL absoluteString];
    // removing the slash at the end of the base href results in missing images and styles
    // GOOD: <base href="https://content.stg-openclass.com/eps/pearson-reader/api/item/d8c65f1c-12e6-4ede-91e4-8bc2a12b74f0/1/file/donatelleATH14-062415/OPS/s9ml/front_matter/"/>
    // BAD: <base href="https://content.stg-openclass.com/eps/pearson-reader/api/item/d8c65f1c-12e6-4ede-91e4-8bc2a12b74f0/1/file/donatelleATH14-062415/OPS/s9ml/front_matter"/>
    //    if ([baseURLStr hasSuffix:@"/"])
    //    {
    //        return [baseURLStr substringToIndex:baseURLStr.length-(baseURLStr.length>0)];
    //    }
    return baseURLStr;
}

- (NSString*) removeAnchorFromURLString:(NSString*)url
{
    return  [[url componentsSeparatedByString:@"#"] objectAtIndex:0];
}

/**
 This method getting called to retrieve the page UUID
 @return NSString, returns the page's id
 */
-(NSString*)getPageUUID
{
    return self.page;
}

/**
 This method getting called to retrieve whether page has loaded or not
 @return BOOL, returns the whether page has loaded or not
 */
-(BOOL)isPageDidLoad
{
    return self.isPageLoaded;
}

#pragma mark - Self methods

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id) initWithPage:(NSString*)page
          withFrame:(CGRect)frame
        andDelegate:(id)delegate
{
    self = [super init];
    if(self)
    {
        self.page = page;
        self.delegate = delegate;
        self.contentFrame = frame;
    }
    
    return self;
}

-(void)loadView
{
//    DLog(@"loadView GOT CALLED scalePageToFit: %@", (BOOL)[[self delegate] scalePageToFit]?@"YES":@"NO");
    //set the current view
    [self setView:[[UIView alloc]initWithFrame:self.contentFrame]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect frame = self.view.bounds;    
    
    self.pageContent = [[PxePlayerPagesWebView alloc] initWithFrame:frame
                                                 withScalePageToFit:(BOOL)[[self delegate] scalePageToFit]];
    [self.view addSubview:self.pageContent];
    self.pageContent.delegate = self;
    self.pageContent.scrollView.delegate = self;
    [self.pageContent.scrollView setShowsVerticalScrollIndicator:YES];
    [self.pageContent.scrollView setShowsHorizontalScrollIndicator:NO];
}

- (void) viewDidLoad
{
    DLog(@"ViewDidLoad fired");
    [super viewDidLoad];
    [NSURLProtocol registerClass:[PxeURLProtocol class]];
    
    self.viewDidAppeared = NO;
    self.isPageLoaded = NO;
    
    /**** refresh page Impl ***/
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(handleRefresh:)forControlEvents:UIControlEventValueChanged];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor clearColor] forKey:NSBackgroundColorAttributeName]; //background color :optional
    [attributes setObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Reloading Page" attributes:attributes];
    
    refreshControl.attributedTitle = title;
    [refreshControl setTintColor:[UIColor darkGrayColor]];
    
    [self.pageContent.scrollView addSubview:refreshControl]; //<- this is point to use. Add "scrollView" property.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // Pan Gesture Recognizer
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
//    
//    // view is your UIViewController's view that contains your UIWebView as a subview
//    [self.view addGestureRecognizer:pan];
//    
//    pan.delegate = self;
    
    //load the page content
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.pageContent addGestureRecognizer:longPressRecognizer];
    longPressRecognizer.delegate = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.pageContent addGestureRecognizer:singleTap];
    
    [self loadPage];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    DLog(@"self.pageContent.scrollView.minimumZoomScale: %f", self.pageContent.scrollView.minimumZoomScale);
//    [self.pageContent.scrollView setZoomScale:self.pageContent.scrollView.minimumZoomScale animated:NO];
    
    if([[self delegate] respondsToSelector:@selector(pageContentLoading:)])
    {
        [[self delegate] pageContentLoading:self.page];
    }
    
    if(self.isPageLoaded)
    {
        [self pageDidLoad];
        
        [[PxePlayer sharedInstance] dispatchGAIScreenEventForPage:self.page];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //restrict the horizondal scrolling
    [self.pageContent.scrollView setContentSize:CGSizeMake(self.pageContent.frame.size.width, self.pageContent.scrollView.contentSize.height)];

    //calling load page again to avoid any exceptional case for page loading interrupted in global queue , loadpage has iteself written condtion for page loading or already loaded .
    if( (!self.isPageLoaded) )
    {
        [self loadPage];
    }
    
    self.viewDidAppeared = YES;
    
    DLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!self.viewDidAppeared = YES for page: %@", self.page);
    //Work around for iOS 9.0 bug - PXEPL-6637; still doesn't work on the very first view,
    //but first view should be a cover, so we're good
    [[self.pageContent.scrollView.subviews firstObject]  becomeFirstResponder];
    
    DLog(@"Posting PXEPLAYER_PAGE_SETUP_COMPLETE notification...");
    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_SETUP_COMPLETE object:nil userInfo:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [self stopPageContentActivity];
    
    self.highlights = @[];
    
    if (self.pageContent)
    {
        [self.pageContent removeOrientationChangeObserver];
    }
    
    [super viewWillDisappear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    //get back to original minimum zoom scale
    [self.pageContent.scrollView setZoomScale:self.pageContent.scrollView.minimumZoomScale animated:NO];

    self.viewDidAppeared = NO;
//    DLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~self.viewDidAppeared = NO");
    [super viewDidDisappear:animated];
}

-(void)viewDidUnload
{
    if([self.pageContent isLoading])
    {
        [self.pageContent stopLoading];
    }
    
    [super viewDidUnload];
}

-(void)dealloc
{
//    DLog(@"page content view controller deallocated...%@",self.page);
    self.pageContent.delegate               = nil;
    self.pageContent.scrollView.delegate    = nil;
    
    self.page                               = nil;
    self.pageContent                        = nil;
    
    self.moreInfoPopover.delegate           = nil;
    self.moreInfoPopover                    = nil;
}

- (void)didReceiveMemoryWarning
{    
    [super didReceiveMemoryWarning];
//    [sel ];
}


#pragma mark - UIWebview delegate methods
-(void)handleRefresh:(UIRefreshControl *)refresh
{
    [self.delegate refreshPageWithUrl:[self getPageAbsoluteURL]];
    
    if ([Reachability isReachable])
    {
        [[PxePlayer sharedInstance] refreshAnnotationsOnDeviceWithCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error) {
            if(!error)
            {
                [[PxePlayer sharedInstance] refreshBookmarksOnDeviceWithCompletionHandler:nil];
            }
        }];
        
//        Not refreshing glossary data
//        [[PxePlayer sharedInstance] refreshGlossaryOnDeviceWithCompletionHandler:nil];
    }
    [refresh endRefreshing];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSMutableURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    /***********************************/
    NSString *requestURLString = [request.URL absoluteString];
    [request setAllHTTPHeaderFields:[PXEPlayerCookieManager getRequestHeaders]];
    DLog(@"requestURLString: %@", requestURLString);
    
    // If it's a pxeframe scheme used for getting messages from WEB JS, then just
    if ([requestURLString rangeOfString:@"pxe-frame://"].location != NSNotFound)
    {
        return [self shouldLoadPxeFrameWithRequestURLString:requestURLString];
    }
    else
    {
        NSString *pageURLString = [self getPageAbsoluteURL];
        DLog(@"Absolute pageURLString: %@", pageURLString);
        // Is the page in the current book (do the mainpaths match?)
        NSString *mainRequestPath = [requestURLString stringByDeletingLastPathComponent];
        // Offline issue
        if ([mainRequestPath rangeOfString:@"file:"].location != NSNotFound)
        {
            mainRequestPath = [mainRequestPath stringByReplacingOccurrencesOfString:@"file:" withString:@""];
        }
        NSString *mainPagePath = [pageURLString stringByDeletingLastPathComponent];
        
        DLog(@"mainRequestPath: %@", mainRequestPath);
        DLog(@"mainPagePath: %@", mainPagePath);
        
        if ([mainRequestPath isEqualToString:mainPagePath])
        {
            DLog(@"mainRequestPath isEqualToString:mainPagePath");
            if([requestURLString rangeOfString:[pageURLString lastPathComponent]].location != NSNotFound)
            {
                // The last path component of the pageURL is in the request URL
                // This is a carry over from old Pearson code.
                return YES;
            }
            else if ([self.delegate isValidPage:requestURLString])
            {
                // The page requested is in the TOC or Playlist
                PxePlayerPageViewController *pxePVC = (PxePlayerPageViewController*)self.delegate;
                [pxePVC gotoPageWithPageURL:requestURLString error:nil];
                return YES;
            }
            else
            {
                // Call to load in browser added because footnotes like the following need to open in internal browser pop up:
                // https://revel-stg.pearson.com/eps/sanvan/api/item/2c2bd9a1-50de-4094-895e-6fc08efe977d/1/file/ciccarelli-pae-3e_v10/OPS/xhtml/bkm05_sec_10.xhtml#P700049490800000000000000000754C
                [self loadBrowserWithLink:requestURLString forType:@"unknown" asLightbox:NO];
                return NO;
            }
        }
        else // Request Page not in current book
        {
            DLog(@"mainRequestPath isNOTEqualToString:mainPagePath");
            if ([requestURLString hasPrefix:@"about:"])
            {
                return NO;
            }
            else if([requestURLString rangeOfString:@"_embed.true"].location != NSNotFound  ||
                    [requestURLString rangeOfString:@"embed=true"].location != NSNotFound   ||
                    [mainRequestPath rangeOfString:@"widgets"].location != NSNotFound)
            {
                // This is an embedded video
                DLog(@"EMBEDDED VIDEO");
                return YES;
            }
            else if ([self isRequestedHostRecognized:mainRequestPath])
            {
                DLog(@"RequestedHostRecognized");
                // This request is for a host that is in the URL Whitelist
                // Therefore, the web view should load it.
                return YES;
            }
            else if ([self isRequestedHostExternal:mainRequestPath])
            {
                DLog(@"THIS IS AN EXTERNAL LINK: %@", mainRequestPath);
                // This request is for a host that is in the URL Whitelist
                // Therefore, the web view should load it.
                [[PxePlayer sharedInstance] loadUrlInSafari:request.URL];
                return NO;
            }
            else if (self.isPageLoaded)
            {
                // Only send items to internal browser if page is loaded and displayed
                DLog(@"LOAD IN INTERNAL BROWSER");
                [self loadBrowserWithLink:requestURLString forType:@"unknown" asLightbox:NO];
                return NO;
            }
            else if (self.viewDidAppeared)
            {
                DLog(@"isPageLoaded: %@", self.isPageLoaded?@"YES":@"NO");
                DLog(@"viewDidAppeared: %@", self.viewDidAppeared?@"YES":@"NO");
                DLog(@"LOAD IN INTERNAL BROWSER");
                [self loadBrowserWithLink:requestURLString forType:@"unknown" asLightbox:NO];
                return NO;
            }
        }
    }
    
    return YES;
}

- (void) showSearchHighlightsOnPage
{
    if (self.highlights && [self.highlights count] > 0)
    {
        [self.pageContent stringByEvaluatingJavaScriptFromString:@"pxereader.clearSearchHighlights()"];
        [self.pageContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"pxereader.doSearchHighlight([\"%@\"]);", [self.highlights componentsJoinedByString:@"\",\""]]];
    }
    
    [self updateFont];
    [self updateTheme];
//    DLog(@"called it from here");
}

- (BOOL) isRequestedHostRecognized:(NSString*)requestURL
{
    NSArray *hostWhitelist = [self.delegate getHostWhiteList];
    DLog(@"requestURL: %@", requestURL);
    for (NSString *host in hostWhitelist)
    {
        DLog(@"HOST: %@", host);
        if ([requestURL rangeOfString:host].location != NSNotFound)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) isRequestedHostExternal:(NSString*)requestURL
{
    NSArray *hostExternallist = [self.delegate getHostExternalList];
    
    for (NSString *host in hostExternallist)
    {
        if ([requestURL rangeOfString:host].location != NSNotFound)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) shouldLoadPxeFrameWithRequestURLString:(NSString*)requestURL
{
    DLog(@"PXEFRAME!!!");
    NSString* event = [requestURL stringByReplacingOccurrencesOfString:@"pxe-frame://" withString:@""];
    NSArray *eventValues = [event componentsSeparatedByString:@"#"];
    DLog(@"eventValues: %@", eventValues);
    if([eventValues count])
    {
        NSString *eventName = eventValues[0];
        NSString *eventMessage = @"";
        if([eventValues count] > 1)
        {
            eventMessage = eventValues[1];
        }
        
        DLog(@"### Notification Event Name: %@", eventName);
        DLog(@"### Notification Event Message: %@", eventMessage);
        eventMessage = [eventMessage urlDecodeUsingEncoding];
        
        if([eventName isEqualToString:PXEPLAYER_GADGET_EVENT])
        {
            NSData *data = [eventMessage dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *gadgetDict = [self convertGadgetDataToDictionary:data];
            
            if (! [gadgetDict objectForKey:@"error"])
            {
                if ([gadgetDict objectForKey:@"contentUrl"])
                {
                    [self loadBrowserWithDictionary:gadgetDict asLightbox:YES];
                }
                [[PxePlayer sharedInstance] dispatchGAIEventWithCategory:@"pxe-frame"
                                                                  action:[gadgetDict objectForKey:@"type"]
                                                                   label:[gadgetDict objectForKey:@"contentUrl"]
                                                                   value:nil];
            }
            else
            {
                DLog(@"ERROR badly formatted Gadget JSON");
            }
        }
        else if([eventName isEqualToString:@"onAnnotationData"])
        {
            //decode the URL
            NSString *decodedEventMessage = [eventMessage stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            DLog(@"onAnnotationData decodedEventMessage: %@", decodedEventMessage);
            [self.pageContent respondToAnnotationDataWithMessage:decodedEventMessage event:eventName];
            
        }
        else if([eventName isEqualToString:@"onAnnotationAdd"])
        {
            NSString *decodedEventMessage = [eventMessage stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            DLog(@"decodedEventMessage: %@", decodedEventMessage);
            
            [self.pageContent updateNote:decodedEventMessage];
            
            [self respondToAnnotationEventMessage:decodedEventMessage action:@"add"];
        }
        else if([eventName isEqualToString:@"onAnnotationUpdate"])
        {
            NSString *decodedEventMessage = [eventMessage stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            DLog(@"decodedEventMessage: %@", decodedEventMessage);
            [self.pageContent updateNote:decodedEventMessage];
            [self respondToAnnotationEventMessage:decodedEventMessage action:@"update"];
        }
        else if([eventName isEqualToString:@"onAnnotationRemove"])
        {
            NSString *decodedEventMessage = [eventMessage stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            DLog(@"decodedEventMessage: %@", decodedEventMessage);
            [self.pageContent updateNote:decodedEventMessage];
            [self respondToAnnotationEventMessage:decodedEventMessage action:@"delete"];
        }
        else if([eventName isEqualToString:@"onGlossaryData"])
        {
            DLog(@"got a onGlossaryData Event");
            NSDictionary *glossaryDict = [self displayMoreInfo:eventMessage];
            if (glossaryDict)
            {
                [[PxePlayer sharedInstance]  dispatchGAIEventWithCategory:@"pxe-frame"
                                                                   action:[glossaryDict objectForKey:@"type"]
                                                                    label:[glossaryDict objectForKey:@"method"]
                                                                    value:nil];
            }
        }
        else if([eventName isEqualToString:@"onWidgetEvent"] || [eventName isEqualToString:@"onWidgetEvents"])
        {
            NSDictionary *widgetDict = [self sendWidgetNotification: eventMessage];
            if(widgetDict)
            {
                [[PxePlayer sharedInstance]  dispatchGAIEventWithCategory:@"pxe-frame"
                                                                   action:[widgetDict objectForKey:@"type"]
                                                                    label:[widgetDict objectForKey:@"method"]
                                                                    value:nil];
            }
        }
        else if([eventName isEqualToString:@"onPageClick"])
        {
            DLog(@"Let's close any opened menues...");
            if (self.pageContent)
            {
                [self.pageContent disableUserSelection];
            }
            NSDictionary *pageClickDict = [self sendPageClickNotification: eventMessage];
            if(pageClickDict)
            {
                [[PxePlayer sharedInstance]  dispatchGAIEventWithCategory:@"pxe-frame"
                                                                   action:[pageClickDict objectForKey:@"type"]
                                                                    label:[pageClickDict objectForKey:@"page"]
                                                                    value:nil];
            }
        }
        else if([eventName isEqualToString:@"onNotebookPrompt"])
        {
            NSDictionary *notebookDict = [self sendNotebookNotification: eventMessage];
            if(notebookDict)
            {
                [[PxePlayer sharedInstance]  dispatchGAIEventWithCategory:@"pxe-frame"
                                                                   action:[notebookDict objectForKey:@"type"]
                                                                    label:[notebookDict objectForKey:@"page"]
                                                                    value:[notebookDict objectForKey:@"triggeredPromptIndex"]];
            }
        }
        else if ([eventName isEqualToString:@"retrieve"])
        {
            NSString *decodedEventMessage = [eventMessage stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            [self respondToRetrieveEventMessage:decodedEventMessage];
        }
        else if ([eventName isEqualToString:@"persist"])
        {
            NSString *decodedEventMessage = [eventMessage stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            [self respondToPersistEventMessage:decodedEventMessage];
        }
        else if([eventName isEqualToString:@"onAnnotationLoad"])
        {
            [self updateFont];
            [self updateTheme];
//            DLog(@"called it from here");
            [self annotateState];
        }
        else
        {
            eventMessage = [eventMessage urlDecodeUsingEncoding];
            [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:@{@"Event":eventMessage}];
        }
        if ([eventName isEqualToString:@"oniPadPopover"])
        {
            [self createiPadPopoverForEvent:eventMessage];
        }
        if ([eventName isEqualToString:@"oniPadPopoverClose"])
        {
            DLog(@"Closing pop over in VC");
            [[self.modalPopOverVC presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        }
        
    }
    
    return NO;
}

- (BOOL) respondToOnGadgetEvent:(NSString*)eventMessage
{
    eventMessage = [eventMessage urlDecodeUsingEncoding];
    NSData *data = [eventMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *gadgetDict = [self convertGadgetDataToDictionary:data];
    
    if (! [gadgetDict objectForKey:@"error"])
    {
        if ([gadgetDict objectForKey:@"contentUrl"])
        {
            [self loadBrowserWithDictionary:gadgetDict asLightbox:YES];
        }
    }
    else
    {
        DLog(@"ERROR badly formatted Gadget JSON");
    }
    
    return NO;
}


- (void) respondToAnnotationEventMessage:(NSString *)message action:(NSString*)action
{
//    message = [message urlDecodeUsingEncoding];
    DLog(@"annotationMessage: %@", message);
    DLog(@"annotationAction: %@", action);
    NSError *jsonError;
    
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingMutableContainers
                                                 error:&jsonError];
//    DLog(@"jsonDict: %@", jsonDict);
    if (jsonError)
    {
        //TODO: Respond to badly formatted JSON string
    } else {
        if ([action isEqualToString:@"delete"])
        {
            NSDictionary *result = [jsonDict objectForKey:@"result"];
            
            if([[result objectForKey:@"status" ] isEqualToString:@"success"])
            {
                NSError *deleteError;
                [[PxePlayer sharedInstance] deleteAnnotationOnDeviceWithResult:result withError:&deleteError];
            }
            else
            {
                //TODO: Do something when deletion didn't work rather than refreshing data
            }
        }
        else if ([action isEqualToString:@"add"] || [action isEqualToString:@"update"])
        {
            NSArray *annotationAR = [jsonDict objectForKey:@"annotations"];
            NSDictionary *annotationDict = [annotationAR objectAtIndex:0];
            
            PxePlayerAnnotation *annotation = [[PxePlayerAnnotation alloc] initWithDictionary:annotationDict];
            PxePlayerAnnotations *annotations = [PxePlayerAnnotations new];
            [annotations setAnnotation:annotation forURI:[jsonDict objectForKey:@"uri"]];
            
            DLog(@"Text selection - for web view: %@", annotation.selectedText);
            if (self.pageContent) { //TODO: need to determine if this is the right place for this
                self.pageContent.currentAnnotation = annotation;
            }
            
            NSError *annotationsUpdateError;
            PxePlayerDataInterface *dataInterface = [self.delegate getCurrentDataInterface];
            [[PxePlayer sharedInstance] updateAnnotationsOnDevice:annotations
                                                     forContextId:dataInterface.contextId
                                                        withError:&annotationsUpdateError];
            if (annotationsUpdateError)
            {
                //TODO: Handle Error
            }
        }
    }
}

- (void) respondToRetrieveEventMessage:(NSString*)message
{
    DLog(@"RetrieveEvent: %@", message);
    message = [message urlDecodeUsingEncoding];
    // Parse it into a dictionary
    NSError *jsonError;
    NSData *objectData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *messageDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                                options:0
                                                                  error:&jsonError];
    DLog(@"messageDict: %@", messageDict);
    if (jsonError)
    {
        DLog(@"ERROR pasrsing retrieve event message");
        [self.pageContent stringByEvaluatingJavaScriptFromString:@"pxereader.onOfflineFailureCallBack()"];
    }
    else
    {
        NSDictionary *data = messageDict[@"data"];
        NSString *method = data[@"method"];
        NSString *offlineType = data[@"offlineType"];
        NSString *requestId = messageDict[@"requestId"];
        
        if ([method isEqualToString:@"GET"] && [offlineType isEqualToString:@"annotations"])
        {
            [[PxePlayer sharedInstance] getAnnotationsForPage:self.page
                                        withCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error)
             {
                 DLog(@"completionHandler");
                 if(!error)
                 {
                     NSString *jsonString = [annotationsTypes asJSONString];
                     //                     NSString *jsonString = [annotationsTypes asSerializedJSONString];
                     DLog(@"ANNOTATIONS JSON STRING: %@", jsonString);
                     //DLog(@"ANNOTATIONS SERIALIZED JSON STRING: %@", [annotationsTypes asSerializedJSONString]);
                     NSString *jsCall = [NSString stringWithFormat:@"pxereader.onOfflineSuccessCallBack(%@, %@);", requestId, jsonString];
                     [self.pageContent stringByEvaluatingJavaScriptFromString:jsCall];
                 }
                 else
                 {
                     //TODO: Handle error
                 }
             }];
        }
    }
}

- (void) respondToPersistEventMessage:(NSString*)message
{
    
}

- (void) createiPadPopoverForEvent:(NSString*)eventMessage
{
    DLog(@"Opening pop over for iPad with message: %@", eventMessage);
    
    self.modalPopOverVC = [[UIViewController alloc] init];
    self.modalPopOverVC.view.frame = IPAD_RECT;
    self.modalPopOverVC.preferredContentSize = IPAD_SIZE;
    self.modalPopOverVC.modalPresentationStyle = UIModalPresentationPopover;
    
    self.pageContent.noteView = [[PxePlayerNoteView alloc] initWithParentFrame:self.modalPopOverVC.view.frame
                                                               isAnnotationNew:self.pageContent.isAnnotationNew
                                                             annotationMessage:eventMessage
                                                             webViewRequestUri:self.pageContent.request.URL.absoluteString];
    
    self.pageContent.noteView.delegate = self.pageContent;
    [self.modalPopOverVC.view addSubview:self.pageContent.noteView];
    
    [self presentViewController:self.modalPopOverVC animated:YES completion:nil];
    
    self.presentationController = [self.modalPopOverVC popoverPresentationController];
    self.presentationController.delegate = self;
    [self.presentationController setPermittedArrowDirections:0]; //no arrow anchor
    self.presentationController.sourceView = self.view;
    self.presentationController.sourceRect = CENTER_OF_VIEW;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    DLog(@"Closing the popover");
    self.pageContent.isNoteViewOpen = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    DLog(@"\n\nWEBVIEW STARTING TO LOAD....\n");
    [self showSearchHighlightsOnPage];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading)
    {
        DLog(@"Webview still loading other stuff");
    } else {
        //finished
        DLog(@"Webview finished loading");
#ifdef DEBUG
        [[PxePlayer sharedInstance] markLoadTime:@"FINISHED - LOADING Page View"];
        [[PxePlayer sharedInstance] markLoadComplete];
#endif
    }
    //reset the content size of the webview
//    [webView.scrollView setZoomScale:webView.scrollView.minimumZoomScale animated:YES];
    [webView.scrollView setContentSize:CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
//    DLog(@"webView width: %f", webView.frame.size.width);
//    DLog(@"webView.scrollView width: %f", webView.scrollView.contentSize.width);
    //disable default contextual menu
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    
    if (self.isPageLoaded)
    {
        return;
    }
    self.isPageLoaded = YES;
    
    [self showSearchHighlightsOnPage];
    
    [self pageDidLoad];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"PAGE FAILED TO LOAD");
    //reset the content size of the webview
    [webView.scrollView setZoomScale:webView.scrollView.minimumZoomScale animated:YES];
    [webView.scrollView setContentSize:CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];

    if([[self delegate] respondsToSelector:@selector(pageLoadFailed:)])
    {
        [[self delegate] pageLoadFailed:self.page];
    }
}

/**
 This method getting called to highlight the searched words in the page
 @return NSString, returns the page's id
 */
-(void)highlightSearchWords:(NSArray*)highlightLabels
{
    self.highlights = highlightLabels;
    DLog(@"self.highlights: %@", self.highlights);
}

/**
 This method getting called to update the font size of the page content
 @see [UIWebView stringByEvaluatingJavaScriptFromString];
 @see [PxePlayer getPageFontSize]
 */
- (void) updateFont
{
    NSInteger fontSize = [self.delegate getPageFontSize];
    DLog(@"fontSize: %lu", (unsigned long)fontSize);
    if (fontSize)
    {
        [self.pageContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"pxereader.setFontSize(%lu)", (unsigned long)fontSize]];
    }
}

/**
 This method getting called to update the theme of the page content
 @see [UIWebView stringByEvaluatingJavaScriptFromString];
 @see [PxePlayerPageViewController getPageTheme]
 */
- (void) updateTheme
{
    NSString *theme = [self.delegate getPageTheme];
    DLog(@"THEME: %@", theme);
    if (theme)
    {
        [self.pageContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"pxereader.setTheme(\"%@\")", theme]];
    }
}

/**
 This method getting called to set the annotated label in the page
 @param NSString, label is an annotatated string that need to be highlighted 
 @see [UIWebView stringByEvaluatingJavaScriptFromString];
 */
- (void) setAnnotationLabel:(NSString*)label
{
//    DLog(@"Setting the annotation label: %@", label);
    [self.pageContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Annotate.instance.setPageLabel(\"%@\");", label]];
}


#pragma mark Glossary/More Info Native Pop Up

- (NSDictionary*) displayMoreInfo:(NSString*)jsonString
{
//    DLog(@"jsonString: %@", jsonString);
    jsonString = [jsonString urlDecodeUsingEncoding];
    // Parse Json String
    NSData *moreInfoData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:moreInfoData options:0 error:&error];
    DLog(@"jsonDict: %@", jsonDict);
//    DLog(@"error: %@", error);
    
    if(error)
    {
        NSError *error = [PxePlayerError errorForCode:PxePlayerJSONParseError];
        [[NSNotificationCenter defaultCenter] postNotificationName:PXE_UIError object:moreInfoData userInfo:@{@"error":error}];
    }
    else
    {
        //TODO:  Add call to protocol delegate's optional method and if doesn't respond, display PXE version of MoreInfoPopUp
        // Dispaly More Info as pop over
//        NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],@"PxeReaderResources.bundle"];
//        DLog(@"bundlePath: %@", bundlePath);
        
//        PXEPlayerMoreInfoViewController *moreInfoViewController = [[PXEPlayerMoreInfoViewController alloc] initWithNibName:@"PXEPlayerMoreInfoViewController"
//                                                                                                                    bundle:[NSBundle bundleWithPath:bundlePath]];
        
        NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:kDataBundleName ofType:@"bundle"]];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PxeReaderStoryboard" bundle:resourceBundle];
        
        PXEPlayerMoreInfoViewController *moreInfoViewController = (PXEPlayerMoreInfoViewController *)[sb instantiateViewControllerWithIdentifier:@"MoreInfo"];
        moreInfoViewController.jsonDict = jsonDict;
        
        if(self.moreInfoPopover)
        {
            self.moreInfoPopover.delegate = nil;
            self.moreInfoPopover = nil;
        }
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            moreInfoViewController.delegate = self;
            
            self.moreInfoPopover = [[UIPopoverController alloc] initWithContentViewController:moreInfoViewController];
            self.moreInfoPopover.popoverContentSize = CGSizeMake(moreInfoViewController.view.frame.size.width, moreInfoViewController.view.frame.size.height);
            self.moreInfoPopover.delegate = self;
            
            CGRect centeredFrame = [self centerFrameRect:moreInfoViewController.view.frame.size];
            
            [self.moreInfoPopover presentPopoverFromRect:centeredFrame
                                                  inView:self.view
                                permittedArrowDirections:0
                                                animated:YES];
        }
        else
        {
            [self.delegate displayMoreInfoVC:moreInfoViewController];
        }
    }
    return jsonDict;
}

- (CGRect) centerFrameRect:(CGSize)viewFrameSize
{
    float xPos = self.view.frame.origin.x + (self.view.frame.size.width - viewFrameSize.width)/2;
    float yPos = self.view.frame.origin.y + (self.view.frame.size.height - viewFrameSize.height)/2;
    
    return CGRectMake(xPos, yPos, viewFrameSize.width, viewFrameSize.height);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(self.moreInfoPopover)
    {
        if([self.moreInfoPopover isPopoverVisible])
        {
            [self.moreInfoPopover dismissPopoverAnimated:NO];
            
            [self.moreInfoPopover presentPopoverFromRect:[self centerFrameRect:self.moreInfoPopover.popoverContentSize]
                                                  inView:self.view
                                permittedArrowDirections:0
                                                animated:YES];
        }
    }
    
    if (self.modalPopOverVC) {
        //[[self.modalPopOverVC presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        self.presentationController.sourceRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0.0f, 0.0f);
    }
}

- (void) loadBrowserWithLink:(NSString*)urlString forType:(NSString*)type asLightbox:(BOOL)lightbox
{
//    DLog(@"loadBrowserWithLink: %@ asLightbox: %@", urlString, lightbox?@"YES":@"NO");
    if(self.moreInfoPopover)
    {
        [self.moreInfoPopover dismissPopoverAnimated:NO];
    }
    
    if([[self delegate] respondsToSelector:@selector(loadBrowserWithURL:forType:asLightbox:)])
    {
        [[self delegate] loadBrowserWithURL:urlString forType:type asLightbox:lightbox];
        
        [[PxePlayer sharedInstance] dispatchGAIEventWithCategory:@"internalBrowser"
                                                          action:type
                                                           label:urlString
                                                           value:nil];
    }
}

- (void) loadBrowserWithDictionary:(NSDictionary*)dict asLightbox:(BOOL)lightbox
{
//    DLog(@"loadBrowserWithDictionary: %@ asLightbox: %@", dict, lightbox?@"YES":@"NO");
    if(self.moreInfoPopover)
    {
        [self.moreInfoPopover dismissPopoverAnimated:NO];
    }
    
    if([[self delegate] respondsToSelector:@selector(loadBrowserWithDictionary:asLightbox:)])
    {
        [[self delegate] loadBrowserWithDictionary:dict asLightbox:lightbox];
        
        
    }
}

- (NSDictionary*) sendWidgetNotification:(NSString*)eventMessage
{
    NSMutableDictionary *widgetMessage = [NSMutableDictionary new];
    if(eventMessage)
    {
        eventMessage = [eventMessage urlDecodeUsingEncoding];
        NSError *error;
        NSData *data = [eventMessage dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&error];
        [widgetMessage addEntriesFromDictionary:eventDict];
        [widgetMessage setObject:self.page forKey:@"page"];
//        DLog(@"widgetMessage: %@", widgetMessage);
        [[NSNotificationCenter defaultCenter] postNotificationName:PXE_WidgetEvent object:nil userInfo:widgetMessage];
    }
    return widgetMessage;
}

- (NSDictionary*) sendPageClickNotification:(NSString*)eventMessage
{
    NSMutableDictionary *pageClickMessage = [NSMutableDictionary new];
    if(eventMessage)
    {
        eventMessage = [eventMessage urlDecodeUsingEncoding];
        NSError *error;
        NSData *data = [eventMessage dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&error];
        
        [pageClickMessage addEntriesFromDictionary:eventDict];
        [pageClickMessage setObject:self.page forKey:@"page"];
        DLog(@"pageClickMessage: %@", pageClickMessage);
        [[NSNotificationCenter defaultCenter] postNotificationName:PXE_PageClickEvent object:nil userInfo:pageClickMessage];
    }
    return pageClickMessage;
}

- (NSDictionary*) sendNotebookNotification:(NSString*)eventMessage
{
    NSMutableDictionary *notebookMessage = [NSMutableDictionary new];
    if(eventMessage)
    {
        eventMessage = [eventMessage urlDecodeUsingEncoding];
        NSError *error;
        NSData *data = [eventMessage dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&error];
        
        [notebookMessage addEntriesFromDictionary:eventDict];
        [notebookMessage setObject:self.page forKey:@"page"];
        DLog(@"notebookMessage: %@", notebookMessage);
        [[NSNotificationCenter defaultCenter] postNotificationName:PXE_NotebookEvent object:nil userInfo:notebookMessage];
    }
    return notebookMessage;
}

# pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PXE_ContentStartedScrolling object:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PXE_ContentStoppedScrolling object:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PXE_ContentStoppedScrolling object:nil];
}

- (void)scrollViewDidScroll: (UIScrollView*)scrollView
{
    // Horizontal Scrolling
//    DLog(@"scrollView: %@", scrollView);
//    DLog(@"document.width: %f", [self.pageContent stringByEvaluatingJavaScriptFromString:@"document.width"]);
    if (scrollView.contentOffset.x != 0)
    {
//        DLog(@"Content Offset != 0 BEFORE: %f", scrollView.contentOffset.x);
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
    }
    
    // Vertical Scrolliing
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    NSMutableDictionary *contentScroll = [NSMutableDictionary new];
    if (scrollOffset == 0)
    {
        [contentScroll setObject:PXEPLAYER_TOP forKey:PXEPLAYER_POSITION];
    }
    else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
    {
        [contentScroll setObject:PXEPLAYER_BOTTOM forKey:PXEPLAYER_POSITION];
    }
    
    //determine direction of scroll
    if (_lastContentOffset > scrollView.contentOffset.y){
        [contentScroll setObject:PXEPLAYER_DIRECTION_DOWN forKey:PXEPLAYER_DIRECTION];
    }
    else if (_lastContentOffset < scrollView.contentOffset.y){
        [contentScroll setObject:PXEPLAYER_DIRECTION_UP forKey:PXEPLAYER_DIRECTION];
    }
    // Sending this because eTextK-12 hasn't changed yet
    [[NSNotificationCenter defaultCenter] postNotificationName:PXE_ContentStoppedScrolling object:self userInfo:contentScroll];
    [[NSNotificationCenter defaultCenter] postNotificationName:PXE_ContentScrolling object:self userInfo:contentScroll];
    
    _lastContentOffset = scrollView.contentOffset.y;
}

# pragma mark UIScrollViewDelegate - END

- (void) setJavascriptOfflineMode
{
    NSString *offlineMode = @"false";
    if( self.isOffline)
    {
        offlineMode = @"true";
    }
//    DLog(@"offlineMode: %@", offlineMode);
    [self.pageContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"pxereader.setOfflineMode(%@)", offlineMode]];
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case NotReachable:
        {
//            DLog(@"The internet is down.");
            self.isOffline = YES;
            [self performSelectorOnMainThread:@selector(setJavascriptOfflineMode) withObject:nil waitUntilDone:YES];
            
            break;
        }
        case ReachableViaWiFi:
        {
//            DLog(@"The internet is working via WIFI.");
            self.isOffline = NO;
            [self performSelectorOnMainThread:@selector(setJavascriptOfflineMode) withObject:nil waitUntilDone:YES];
            
            break;
        }
        case ReachableViaWWAN:
        {
//            DLog(@"The internet is working via WWAN.");
            self.isOffline = NO;
            [self performSelectorOnMainThread:@selector(setJavascriptOfflineMode) withObject:nil waitUntilDone:YES];
            
            break;
        }
    }
}

- (void) clearPageContent
{
    
}

- (void) stopPageContentActivity
{
//    DLog(@"stopPageContentActivity GOT CALLED");
    [self.pageContent stopLoading];
    
    [self.pageContent stringByEvaluatingJavaScriptFromString:@"pxereader.clearSearchHighlights()"];
    [self.pageContent stringByEvaluatingJavaScriptFromString:@"pxereader.stopWidgets()"];
    
    [self.pageContent loadHTMLString: @"" baseURL: nil];
    
    self.pageContent = nil;
    self.pageContent.delegate = nil;
}

- (void) handleEnteredBackground:(NSNotification*)notification
{
    [self.pageContent stringByEvaluatingJavaScriptFromString:@"pxereader.clearSearchHighlights()"];
    [self.pageContent stringByEvaluatingJavaScriptFromString:@"pxereader.stopWidgets()"];
}

- (void) updateBacklinkMapping:(PxePlayerPageViewBacklinkMapping*) backlinkMapping
{
    if (backlinkMapping && self.viewDidAppeared)
    {
        NSString *csvMappings = [NSString stringWithFormat:@"window.pxeContext.backlinkCSVMappings = %@", backlinkMapping.backlinkCSVMappings];
        [self.pageContent stringByEvaluatingJavaScriptFromString:csvMappings];
        
        NSString *launchParams = [NSString stringWithFormat:@"window.pxeContext.backlinkLaunchParams = %@", backlinkMapping.backlinkLaunchParams];
        [self.pageContent stringByEvaluatingJavaScriptFromString:launchParams];
        
        NSString *endpointMapping = [NSString stringWithFormat:@"window.pxeContext.backlinkEndpointMapping = %@", backlinkMapping.backlinkEndpointMapping];
        [self.pageContent stringByEvaluatingJavaScriptFromString:endpointMapping];
        
        NSString *signatureEndpoint = [NSString stringWithFormat:@"window.pxeContext.backlinkSignatureEndpoint = \"%@\"", backlinkMapping.backlinkSignatureEndpoint];
        [self.pageContent stringByEvaluatingJavaScriptFromString:signatureEndpoint];
    } else {
        //TODO: Return a real error
        if (!backlinkMapping)
        {
            DLog(@"ERROR: backlinkMapping object is nil");
        }
        if (!self.viewDidAppeared)
        {
            DLog(@"ERROR: trying to set javascript backlink mapping before view is ready");
        }
    }
}

- (void) scrollToAnchor:(NSString*)anchor
{
    NSString *scrollCommand = [NSString stringWithFormat:@"document.getElementById('%@').scrollIntoView(true);", anchor];
    DLog(@"scrollCommand: %@", scrollCommand);
    [self.pageContent stringByEvaluatingJavaScriptFromString:scrollCommand];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        DLog(@"Long press state began...");
        
        [self.pageContent.menuControllerManager setUpBaseMenuItems];
#ifdef DEBUG
        CGPoint lpLocation = [gestureRecognizer locationInView:self.pageContent];
        DLog(@"Long press location is at x:%f y:%f", lpLocation.x, lpLocation.y);
#endif  
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}

- (void) willHideMenu:(NSNotification*)notification
{
    //self.pageContent.baseMenuPosition = [UIMenuController sharedMenuController].menuFrame;
    DLog(@"Base menu will close - it is at x: %f and y: %f", self.pageContent.baseMenuPosition.origin.x, self.pageContent.baseMenuPosition.origin.y);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    
}

- (void) singleTap:(UITapGestureRecognizer*)gesture
{
    CGPoint touchLocation = [gesture locationInView:self.pageContent];
    
    DLog(@"Single tap occurred at x:%f y:%f", touchLocation.x, touchLocation.y);
    if (self.pageContent)
    {
        self.pageContent.baseMenuPosition = CGRectMake(touchLocation.x, touchLocation.y, 0.0f, 0.0f);
    }
}

- (NSDictionary *) convertGadgetDataToDictionary:(NSData*)data
{
    NSMutableDictionary *gadgetDict = [NSMutableDictionary new];
    [gadgetDict setObject:@"gadget" forKey:@"fileType"];
    // Convert data to json object
    NSError *gadgetError;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&gadgetError];
//    DLog(@"gadget JSON: %@", json);
    
    if(gadgetError)
    {
        [gadgetDict setObject:gadgetError forKey:@"error"];
        return gadgetDict;
    }
    // Get gadget type
    NSString *gadgetType = [json objectForKey:PXE_MEDIA_TYPE];
    if (gadgetType)
    {
        [gadgetDict setObject:gadgetType forKey:PXE_MEDIA_TYPE];
    }
    // Get Gadget URL
    NSString *gadgetURL = [json objectForKey:PXE_MEDIA_URL_PATH];
    if (gadgetURL)
    {
        // Offline issue
        if ([gadgetURL rangeOfString:@"file://"].location != NSNotFound)
        {
            gadgetURL = [gadgetURL stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        }
        [gadgetDict setObject:gadgetURL forKey:PXE_MEDIA_URL_PATH];
    }
    // Get Gadget Caption
    NSString *gadgetCaption = [json objectForKey:PXE_MEDIA_CAPTION];
    if (gadgetCaption)
    {
        //remove a leading and closing hard returns
        gadgetCaption = [gadgetCaption stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [gadgetDict setObject:gadgetCaption forKey:PXE_MEDIA_CAPTION];
    }
    // Get Gadget Title
    NSString *gadgetTitle = [json objectForKey:PXE_MEDIA_TITLE];
    if (gadgetTitle)
    {
        //remove a leading and closing hard returns
        [gadgetDict setObject:gadgetTitle forKey:PXE_MEDIA_TITLE];
    }
    
    return gadgetDict;
}

@end
