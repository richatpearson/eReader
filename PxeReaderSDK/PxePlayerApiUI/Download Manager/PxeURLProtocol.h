//
//  POCURLProtocol.h
//
//  Created by Mason, Darren J on 2/10/15.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayer.h"

/**
 *  This class is a standard URL protocol that allows an offline book to reference internal assets (images, css, js, etc)
 */
@interface PxeURLProtocol : NSURLProtocol

@property (nonatomic,weak) PxePlayer *pxePlayer;

+ (BOOL) canInitWithRequest:(NSURLRequest *)request;
+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request;
+ (BOOL) requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b;
- (void) startLoading;
- (void) stopLoading;

@end
