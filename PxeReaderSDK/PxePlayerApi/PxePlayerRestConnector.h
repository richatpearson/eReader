//
//  DataManager.h
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PxePlayerDataInterface.h"

typedef void (^CompletionHandler)(id receivedObj, NSError* error);

@interface PxePlayerRestConnector : NSObject


/*!
     @method     responseWithUrl:withParams:error:
     
     @abstract
                 Performs a synchronous load of the given request,
                 returning the formatted json object.
     
     @discussion
                 This method initiates a synchronous request, identifies
                 the error status, and based on error status, it will 
                 parse the json object received into appropriate 
                 Objective C object and returns it.
     
     @param
     api      
                 The api to request. It wont expect the complete URL.
                 Only the last part of the URL is expected here. Inside
                 the method it will prepare the full URL based on the 
                 WEBAPI_URL defined in URLConstants
     
     @param
     params    
                 The input parameters to be sent to POST request
     
     @param
     error       
                 Out parameter (may be NULL) used if an error occurs
                 while processing the request. Will not be modified if the
                 load succeeds.
     
     @result     
                 The formatted json object.
 */

+(id)responseWithUrl:(NSString*)api withParams:(NSDictionary*)params method:(NSString*)method error:(NSError**)error;

/*
     @method     responseWithUrlAsync:withParams:completionHandler:

     @abstract
                 Performs a synchronous load of the given request,
                 returning the formatted json object.

     @discussion
                 This method initiates a synchronous request, identifies
                 the error status, and based on error status, it will
                 parse the json object received into appropriate
                 Objective C object and returns it.

     @param
     api
                 The api to request. It wont expect the complete URL.
                 Only the last part of the URL is expected here. Inside
                 the method it will prepare the full URL based on the
                 WEBAPI_URL defined in URLConstants

     @param
     handler
                 The completion handler block which will be executed
                 when the data is received from the request sent.

     @param
     error
                 Out parameter (may be NULL) used if an error occurs
                 while processing the request. Will not be modified if the
                 load succeeds.

     @result
                 nil
*/
+(void)responseWithUrlAsync:(NSString*)api withParams:(NSDictionary*)params method:(NSString*)method completionHandler:(CompletionHandler)handler;

/*
 @method     responseWithUrlAsync:withParams:completionHandler:
 
 @abstract
 Performs a synchronous load of the given request,
 returning the formatted json object.
 
 @discussion
 This method initiates a synchronous request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 Objective C object and returns it.
 
 @param
 api
 The api to request. It wont expect the complete URL.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 handler
 The completion handler block which will be executed
 when the data is received from the request sent.
 
 @param
 error
 Out parameter (may be NULL) used if an error occurs
 while processing the request. Will not be modified if the
 load succeeds.
 
 @result
 nil
 */
+ (void) responseWithDataInterfaceAsync:(PxePlayerDataInterface*)dataInterface
                  withCompletionHandler:(CompletionHandler)handler;

/*
 @method     responseWithUrlAsync:withParams:completionHandler:
 
 @abstract
 Performs a synchronous load of the given request,
 returning the formatted json object.
 
 @discussion
 This method initiates a synchronous request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 Objective C object and returns it.
 
 @param
 api
 The api to request. It wont expect the complete URL.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 handler
 The completion handler block which will be executed
 when the data is received from the request sent.
 
 @param
 error
 Out parameter (may be NULL) used if an error occurs
 while processing the request. Will not be modified if the
 load succeeds.
 
 @result
 nil
 */
+(void)responseDataWithURLAsync:(NSString*)url withCompletionHandler:(CompletionHandler)handler;

/*
 @method     responseWithUrlAsync:withParams:completionHandler:
 
 @abstract
 Performs a synchronous load of the given request,
 returning the formatted json object.
 
 @discussion
 This method initiates a synchronous request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 Objective C object and returns it.
 
 @param
 api
 The api to request. It wont expect the complete URL.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 handler
 The completion handler block which will be executed
 when the data is received from the request sent.
 
 @param
 error
 Out parameter (may be NULL) used if an error occurs
 while processing the request. Will not be modified if the
 load succeeds.
 
 @result
 nil
 */
+(void)responseWithXMLURLAsync:(NSString*)url withCompletionHandler:(CompletionHandler)handler;

+(void) performNetworkCallWithRequest:(NSURLRequest*)request
                 andCompletionHandler:(CompletionHandler)onComplete;

@end
