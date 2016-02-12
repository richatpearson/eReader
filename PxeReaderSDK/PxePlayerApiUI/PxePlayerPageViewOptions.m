//
//  PxePlayerPageViewOptions.m
//  PxeReader
//
//  Created by Tomack, Barry on 10/24/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerPageViewOptions.h"
#import "PxePlayerUIConstants.h"
#import "PXEPlayerMacro.h"

@interface PxePlayerPageViewOptions ()

/**
 Mutable array to hold those known hosts whose content must appear inline (embedded)
 */
@property (nonatomic, strong) NSMutableArray *hostWhitelist;
/**
 Mutable array to hold those known hosts whose content must appear outside of app (launch Safari or other app)
 */
@property (nonatomic, strong) NSMutableArray *hostExternallist;

@end

@implementation PxePlayerPageViewOptions

@synthesize bookTheme = _bookTheme;
@synthesize fontSize = _fontSize;

- (id) init
{
    if (self = [super init])
    {
        self.showAnnotate           = PXEPLAYER_DEFAULT_ANNOTATE;
        self.enableMathML           = PXEPLAYER_DEFAULT_MATHML;
        self.printPageSupport       = PXEPLAYER_DEFAULT_PRINTPAGEJUMPSUPPORT;
        
        [self setDefaultHostWhiteList];
        
        self.hostExternallist = [NSMutableArray new];
        
        self.useDefaultFontAndTheme = YES;
        
        self.transitionStyle = UIPageViewControllerTransitionStylePageCurl;
    }
    return self;
}

- (NSInteger) bookPageFontSize
{
    if (self.useDefaultFontAndTheme && !_fontSize)
    {
        _fontSize = PXEPLAYER_DEFAULT_FONTSIZE;
    }
    DLog(@"_fontSize %ld", (long)_fontSize);
    return _fontSize;
}

- (void) setBookPageFontSize:(NSInteger)size
{
    DLog(@"incoming %lu", (long)size);
    if (size)
    {
        if (size < PXE_MIN_FONT_SIZE)
        {
            size = PXE_MIN_FONT_SIZE;
        }
        if (size > PXE_MAX_FONT_SIZE)
        {
            size = PXE_MAX_FONT_SIZE;
        }
        
        _fontSize = (long)size;
    }
    else
    {
        // Can't pass nil as an Int value in Swift so  can't unit test cover this
        _fontSize = PXEPLAYER_DEFAULT_FONTSIZE;
    }
    DLog(@"BOOKPageFontSize Set: %lu", (long)_fontSize);
}

- (NSString*)bookPageTheme
{
    if (self.useDefaultFontAndTheme && !_bookTheme)
    {
        _bookTheme = PXEPLAYER_DEFAULT_THEME;
    }
    DLog(@"bookTheme %@", _bookTheme);
    return _bookTheme;
}

- (void) setBookPageTheme:(NSString*)theme
{
    if(theme)
    {
        _bookTheme = theme;
    }
    else if (self.useDefaultFontAndTheme)
    {
        _bookTheme = PXEPLAYER_DEFAULT_THEME;
    }
}

#pragma mark URL Host Whitelist BEGIN

- (void) setDefaultHostWhiteList
{
    self.hostWhitelist = [NSMutableArray new];
    //TODO: Remove this line at some point when client apps are using whitelist
    [self.hostWhitelist addObject:@"mediaplayer.pearsoncmg.com"];
    [self.hostWhitelist addObject:@"media.pearsoncmg.com"];
}

- (NSMutableArray*) addHostToWhiteList:(NSString*)host
{
    if(host)
    {
        // Don't want to add a full path
        NSURL *url = [NSURL URLWithString:host];
        if([url host])
        {
            host = [url host];
        }
        
        if (![self.hostWhitelist containsObject:host])
        {
            [self.hostWhitelist addObject:host];
        }
    }
    return self.hostWhitelist;
}

- (NSMutableArray*) addHostArrayToWhiteList:(NSArray*)hostArray
{
    for (NSString *host in hostArray)
    {
        [self addHostToWhiteList:host];
    }
    return self.hostWhitelist;
}

- (NSMutableArray*) hostWhiteList
{
    return self.hostWhitelist;
}

# pragma mark URL Host Externallist BEGIN

- (NSMutableArray*) addHostToExternalList:(NSString*)host
{
    DLog(@"incoming host: %@", host);
    if(host)
    {
        // Just want the host
        NSURL *url = [NSURL URLWithString:host];
        if([url host])
        {
            host = [url host];
        }
        DLog(@"host: %@", host);
        if (![self.hostExternallist containsObject:host])
        {
            [self.hostExternallist addObject:host];
        }
    }
    return self.hostExternallist;
}

- (NSMutableArray*) addHostArrayToExternalList:(NSArray*)hostArray
{
    for (NSString *host in hostArray)
    {
        [self addHostToExternalList:host];
    }
    return self.hostExternallist;
}

- (NSMutableArray*) hostExternalList
{
    return self.hostExternallist;
}

- (NSString*) description
{
    NSMutableString *dataDesc = [NSMutableString stringWithString:@"PxePlayerPageViewOptions: \n"];
    [dataDesc appendFormat:@"   hostWhiteList: %@ \n", self.hostWhitelist];
    [dataDesc appendFormat:@"   hostExternalList: %@ \n", self.hostExternallist];
    [dataDesc appendFormat:@"   showAnnotate: %@ \n", self.showAnnotate?@"YES":@"NO"];
    [dataDesc appendFormat:@"   printPageSupport: %@ \n", self.printPageSupport?@"YES":@"NO"];
    [dataDesc appendFormat:@"   useDefaultFontAndTheme: %@ \n", self.useDefaultFontAndTheme?@"YES":@"NO"];
    [dataDesc appendFormat:@"   disableHorizontalScrolling: %@ \n", self.disableHorizontalScrolling?@"YES":@"NO"];
    [dataDesc appendFormat:@"   scalePage: %@ \n", self.scalePage?@"YES":@"NO"];
    [dataDesc appendFormat:@"   enableMathML: %@ \n", self.enableMathML?@"YES":@"NO"];
    [dataDesc appendFormat:@"   bookTheme: %@ \n", self.bookTheme];
    [dataDesc appendFormat:@"   fontSize: %ld \n", (long)self.fontSize];
    [dataDesc appendFormat:@"   backlinkMapping: %@ \n", self.backlinkMapping];
    
    return dataDesc;
}

@end
