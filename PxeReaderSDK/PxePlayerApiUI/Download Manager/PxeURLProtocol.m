//
//  POCURLProtocol.m
//
//  Created by Mason, Darren J on 2/10/15.
//  Copyright (c) 2014 Pearson. All rights reserved.
//


#import "PxeURLProtocol.h"
#import "PxePlayer.h"
#import "PxePlayerDownloadManager.h"
#import "PXEPlayerMacro.h"
#import "Reachability.h"

#define EXTERNAL_REQUEST_KEY @"ExternalRequest"

@implementation PxeURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest *)request
{
    NSString* filePath = [[PxePlayer sharedInstance] getBaseURL];
    DLog(@"filePath: %@", filePath);
    DLog(@"REACHABILITY: %@", [Reachability isReachable]?@"YES":@"NO");
    if ([Reachability isReachable])
    {
        BOOL canInit =  (filePath != nil) && !([@"http" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame) && !([@"https" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame);
//        DLog(@"canInit: %@", canInit?@"YES":@"NO");
//        DLog(@"(filePath != nil): %@", (filePath != nil)?@"YES":@"NO")
//        DLog(@"!([@\"http\" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame): %@", !([@"http" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame)?@"YES":@"NO")
//        DLog(@"!([@\"https\" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame): %@", !([@"https" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame)?@"YES":@"NO")
    	return canInit;
    }
    else
    // NOTE: Offline not unit tested - 12/30/15
    {
        if ([request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"http"])
        {
            [NSURLProtocol setProperty:@YES forKey:EXTERNAL_REQUEST_KEY inRequest:(NSMutableURLRequest*)request];
            DLog(@"Now the property for ExternalRequest is %@", [NSURLProtocol propertyForKey:EXTERNAL_REQUEST_KEY inRequest:request]);
        }
        return filePath != nil && ([@"file" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame ||
                                   [@"https" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame ||
                                   [@"http" caseInsensitiveCompare:request.URL.scheme] == NSOrderedSame);
    }
    
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL) requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [[[a URL] resourceSpecifier] isEqualToString:[[b URL] resourceSpecifier]];
}

- (void) sendResponse:(NSData *)data
             mimetype:(NSString *)mimetype
                  url:(NSURL *)url
{
    NSDictionary *headers = @{@"Content-Type" : mimetype, @"Access-Control-Allow-Origin" : @"*", @"Cache-control" : @"no-cache"};
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:headers];

    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void) sendError:(NSInteger)code
{
    DLog(@"CODE: %ld", (long)code);
    NSError* err = [NSError errorWithDomain:@"com.pearson.downloadManager" code:code userInfo:nil];
    [[self client] URLProtocol:self didFailWithError:err];
}

- (void) startLoading
{
    NSString* basePath = [[PxePlayer sharedInstance] getBaseURL];
    DLog(@"basePath: %@", basePath);
    if (basePath == nil && [@"file" caseInsensitiveCompare:self.request.URL.scheme] != NSOrderedSame)
    {
        DLog(@"Will return 404!");
        // EPUB was closed. Return a 404
        [self sendError:404];
    }
    else
    {
        NSString *requestPath = self.request.URL.path;
        DLog(@"requestPath: %@", requestPath);
        if (requestPath.length > basePath.length) // avoid out of bounds error
        {
            if ([[requestPath substringFromIndex:basePath.length] isEqualToString:@"/OPS/xhtml"])
            {
                //only happens when downloaded and on-line
                DLog(@"\n!!!Reqest path is /OPS/xhtml - a DIRECTORY - skip!! \n");
                return;
            }
        }
        
        NSData* data;
        NSString *custMimeType = @"application/octet-stream";
        //ONLY do this if the files are IN the epub
        if([requestPath rangeOfString:[@"/" stringByAppendingPathComponent:READER_SDK_PATH]].location == NSNotFound)
        {
            if (basePath.length < requestPath.length && ![NSURLProtocol propertyForKey:EXTERNAL_REQUEST_KEY inRequest:self.request]) // avoid accidental Index out of bounds error
            {
                NSString *entryPath = [requestPath substringFromIndex:basePath.length];
                NSError *error;
                DLog(@"CALLING READPAGE from PxeURLProtocol: %@", entryPath);
                data = [[PxePlayerDownloadManager sharedInstance] readPage:[basePath stringByAppendingPathComponent:entryPath]
                                                             dataInterface:[[PxePlayer sharedInstance] currentDataInterface]
                                                                     error:&error];
            }
			if ([NSURLProtocol propertyForKey:EXTERNAL_REQUEST_KEY inRequest:self.request])
            {
                DLog(@"Will use placeholder for asset with path: %@", requestPath);
                
                custMimeType = @"text/html";
                
                data = [self prepareDataForPlaceholderForExternalAsset];
            }
        }
        else
        {
            DLog(@"NOT INSIDE EPUB. %@", requestPath);
            data = [[NSFileManager defaultManager] contentsAtPath:requestPath];
        }
        
        if (data == nil)
        {
            [self sendError:404];
        }
        else
        {
            if([requestPath rangeOfString:@".css"].location != NSNotFound)
            {
                custMimeType = @"text/css"; //css
            }
            [self sendResponse:data mimetype:custMimeType url:self.request.URL];
        }
    }
}

- (NSData*) prepareDataForPlaceholderForExternalAsset
{
    NSString *placeholder =
        @"<div id=\"placeholder\" style=\"background-color:#efefef; border:1px solid #999999; text-align:center; width:100%; height:100%\"> \
          <font font-family=\"Helvetica Neue\" font-weight=\"Medium\" size=\"5\" color=\"#b3b3b3\"> \
            <div style=\"display:inline-block; margin-top:5%\"> \
              This content is unavailable when offline or printing \
            </div> \
          </font> \
        </div>";
    
    //TODO: what's missing is controlling the font size dynamically based on the parent's height
    //TODO: the challange is some of these external assets are in iFrames so it was hard to have a JS that could control the font size of the div
    //TODO: once we have a working JS then we can inject it the header
    
    return [placeholder dataUsingEncoding:NSUTF8StringEncoding];
}

-(void)stopLoading {}

@end
