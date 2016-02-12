//
//  PxePlayerEnvironmentContext.h
//  PxeReader
//
//  Created by Tomack, Barry on 4/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PxePlayerEnvironmentType)
{
    PxePlayerDevEnv     = 0,
    PxePlayerQAEnv      = 1,
    PxePlayerStagingEnv = 2,
    PxePlayerProdEnv    = 3
};

@interface PxePlayerEnvironmentContext : NSObject

/**
 
 */
- (id) initWithWebAPIEndpoint:(NSString*)apiEndpoint
         searchServerEndpoint:(NSString*)searchEndpoint
          pxeServicesEndpoint:(NSString*)pxeServicesEndpoint
               pxeSDKEndpoint:(NSString*)pxeSDKEndpoint;

/**
 
 */
- (id) initWithWebAPIEndpoint:(NSString*)apiEndpoint
         searchServerEndpoint:(NSString*)searchEndpoint
          pxeServicesEndpoint:(NSString*)pxeServicesEndpoint
               pxeSDKEndpoint:(NSString*)pxeSDKEndpoint
              environmentType:(PxePlayerEnvironmentType)environmentType;


/**
 
 */
- (void) setWebAPIEndpoint:(NSString*)apiEndpoint;

/**
 
 */
- (NSString*) getWebAPIEndpoint;

/**
 
 */
- (void)setSearchServerEndpoint:(NSString*)searchEndpoint;

/**
 
 */
- (NSString*)getSearchServerEndpoint;

/**
 
 */
- (void) setPxeServicesEndpoint:(NSString*)pxeServicesEndpoint;

/**
 
 */
- (NSString*) getPxeServicesEndpoint;

/**
 
 */
- (void) setPxeSDKEndpoint:(NSString*)pxeSDKEndpoint;

/**
 
 */
- (NSString*) getPxeSDKEndpoint;

/**
 
 */
- (void) setPxeEnvironmentType:(PxePlayerEnvironmentType)environmentType;

/**
 
 */
- (PxePlayerEnvironmentType) getPxeEnvironmentType;

/**
 
 */
- (NSString*) getPxeEnvironmentNameForType:(PxePlayerEnvironmentType)environmentType;

/**
 
 */
- (BOOL) verifyForErrors:(NSError**)error;

@end
