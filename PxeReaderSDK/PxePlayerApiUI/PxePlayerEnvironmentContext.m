//
//  PxePlayerEnvironmentContext.m
//  PxeReader
//
//  Created by Tomack, Barry on 4/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayerEnvironmentContext.h"
#import "PxePlayerError.h"
#import "PXEPlayerMacro.h"

@interface PxePlayerEnvironmentContext()

/**
 
 */
@property (nonatomic, assign) PxePlayerEnvironmentType environmentType;

/**
 WebAPI URL 
 //TODO: only used by eText - needs to changes
 */
@property (nonatomic, strong) NSString *webAPIURI;

/**
 Search Server URL
 */
@property (nonatomic, strong) NSString *searchAPIURI;

/**
 PXE Services URL
 */
@property (nonatomic, strong) NSString *pxeServicesURI;

/**
 PXE SDK (javascript) endpoint
 */
@property (nonatomic, strong) NSString *pxeSDKURI;

@end

@implementation PxePlayerEnvironmentContext

- (id) initWithWebAPIEndpoint:(NSString*)apiEndpoint
         searchServerEndpoint:(NSString*)searchEndpoint
          pxeServicesEndpoint:(NSString*)pxeServicesEndpoint
               pxeSDKEndpoint:(NSString*)pxeSDKEndpoint
{
    PxePlayerEnvironmentType envType = [self tryToFigureOutEnvironmentType:pxeServicesEndpoint];
    
    self = [self initWithWebAPIEndpoint:apiEndpoint
                   searchServerEndpoint:searchEndpoint
                    pxeServicesEndpoint:pxeServicesEndpoint
                         pxeSDKEndpoint:pxeSDKEndpoint
                        environmentType:envType];
    return self;
}

- (id) initWithWebAPIEndpoint:(NSString*)apiEndpoint
         searchServerEndpoint:(NSString*)searchEndpoint
          pxeServicesEndpoint:(NSString*)pxeServicesEndpoint
               pxeSDKEndpoint:(NSString*)pxeSDKEndpoint
              environmentType:(PxePlayerEnvironmentType)environmentType
{
    self = [super init];
    if (self)
    {
        self.webAPIURI = apiEndpoint;
        self.searchAPIURI = searchEndpoint;
        self.pxeServicesURI = pxeServicesEndpoint;
        self.pxeSDKURI = pxeSDKEndpoint;
        self.environmentType = environmentType;
        DLog(@"self.environmentType: %lu", (long)self.environmentType);
    }
    return self;
}

- (PxePlayerEnvironmentType) tryToFigureOutEnvironmentType:(NSString*)pxeEndpoint
{
    PxePlayerEnvironmentType eType = PxePlayerProdEnv;
    
    if ([pxeEndpoint rangeOfString:@"stg"].location != NSNotFound) {
        if ([pxeEndpoint rangeOfString:@"qa"].location != NSNotFound) {
            eType = PxePlayerQAEnv;
        } else {
            eType = PxePlayerStagingEnv;
        }
    }
    else if ([pxeEndpoint rangeOfString:@"dev"].location != NSNotFound) {
        eType = PxePlayerDevEnv;
    }
    
    return eType;
}

- (NSString*) getPxeEnvironmentNameForType:(PxePlayerEnvironmentType)environmentType
{
    NSString *environmentName;
    
    DLog(@"pxeEnvironmentType: %lu", (long)environmentType);
    switch (environmentType) {
        case PxePlayerDevEnv:
            environmentName = @"PxePlayerDevEnv";
            break;
        case PxePlayerQAEnv:
            environmentName = @"PxePlayerQAEnv";
            break;
        case PxePlayerStagingEnv:
            environmentName = @"PxePlayerStagingEnv";
            break;
        case PxePlayerProdEnv:
            environmentName = @"PxePlayerProdEnv";
            break;
        default:
            environmentName = @"PxePlayerQAEnv";
            break;
    }
    
    return environmentName;
}

- (NSString*) description
{
    NSMutableString *dataDesc = [NSMutableString stringWithString:@"PxePlayerEnvironmentContext: \n"];
    [dataDesc appendFormat:@"   WebAPIURL: %@ \n", self.webAPIURI];
    [dataDesc appendFormat:@"   SearchServerURL: %@ \n", self.searchAPIURI];
    [dataDesc appendFormat:@"   PXEServicesURL: %@ \n", self.pxeServicesURI];
    [dataDesc appendFormat:@"   PXESDKURL: %@ \n", self.pxeSDKURI];
    return dataDesc;
}

- (void) setWebAPIEndpoint:(NSString*)apiEndpoint
{
    self.webAPIURI = apiEndpoint;
}

- (NSString*) getWebAPIEndpoint
{
    return self.webAPIURI;
}

- (void) setSearchServerEndpoint:(NSString*)searchEndpoint
{
    self.searchAPIURI = searchEndpoint;
}

- (NSString*) getSearchServerEndpoint
{
    return self.searchAPIURI;
}

- (void) setPxeServicesEndpoint:(NSString*)pxeServicesEndpoint
{
    self.pxeServicesURI = pxeServicesEndpoint;
}

- (NSString*) getPxeServicesEndpoint
{
    return self.pxeServicesURI;
}

- (void) setPxeSDKEndpoint:(NSString*)pxeSDKEndpoint
{
    self.pxeSDKURI = pxeSDKEndpoint;
}

- (NSString*) getPxeSDKEndpoint
{
    return self.pxeSDKURI;
}

- (void) setPxeEnvironmentType:(PxePlayerEnvironmentType)environmentType
{
    self.environmentType = environmentType;
}


- (PxePlayerEnvironmentType) getPxeEnvironmentType
{
    return self.environmentType;
}

- (BOOL) verifyForErrors:(NSError**)error
{
    NSMutableArray *errors = [NSMutableArray new];
    BOOL verified = YES;
    if (! self.webAPIURI)
    {
        DLog(@"ERROR: PxePlayerEnvironmentContext: Missing WebAPIEndpoint");
        [errors addObject:@"WebAPIEndpoint"];
    }
    if (! self.searchAPIURI)
    {
        DLog(@"ERROR: PxePlayerEnvironmentContext: Missing SearchServerEndpoint");
        [errors addObject:@"SearchServerEndpoint"];
    }
    if (! self.pxeServicesURI)
    {
        DLog(@"ERROR: PxePlayerEnvironmentContext: Missing PXEServicesEndpoint");
        [errors addObject:@"Missing PXEServicesEndpoint"];
    }
    if (! self.pxeSDKURI)
    {
        DLog(@"ERROR: PxePlayerEnvironmentContext: Missing PXESDKEndpoint");
        [errors addObject:@"PXESDKEndpoint"];
    }
    
    if ([errors count] > 0)
    {
        verified = NO;
        
        NSString *errorStr = [NSString stringWithFormat:NSLocalizedString(@"PxePlayerEnvironment missing data: %@.", @"PxePlayerEnvironment missing data: {errors array}."), errors];
        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:errorStr};
        // added error != NULL condition to satisfy
        // Potential null dereference. According to coding standards in 'Creating and Returning NSError Objects' the parameter 'error' may be null.
        if (error != NULL) *error = [PxePlayerError errorForCode:PxePlayerEnvironmentError errorDetail:errorDict];
    }
    
    return verified;
}

@end
