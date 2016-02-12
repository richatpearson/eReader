//
//  DataManager.m
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerRestConnector.h"
#import "Reachability.h"
#import "PxePlayerNCXParser.h"
#import "PxePlayerXHTMLNCXParser.h"
#import "PxePlayerXMLParser.h"
#import "PXEPlayerCookieManager.h"
#import "PxePlayer.h"
#import "PxePlayerError.h"
#import "PXEPlayerMacro.h"
#import "PXEPlayerEnvironment.h"
#import "PxePlayerDownloadManager.h"

@implementation PxePlayerRestConnector

+(NSString*)prepareURL:(NSString*)api
{
    NSString *webAPI = [[PxePlayer sharedInstance] getWebAPIEndpoint];
    return [[webAPI stringByAppendingString:api] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(id)responseWithUrl:(NSString*)api withParams:(NSDictionary*)params method:(NSString*)method error:(NSError**)error
{
    api = [api stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
//    if ([Reachability isReachable])//TODO: this needs to take into account offline content
//    {
        //this is section where network is available ,you can perform your action here which is dependent on network
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
        NSString *actualUrl = ([api rangeOfString:@"http:/"].location == NSNotFound &&
                               [api rangeOfString:@"https:/"].location == NSNotFound) ? [self prepareURL:api]:[api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSError *parseError = nil;
        NSMutableDictionary* paramDict = [params mutableCopy];
        if(params)
        {
            NSString* authToken = paramDict[@"authToken"];
            if(authToken)
            {
                [request setValue:authToken forHTTPHeaderField:@"authToken"];
                [paramDict removeObjectForKey:@"authToken"];
            }
        }
        
        if(([method caseInsensitiveCompare:PXE_Post] == NSOrderedSame) || ([method caseInsensitiveCompare:PXE_Put] == NSOrderedSame))
        {
            if (params)
            {
                //NOTE::here we can check the arrived Dictionary objects is valid for JSON conversion alternate for parseError result
                //TODO :: conversion from model to JSON required
                NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&parseError];
                
//                DLog(@"post data %@",[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
                
                if(parseError)
                {
                    NSDictionary* errorDictionary = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"trying to post wrong JSON format : %@",@"Wrong JSON"),[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]]};
                    *error = [PxePlayerError errorForCode:PxePlayerPostWrongJSON
                                              errorDetail:errorDictionary];
                    return nil;
                }
                
                [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:postData];
            }
        }
        
        [request setHTTPMethod:method];
        
//        DLog(@"Downloading data from URL %@", actualUrl);
        
        NSURL* url = [NSURL URLWithString:actualUrl];
        if(url)
        {
            [request setURL:url];
            
            NSHTTPURLResponse* receivedResponse = nil;
            NSError *responseError = nil;
            request.timeoutInterval = 10;
            NSData* receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&receivedResponse error:&responseError];
            
//            DLog(@"received data %@",[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
//            DLog(@"received status code %d",receivedResponse.statusCode);
            
            if (!responseError)    //all data successfully received without loss
            {
                id response = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&parseError];
                if(parseError)
                {
                    NSDictionary* errorDictionary = @{NSLocalizedDescriptionKey:NSLocalizedString([[NSString alloc] initWithData:receivedData
                                                                                                                        encoding:NSUTF8StringEncoding], @"Parse Error")};
                    *error = [PxePlayerError errorForCode:PxePlayerParseError errorDetail:errorDictionary];
                    
                    return nil;
                }
                else
                {                    
                    //200, 201 , 204 are success response codes
                    if(([receivedResponse statusCode] != 200) && ([receivedResponse statusCode] != 201) && ([receivedResponse statusCode] != 204))
                    {
                        NSDictionary* errorDictionary = nil;
                        //return the error data
                        if(![NSJSONSerialization isValidJSONObject:receivedData])
                        {
                            errorDictionary = @{NSLocalizedDescriptionKey:NSLocalizedString(@"No Results found", @"No Results found")};
                        }
                        else {
                            errorDictionary = @{@"result": response};
                        }
                        
                        *error = [PxePlayerError errorForCode:receivedResponse.statusCode errorDetail:errorDictionary];
                    }
                }
                return response;
            }
//            else
//            {
//                DLog(@"error %@",[responseError localizedDescription]);
//                NSDictionary* errorDictionary = @{NSLocalizedDescriptionKey:NSLocalizedString(@"No Connection\nYou are not connected to the internet. Please check your connection.", @"No Connection") };
//                *error = [NSError errorWithDomain:@"com.nexttext.sdk" code:receivedResponse.statusCode userInfo:errorDictionary];
//            }
//        }
//        else
//        {
//            if (error != NULL) *error = [PxePlayerError errorForCode:PxePlayerMalformedURL
//                                                     localizedString:actualUrl];
//        }
    }
    else
    {
        ///this is section where network in not available,you can show some custom message  here
        if (error != NULL) *error = [PxePlayerError errorForCode:PxePlayerNetworkUnreachable];
        return nil;        
    }
    
    return nil;
}


