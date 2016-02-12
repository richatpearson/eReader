//
//  PXEPlayerCookieManager.m
//  SanVanEcourses
//
//  Created by Mason, Darren J on 8/15/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PXEPlayerCookieManager.h"
#import "PxePlayer.h"
#import "PXEPlayerMacro.h"

@implementation PXEPlayerCookieManager

+(NSDictionary*)getRequestHeaders
{    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:[[PxePlayer sharedInstance] getContentAuthTokenName] forKey:NSHTTPCookieName];
    [cookieProperties setObject:[[PxePlayer sharedInstance] getContentAuthToken] forKey:NSHTTPCookieValue];
    [cookieProperties setObject:[[PxePlayer sharedInstance] getCookieDomain] forKey:NSHTTPCookieDomain];
    
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    
    // set expiration to one month from now or any NSDate of your choosing
    // this makes the cookie sessionless and it will persist across web sessions and app launches
    /// if you want the cookie to be destroyed when your app exits, don't set this
    //[cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies: cookies];
    
    return headers;
}
@end