+(void)responseWithUrlAsync:(NSString*)api withParams:(NSDictionary*)params method:(NSString*)method completionHandler:(CompletionHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* error = nil;
        id response = [self responseWithUrl:api withParams:params method:method error:&error];        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(handler) {
                handler(response, error);
            }
        });
    });
}

+ (void) responseWithDataInterfaceAsync:(PxePlayerDataInterface*)dataInterface
                  withCompletionHandler:(CompletionHandler)handler
{
//    DLog(@"url: %@", dataInterface.tocPath);
//    DLog(@"Reachable: %@", [Reachability isReachable]?@"YES":@"NO");
//    DLog(@"isDownloaded: %@", [[PxePlayer sharedInstance] isDownloaded:dataInterface.contextId]?@"YES":@"NO");
    if(![Reachability isReachable])
    {
        id response;
        NSError *fileError;
        //if this is offline
        NSURL *nsURL = [NSURL URLWithString:dataInterface.tocPath];
        DLog(@"CALLING READPAGE: %@", [nsURL path]);
        NSData* data = [[PxePlayerDownloadManager sharedInstance] readPage:[nsURL path] dataInterface:dataInterface error:&fileError];
        
        if(data)
        {
            if([[[dataInterface.tocPath pathExtension]lowercaseString] isEqualToString:@"ncx"])
            {
                response = [[[PxePlayerNCXParser alloc] init] parseData:data];
            } else {
                response = [[[PxePlayerXHTMLNCXParser alloc] init] parseData:data];
            }
        }
        else
        {
            fileError = [PxePlayerError errorForCode:PxePlayerFileError];
        }
        
        if(handler)
        {
            handler(response, fileError);
        }
        
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLResponse* response;
            NSError* error;
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dataInterface.tocPath]];
            [request setAllHTTPHeaderFields:[PXEPlayerCookieManager getRequestHeaders]];
            
            NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            dispatch_async(dispatch_get_main_queue(), ^
            {
               id response;
               DLog(@"PATH EXTENSION: %@",  [[dataInterface.tocPath pathExtension]lowercaseString]);
               if([[[dataInterface.tocPath pathExtension]lowercaseString] isEqualToString:@"ncx"])
               {
                   response = [[[PxePlayerNCXParser alloc] init] parseData:data];
               } else {
                   response = [[[PxePlayerXHTMLNCXParser alloc] init] parseData:data];
               }
               
               if(handler)
               {
                   handler(response, error);
               }
            });
        });
    }
}

+(void)responseWithXMLURLAsync:(NSString*)url withCompletionHandler:(CompletionHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse* response;
        NSError* error;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setAllHTTPHeaderFields:[PXEPlayerCookieManager getRequestHeaders]];
        
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            id response = [[[PxePlayerXMLParser alloc] init] parseData:data];
            if(handler) {
                handler(response, error);
            }
        });
    });
}

+(void)responseDataWithURLAsync:(NSString*)url withCompletionHandler:(CompletionHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse* response;
        NSError* error;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setAllHTTPHeaderFields:[PXEPlayerCookieManager getRequestHeaders]];
        
        id data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        if(!data){
            //if this is offline
            NSString *newString;
            //remove all # off url
            if([url rangeOfString:@"#"].location > -1)
                newString = [url substringToIndex:[url rangeOfString:@"#"].location];
            else
                newString = url;
            
            data = [NSData dataWithContentsOfFile:newString];
            error = nil;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if(handler) {
                handler(data, error);
            }
        });
    });
}

+(void) performNetworkCallWithRequest:(NSURLRequest*)request
                 andCompletionHandler:(CompletionHandler)onComplete {
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    NSURLSessionDataTask *sessionDataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   [self handleResponse:response withData:data error:error OnComplete:onComplete];
               }];
    
    [sessionDataTask resume];
}

+(void) handleResponse:(NSURLResponse*)response
              withData:(NSData*)data
                 error:(NSError*)error
            OnComplete:(CompletionHandler)onComplete {
    
    NSDictionary *errorDictionary;
    if (error) {
        DLog(@"Networking error: %@", error.description);
        onComplete(nil, error);
    }
    else {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
            NSInteger httpStatusCode = [httpURLResponse statusCode];
            DLog(@"HTTP statusCode is: %ld", (long)httpStatusCode);
            if (httpStatusCode >= 200 && httpStatusCode < 300) { //200-level success
                    onComplete(data, nil);
            }
            else {
                errorDictionary = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Non-200 HTTP status code", @"Non-200 HTTP status code")};
                NSError *error = [PxePlayerError errorForCode:httpStatusCode errorDetail:errorDictionary];
                onComplete(data, error);
            }
        }
        else {
            onComplete(nil, [PxePlayerError errorForCode:PxePlayerNetworkCallFailed]);
        }
    }
}

@end
