//
//  NTApplication.m
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PxePlayer.h"
#import "PxePlayerBookmarkQuery.h"
#import "HMCache.h"
#import "PxePlayerDataInterface.h"
#import "PxePlayerPageViewController.h"
#import "PxePlayerInterface.h"
#import "PxePlayerBookmarks.h"
#import "PxePlayerSearchNCXQuery.h"
#import "PxePlayerSearchURLsQuery.h"
#import "PxePlayerSearchPages.h"
#import "PxePlayerAddAnnotationQuery.h"
#import "PxePlayerAnnotationsTypes.h"
#import "PxePlayerAnnotation.h"
#import "PxePlayerAnnotations.h"
#import "PxePlayerAnnotationsQuery.h"
#import "PxePlayerDeleteAnnotation.h"
#import "PxePlayerContentAnnotationsQuery.h"
#import "PxePlayerNoteDeleteQuery.h"
#import "PxePlayerMediaQuery.h"
#import "PxePlayerDataManager.h"
#import "PxePlayerUIConstants.h"
#import "PxePageDetail.h"
#import "PxePlayerNCXCDParser.h"
#import "PxePlayerXHTMLCDParser.h"
#import "PxePlayerXHTMLParser.h"
#import "PXEPlayerCookieManager.h"
#import "PxePlayerError.h"
#import "PXEPlayerMacro.h"
#import "PxePlayerMasterPlaylistParser.h"
#import "PxePlayerXHTMLNCXParser.h"
#import "PxePlayerTocQuery.h"
#import "PxePlayerToc.h"
#import "PXEPlayerEnvironment.h"
#import "PxePlayerJSONCustomBasketParser.h"
#import "PxePlayerJSONTOCParser.h"
#import "PxeAnnotation.h"
#import "PxeAnnotations.h"
#import "PxeGlossary.h"
#import "PxeBookMark.h"
#import "PxeContext.h"
#import "Reachability.h"
#import "PxePlayerBookmark.h"
#import "PxePlayerAddBookmark.h"
#import "PxePlayerParser.h"
#import "PxePlayerCheckBookmark.h"
#import "PxePlayerUser.h"
#import "PxePlayerDownloadManager.h"
#import "PxePlayerManifestParser.h"
#import "PxeManifest.h"
#import "PxeManifestChunk.h"
#import "PxePlayerManifestItem.h"
#import "PxePlayerGoogleAnalyticsManager.h"

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]
#define PATH_OF_DOCUMENT [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define GA_PXE_SDK_DEV_TRACKING_ID @"UA-56981405-6"
#define GA_PXE_SDK_QA_TRACKING_ID @"UA-56981405-4"
#define GA_PXE_SDK_STAGING_TRACKING_ID @"UA-56981405-7"
#define GA_PXE_SDK_PROD_TRACKING_ID @"UA-56981405-5"

@implementation UINavigationController (Orientation)

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end


@interface PxePlayer ()

@property (nonatomic, strong) PxePlayerDataInterface *dataInterface;

@property (nonatomic, strong) PxePlayerEnvironmentContext *environmentContext;

@property (nonatomic, strong) PxePlayerUser *currentPxePlayerUser;

#ifdef DEBUG
@property (nonatomic, strong) NSMutableString *loadingLog;
#endif

@property (nonatomic, strong) PxePlayerGoogleAnalyticsManager *googleAnalyticsManager;

@end

@implementation PxePlayer

#pragma mark - Public methods

#ifdef DEBUG
- (void) markLoadTime:(NSString*)timeToMark
{
    if (!self.loadingLog)
    {
        self.loadingLog = [NSMutableString new];
    }
    [self.loadingLog appendFormat:@"%@: %@\n", timeToMark, [NSDate date]];
}

- (void) markLoadComplete
{
    DLog(@"Loading Log: %@\n%@", [self getContextID], self.loadingLog);
    self.loadingLog = [NSMutableString stringWithString:@""];
}
#endif

- (NSString*) getContextID
{
    return self.dataInterface.contextId;
}

- (NSString*) getAssetId
{
    return self.dataInterface.assetId;
}


- (PxePlayerUser *) currentUser
{
    return self.currentPxePlayerUser;
}

- (void) setCurrentUser:(PxePlayerUser *) pxePlayerUser
{
    DLog(@"CurrentUser: %@", pxePlayerUser.identityId);
    self.currentPxePlayerUser = pxePlayerUser;
    [self storePxePlayerUser:self.currentPxePlayerUser];
}

- (NSString*) getIdentityID
{
    return self.currentPxePlayerUser.identityId;
}

-(void)setIndexId:(NSString*)indexId
{
    self.dataInterface.indexId = indexId;
}

- (NSString*) getIndexId
{
    return self.dataInterface.indexId;
}

- (NSString*) getGoogleAnalyticsTrackingIdForKey:(NSString*)key
{
    return [self.googleAnalyticsManager getTrackingIdForKey:key];
}

-(void)setAnnotateState:(BOOL)canAnnotate
{
    self.dataInterface.showAnnotate = canAnnotate;
}

-(BOOL)getAnnotateState
{
    return self.dataInterface.showAnnotate;
}

-(void)setEnableMathML:(BOOL)isMathML
{
    self.dataInterface.enableMathML = isMathML;
}

-(BOOL)getEnableMathML
{
    return self.dataInterface.enableMathML;
}

-(void) setCookieDomain:(NSString*)domain
{
    [self.dataInterface setCookieDomain:domain];
}

-(NSString*)getCookieDomain
{
    if([self.dataInterface cookieDomain])
    {
        return [self.dataInterface cookieDomain];
    }
    return @"";
}

-(NSString*)getTOCURL
{
    NSString *tocPath = self.dataInterface.tocPath;
    DLog(@"tocPath: %@", tocPath);
    // If it's toc.ncx
    if ([tocPath rangeOfString:@"toc.ncx"].location != NSNotFound)
    {
        //if toc doesn't have OPS then it needs it if its offline

        if([[self.dataInterface tocPath] rangeOfString:@"OPS"].location == NSNotFound &&
           [[self getBaseURL] rangeOfString:@"OPS"].location == NSNotFound)
        {
            DLog(@"%@",[[[self getBaseURL] stringByAppendingString:@"OPS"] stringByAppendingString:self.dataInterface.tocPath]);
            return [[[self getBaseURL] stringByAppendingString:@"OPS"] stringByAppendingString:self.dataInterface.tocPath];
        } else {
            // make sure there is NOT a leading slash before the OPS
            // Technically, this should not be here if toc path and base urls and stuff are written to dataInterface correctly
            if ([tocPath hasPrefix:@"/"] && [tocPath length] > 1)
            {
                self.dataInterface.tocPath = [tocPath substringFromIndex:1];
            }
        }
        
        return [[self getBaseURL] stringByAppendingString:self.dataInterface.tocPath];
    }
    
    return tocPath;
}

- (NSString*) getTOCPath
{
    DLog(@"getTOCPath");
    //if toc doesn't have OPS then it needs it if its offline
    if([self.dataInterface.tocPath rangeOfString:@"OPS"].location == NSNotFound && [[self getBaseURL] rangeOfString:@"OPS"].location == NSNotFound)
    {
        DLog(@"%@",[[[self getBaseURL] stringByAppendingString:@"/OPS"] stringByAppendingString:self.dataInterface.tocPath]);
        return [[[self getBaseURL] stringByAppendingString:@"/OPS"] stringByAppendingString:self.dataInterface.tocPath];
    } else {
        // make sure there is a leading slash before the OPS
        NSString *firstCharacter = [self.dataInterface.tocPath substringToIndex:1];
        if (![firstCharacter isEqualToString:@"/"] )
        {
            NSString *tocPath = [NSString stringWithFormat: @"/%@",self.dataInterface.tocPath];
            return [[self getBaseURL] stringByAppendingString:tocPath];
        }
    }
    
    return [[self getBaseURL] stringByAppendingString:self.dataInterface.tocPath];
}

-(void)setContentAuthToken:(NSString*)token
{
    [self.dataInterface setContentAuthToken:token];
}

- (NSString*) getRemoveDuplicatePagesForQueryString
{
    NSString *removeDuplicates = @"false";
    
    if (self.dataInterface.removeDuplicatePages)
    {
        removeDuplicates = @"true";
    }
    
    return removeDuplicates;
}

-(NSString*)getContentAuthToken
{
    if([self.dataInterface contentAuthToken])
    {
        return [self.dataInterface contentAuthToken];
    }
    return @"";
}
-(void)setContentAuthTokenName:(NSString*)tokenName
{
    [self.dataInterface setContentAuthTokenName:tokenName];
}

-(NSString*)getContentAuthTokenName
{
    if([self.dataInterface contentAuthTokenName])
    {
        return [self.dataInterface contentAuthTokenName];
    }
    return @"";
}

-(void) resetAuthToken:(NSString*)newToken
{
    self.currentPxePlayerUser.authToken = newToken;
}

- (void) resetOnlineBaseURL:(NSString*)newOnlineBaseURL
{
    self.dataInterface.onlineBaseURL = newOnlineBaseURL;
}

-(void)setAnnotationsSharable:(BOOL)isSharable
{
    [self.dataInterface setAnnotationsSharable:isSharable];
}

- (BOOL) isDownloaded:(NSString*)assetId
{
//    DLog(@"assetId: %@", assetId);
    BOOL downloaded = [[PxePlayerDownloadManager sharedInstance] checkForDownloadedFileByAssetId:assetId];
//    DLog(@"downloaded: %@", downloaded?@"YES":@"NO");
    return downloaded;
}

- (NSString*) getWebAPIEndpoint
{
    return [self.environmentContext getWebAPIEndpoint];
}

- (NSString*) getSearchServerEndpoint
{
    return [self.environmentContext getSearchServerEndpoint];
}

- (NSString*) getPxeSDKEndpoint
{
    DLog(@"PXESDK: %@", [self.environmentContext getPxeSDKEndpoint]);
    return [self.environmentContext getPxeSDKEndpoint];
}

- (NSString*) getPxeServicesEndpoint
{
    return [self.environmentContext getPxeServicesEndpoint];
}

- (PxePlayerEnvironmentType) getPxeEnvironmentType
{
    return [self.environmentContext getPxeEnvironmentType];
}

- (NSString*) getPxeEnvironmentNameForType:(PxePlayerEnvironmentType)environmentType
{
    return [self.environmentContext getPxeEnvironmentNameForType:environmentType];
}

- (BOOL) getAnnotationsSharable
{
    if([self.dataInterface annotationsSharable])
    {
        return [self.dataInterface annotationsSharable];
    }
    return NO;
}

- (PxePlayerDataInterface *) currentDataInterface
{
    return self.dataInterface;
}

- (NSString*) getLearningContext
{
    return [self.dataInterface learningContext];
}

- (void) resetLearningContext:(NSString*)learningContext
{
    self.dataInterface.learningContext = learningContext;
}

- (void) loadUrlInSafari:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

-(BOOL) webFileExists:(NSString*)url
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:5.0];
    [request setAllHTTPHeaderFields:[PXEPlayerCookieManager getRequestHeaders]];
    
    NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ([response statusCode] == 404)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL) updatePxeEnvironment:(PxePlayerEnvironmentContext *)environment error:(NSError**)error
{
    BOOL success = [environment verifyForErrors:error];
    if(success)
    {
        self.environmentContext = environment;
    } else {
        DLog(@"ERROR UPDATING PXE ENVIRONEMNT: %@", *error);
    }
    return success;
}

- (void) updateDataInterface:(PxePlayerDataInterface *)interface
                    finished:(isSuccess)success
{
    DLog(@"INCOMING DATA INTERFACE: %@", interface);
    if ([interface verified])
    {
        if (interface.tocPath || interface.masterPlaylist)
        {
            [self storeDataInterface:interface];
            [self setUpGoogleAnalytics];
            
            if (interface.masterPlaylist)
            {
                [self retrievePlaylistFromDataInterface:(PxePlayerDataInterface*)interface
                                           whenFinished:(isSuccess)success];
            }
            else
            {
                [self retrieveTOCFromDataInterface:interface whenFinished:success];
            }
        }
        else
        {
            success(NO);
        }
    }
    else
    {
        DLog(@"Error: missing required data in PxePlayerDataInterface");
        success(NO);
    }
}

- (void) updateDataInterface:(PxePlayerDataInterface *)interface
                  onComplete:(void (^)(BOOL success, NSError *error))handler
{
    DLog(@"INCOMING DATA INTERFACE: %@", interface);
    NSError *updateError;
    [interface verifyWithError:&updateError];
    
    if (updateError)
    {
        if(handler)
        {
            handler(NO, updateError);
        }
    }
    else
    {
        [self storeDataInterface:interface];
        [self setUpGoogleAnalytics];
        // Dispatch an UpdateDataInterface Event
        [self.googleAnalyticsManager dispatchGAIEventWithCategory:[self.dataInterface getClientAppName]
                                                           action:@"updateDataInterfaceForViewing"
                                                            label:[self.dataInterface getAssetId]
                                                            value:nil
                                                    forTrackerKey:[self getPxeEnvironmentNameForType:[self getPxeEnvironmentType]]];
        
        DLog(@"GoogleAnalytics Category for: %@", [self.dataInterface getClientAppName]);
        
        if (interface.masterPlaylist)
        {
            [self retrievePlaylistFromDataInterface:interface
                                       whenFinished:^(BOOL success) {
                                           NSError *err;
                                           if(!success)
                                           {
                                               err = [PxePlayerError errorForCode:PxePlayerPlaylistError];
                                           }
                                           if (handler)
                                           {
                                               handler(success, err);
                                           }
                                       }];
        }
        else
        {
#ifdef DEBUG
            [self markLoadTime:@"START - Retrieving TOC from DataInterface"];
#endif
            [self submitTOCUrlForIndexingWithCompletionHandler:^(NSString *indexId, NSError *err)
             {
#ifdef DEBUG
                 [self markLoadTime:@"FINISHED - Submitting TOC for Indexing"];
#endif
                 if(err)
                 {
                     self.dataInterface.indexId = nil;
                 }
                 else
                 {
                     DLog(@"indexID: %@", indexId);
                     self.dataInterface.indexId = indexId;
                     [[PxePlayerDataManager sharedInstance] updateContext:interface.contextId
                                                                attribute:@"search_index_id"
                                                                withValue:indexId];
                 }
             }];
            [self retrieveTOCFromDataInterface:interface
                                  whenFinished:^(BOOL success) {
                                    NSError *err;
                                    if(!success)
                                    {
                                        err = [PxePlayerError errorForCode:PxePlayerTOCError];
                                    }
                                    if (handler)
                                    {
                                        handler(success, err);
#ifdef DEBUG
                                        [self markLoadTime:@"FINISHED - Retrieving TOC from DataInterface"];
#endif
                                    }
                                }];
        }
    }
}

- (void) storeDataInterface:(PxePlayerDataInterface *)dataInterface
{
    if(self.dataInterface)
    {
        self.dataInterface = nil;
    }
    
    self.dataInterface = dataInterface;
    
    [self createCurrentUserFromDataInterface:dataInterface];
    
    [[PxePlayerDataManager sharedInstance] createCurrentContextWithDataInterface:dataInterface
                                                                     currentUser:self.currentPxePlayerUser
                                                                     withHandler:^(PxeContext *pxeContext, NSError *err){
                                                                         if (err)
                                                                         {
                                                                             //TODO: What to do if error creating context?
                                                                             DLog(@"ERROR UPDATING DATAINTERFACE: %@", err);
                                                                         }
                                                                     }];
}

- (void) setUpGoogleAnalytics
{
    if(!self.googleAnalyticsManager)
    {
        self.googleAnalyticsManager = [PxePlayerGoogleAnalyticsManager new];
        
        [self.googleAnalyticsManager addTrackerId:GA_PXE_SDK_DEV_TRACKING_ID forKey:[self getPxeEnvironmentNameForType:PxePlayerDevEnv]];
        [self.googleAnalyticsManager addTrackerId:GA_PXE_SDK_QA_TRACKING_ID forKey:[self getPxeEnvironmentNameForType:PxePlayerQAEnv]];
        [self.googleAnalyticsManager addTrackerId:GA_PXE_SDK_STAGING_TRACKING_ID forKey:[self getPxeEnvironmentNameForType:PxePlayerStagingEnv]];
        [self.googleAnalyticsManager addTrackerId:GA_PXE_SDK_PROD_TRACKING_ID forKey:[self getPxeEnvironmentNameForType:PxePlayerProdEnv]];
    }
}

- (PxePlayerUser*) createCurrentUserFromDataInterface:(PxePlayerDataInterface *)dataInterface
{
    BOOL mustStoreCurrentUser = NO;
    DLog(@"currentPxePlayerUSer: %@", self.currentPxePlayerUser);
    if(! self.currentPxePlayerUser)
    {
        mustStoreCurrentUser = YES;
    }
    else if(![self.currentPxePlayerUser.identityId isEqualToString:dataInterface.identityId])
    {
        mustStoreCurrentUser = YES;
    }
    
    if(mustStoreCurrentUser)
    {
        DLog(@"Creating Current User");
        PxePlayerUser *currUser = [PxePlayerUser new];
        currUser.identityId = dataInterface.identityId;
        if (dataInterface.authToken)
        {
            currUser.authToken = dataInterface.authToken;
        }
        
        self.currentPxePlayerUser = currUser;
    }
    [self storePxePlayerUser:self.currentPxePlayerUser];
    return self.currentPxePlayerUser;
}

- (void) retrieveTOCFromDataInterface:(PxePlayerDataInterface*)dInterface
                         whenFinished:(isSuccess)success
{
    DLog(@"Cache data: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    NSArray *tocTree = [[PxePlayerDataManager sharedInstance] fetchTocTree:nil
                                                              forContextId:dInterface.contextId];
    DLog(@"tocTree: %@", tocTree);
    // Check if TOC exist in DB for offline
    if(! [Reachability isReachable])
    {
        if (tocTree)
        {
            success(YES);
            return;
        }
    }
        
    // Get The TOC Parser
    BOOL useNCX = [dInterface.tocPath rangeOfString:@"toc.ncx"].location == NSNotFound?NO:YES;
    
    if (useNCX)
    {
        DLog(@"=======================================================================TOC.NCX");
        [self fetchNCXTOCAndWhenFinished:^(BOOL ncxSuccess)
         {
             DLog(@"ncxSuccess: %@", ncxSuccess?@"YES":@"NO");
             if (ncxSuccess)
             {
                 /* HACKER ALERT */
                 // TODO: This is garbage code becasue ncx titles can't have custom baskets
                 // See if there is any custom basket stuff
                 // Convert ncx to xhtml
                 dInterface.tocPath = [dInterface.tocPath stringByReplacingOccurrencesOfString:@"toc.ncx"
                                                                                    withString:@"xhtml/toc.xhtml"];
#ifdef DEBUG
                 [self markLoadTime:@"START - Fetch Custom Basket Data from TOCAPI"];
#endif
                 [self fetchCustomBasketDataFromCustomTOCAPI:dInterface whenFinished:^(BOOL customBasketSuccess)
                  {
#ifdef DEBUG
                      [self markLoadTime:@"FINISHED - Fetch Custom Basket Data from TOCAPI"];
#endif
                      // Convert back to ncx from xhtml
                      dInterface.tocPath = [dInterface.tocPath stringByReplacingOccurrencesOfString:@"xhtml/toc.xhtml"
                                                                                         withString:@"toc.ncx"];
                      success(ncxSuccess);
                  }];
                 
             }
             else
             {
                 success(ncxSuccess);
             }
         }];
    }
    else
    {
        DLog(@"=======================================================================TOC.XHTML");
//        DLog(@"url: %@", dInterface.ncxURL);
        // First, check the TOC API
        // Second, check for the toc.xhtml file
        // Third, check if there's a toc.ncx
        if ([tocTree count] > 0)
        {
            success(YES);
            return;
        }
        else
        {
#ifdef DEBUG
            [self markLoadTime:@"START - Fetch TOC data from TOCAPI"];
#endif
            [self fetchTOCDataFromTOCAPI:dInterface whenFinished:^(BOOL tocAPISuccess)
             {
                 DLog(@"tocAPISuccess: %@", tocAPISuccess?@"YES":@"NO");
#ifdef DEBUG
                 [self markLoadTime:@"FINISHED - Fetch TOC data from TOCAPI"];
#endif
                 if (tocAPISuccess)
                 {
#ifdef DEBUG
                     [self markLoadTime:@"START - Fetch Custom Basket Data from TOCAPI"];
#endif
                     [self fetchCustomBasketDataFromCustomTOCAPI:dInterface whenFinished:^(BOOL customBasketSuccess)
                      {
#ifdef DEBUG
                          [self markLoadTime:@"FINISHED - Fetch Custom Basket Data from TOCAPI"];
#endif
                          success(tocAPISuccess);
                      }];
                 }
                 else
                 {
                     [self fetchXHTMLTOCAndWhenFinished:^(BOOL xhtmlSuccess)
                      {
                          DLog(@"xhtmlSuccess: %@", xhtmlSuccess?@"YES":@"NO");
                          if (xhtmlSuccess)
                          {
                              [self fetchCustomBasketDataFromDataInterface:self.dataInterface whenFinished:^(BOOL customBasketSuccess)
                               {
                                   success(xhtmlSuccess);
                               }];
                          }
                          else
                          {
                              dInterface.tocPath = [dInterface.tocPath stringByReplacingOccurrencesOfString:@"xhtml/toc.xhtml"
                                                                                               withString:@"toc.ncx"];
                              // TODO: Why do this here?
                              [self storeDataInterface:dInterface];
                              
                              [self fetchNCXTOCAndWhenFinished:^(BOOL ncxSuccess)
                               {
                                   DLog(@"ncxSuccess: %@", ncxSuccess?@"YES":@"NO");
                                   success(ncxSuccess);
                               }];
                          }
                      }];
                 }
             }];
        }
    }
}

- (void) fetchTOCDataFromTOCAPI:(PxePlayerDataInterface*)dataInterface whenFinished:(isSuccess)success
{
    PxePlayerTocParser *tocParser = [[PxePlayerJSONTOCParser alloc] init];
    
#ifdef DEBUG
    [self markLoadTime:@"START - Parse TOC Data"];
#endif
    [tocParser parseTOCDataFromDataInterface:dataInterface
                                 withHandler:^(id receivedNavigator, NSError *error)
     {
         if(error)
         {
             success(NO);
         }
         else
         {
             DLog(@"receivedNavigator: %@", receivedNavigator);
#ifdef DEBUG
             [self markLoadTime:@"FINISHED - Parse TOC Data"];
#endif
             if(receivedNavigator)
             {
#ifdef DEBUG
                 [self markLoadTime:@"START - Fetch and Store Manifest Data"];
#endif
                 [self storeManifestDataForDataInterface:dataInterface
                                             tocChapters:[self retrieveTOCLevelOneAsChapters:receivedNavigator]
                                       completionHandler:^(BOOL manifestSuccess) {
                     if (manifestSuccess)
                     {
                         DLog(@"Success storing manifest and items!");
                     }
#ifdef DEBUG
                     [self markLoadTime:@"FINISHED - Fetch and Store Manifest Data"];
#endif
                     success(YES);
                 }];
             }
             else
             {
                 success(NO);
             }
         }
     }];
}

- (NSDictionary*) retrieveTOCLevelOneAsChapters:(NSDictionary*)toc
{
    return [toc valueForKeyPath:@"toc.items"];
}

- (void) retrievePlaylistFromDataInterface:(PxePlayerDataInterface*)dInterface
                              whenFinished:(isSuccess)success
{
    DLog(@"RetrievingPlaylist: %@", dInterface.masterPlaylist)
    [self submitUrlsForIndexing:dInterface.masterPlaylist withCompletionHandler:^(NSString *indexId, NSError *err)
     {
         if(!err)
         {
             self.dataInterface.indexId = indexId;
         }
         else
         {
             DLog(@"Error submitting URLs for indexing: %@", err);
             self.dataInterface.indexId = nil;
         }
    }];
//         DLog(@"Playlist: %@", dInterface.masterPlaylist);
     //put the list into the db it will be flat
     PxePlayerTocParser *tocParser = [[PxePlayerMasterPlaylistParser alloc] init];
     
     //download NCX content
     [tocParser parseMasterPlaylistFromDataInterface:dInterface
                                         withHandler:^(id receivedNavigator, NSError *error) {
         if(!error)
         {
             success([receivedNavigator boolValue]);
         }
         else
         {
             success(NO);
         }
     }];
}

- (void) fetchNCXTOCAndWhenFinished:(isSuccess)success
{
    PxePlayerTocParser *tocParser = [[PxePlayerNCXCDParser alloc] init];
    
    [tocParser parseDataFromInterface:self.dataInterface withHandler:^(id receivedNavigator, NSError *error)
    {
        if(error)
        {
            DLog(@"success NOOOOOOOOOOOOOOOOOOOOOOOOO");
            success(NO);
        }
        else
        {
            DLog(@"receivedNavigator: %@", receivedNavigator);
            if([receivedNavigator boolValue])
            {
                success([receivedNavigator boolValue]);
            }
            else
            {
                success(NO);
            }
        }
    }];
}

- (void) fetchXHTMLTOCAndWhenFinished:(isSuccess)success
{
    PxePlayerTocParser *tocParser = [[PxePlayerXHTMLParser alloc] init];
    
    [tocParser parseDataFromInterface:self.dataInterface withHandler:^(id receivedNavigator, NSError *error)
     {
         if(error)
         {
             success(NO);
         }
         else
         {
             if([receivedNavigator boolValue])
             {
                 success([receivedNavigator boolValue]);
             }
             else
             {
                 success(NO);
             }
         }
     }];
}

- (void) fetchCustomBasketDataFromCustomTOCAPI:(PxePlayerDataInterface*)dataInterface whenFinished:(isSuccess)success
{
    PxePlayerJSONCustomBasketParser *customBasketParser = [[PxePlayerJSONCustomBasketParser alloc] init];
    
    [customBasketParser parseCustomBasketDataFromDataInterface:dataInterface withHandler:^(id receivedNavigator, NSError *error)
     {
         DLog(@"receivedNavigator: %@", receivedNavigator);
         DLog(@"error: %@", error);
         if(!error)
         {
             success(YES);
         }
         else
         {
             DLog(@"Error parsing Custom Basket Data: %@", error);
             // Sometimes the Custom Basket data provided in the additional toc.xhtml
             // is bad data so just go ahead and run without the custom basket.
             success(NO);
         }
     }];
}

- (void) fetchCustomBasketDataFromDataInterface:(PxePlayerDataInterface*)dataInterface whenFinished:(isSuccess)success
{
    PxePlayerTocParser *customBasketParser = [[PxePlayerXHTMLParser alloc] init];
    
    [customBasketParser parseCustomBasketDataFromDataInterface:dataInterface withHandler:^(id receivedNavigator, NSError *error)
    {
        if(!error)
        {
            success(YES);
        } else {
            DLog(@"Error parsing Custom Basket Data: %@", error);
            // Sometimes the Custom Basket data provided in the additional toc.xhtml
            // is bad data so just go ahead and run without the custom basket.
            success(YES);
        }
    }];
}

- (void) storeManifestDataForDataInterface:(PxePlayerDataInterface*)dataInterface
                               tocChapters:(NSDictionary*)chapters
                         completionHandler:(void (^)(BOOL))success {
    
    if ([self isManifestInStoreForBook:dataInterface.contextId]) {
        success(YES);
        return;
    }
    
    NSString *manifestBaseUrl = [self.environmentContext getWebAPIEndpoint];
    if (!manifestBaseUrl || [manifestBaseUrl isEqualToString:@""]) {
        DLog(@"Client did not provide manifest API base url");
        success(NO);
        return;
    }
    
    [self createCurrentUserFromDataInterface:dataInterface];
    
    NSString *manifestApiUrl = [manifestBaseUrl stringByAppendingString:[NSString stringWithFormat:PXE_Manifest_API, dataInterface.contextId]];
    DLog(@"manifestApiUrl: %@", manifestApiUrl);
    [PxePlayerInterface downloadManifestDataWithUrl:manifestApiUrl
                              withCompletionHandler:^(NSDictionary *manifestDict, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                    if (!error) {
                                        DLog(@"Currently on thread %@", [NSThread currentThread]);
                                        
                                        PxePlayerManifestParser *manifestParser = [PxePlayerManifestParser new];
                                        [manifestParser parseManifestDataDictionary:manifestDict
                                                                      dataInterface:dataInterface
                                                                        tocChapters:(NSDictionary*)chapters
                                                                        withHandler:^(id result, NSError *error) {
                                                                            if (!result) {
                                                                                DLog(@"ERROR - failed to insert manifest");
                                                                                success(NO);
                                                                            }
                                                                            else {
                                                                                success(YES);
                                                                            }
                                                                        }];
                                    }
                                    else {
                                        success(NO);
                                        DLog(@"Paper API found no manifest for this book.");
                                    }
                                });
                         }];
}

-(BOOL) isManifestInStoreForBook:(NSString*)contextId {
    
    PxeManifest *dbManifest;
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSArray *manifests = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeManifest class])
                                               withSortKey:nil
                                                 ascending:NO
                                             withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", contextId]
                                                fetchLimit:0
                                                resultType:NSManagedObjectResultType];
    dbManifest = [manifests firstObject];
    
    if (!dbManifest) {
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL) isTOCDownloadedForContext:(NSString*)contextId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"context.context_id = %@", contextId];
    
    NSUInteger tocPageCount = [[PxePlayerDataManager sharedInstance] fetchCount:NSStringFromClass([PxePageDetail class])
                                                                       property:@"pageId"
                                                                      predicate:predicate];
    
    return (tocPageCount > 0);
}

#pragma mark - Getting instance methods

+(id) sharedInstance
{
    static PxePlayer* sharedApplication = nil;
    //Create shared instance of the UI Library
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApplication = [[self alloc] init];
    });
    
    return sharedApplication;
}

-(void)purgeCachedData
{
    [HMCache resetCache];
}

-(PxePlayerPageViewController*)renderWithOptions:(PxePlayerPageViewOptions*)options
{
    PxePlayerPageViewController* pageVC = [[PxePlayerPageViewController alloc] initWithDataInterface:self.dataInterface
                                                                                  customPlaylistURLs:nil
                                                                                         andGotoPage:nil
                                                                                         withOptions:options];
    return pageVC;
}

-(PxePlayerPageViewController*)renderPage:(NSString*)URLOrContentID withOptions:(PxePlayerPageViewOptions*)options
{
    PxePlayerPageViewController* pageVC = [[PxePlayerPageViewController alloc] initWithDataInterface:self.dataInterface
                                                                                  customPlaylistURLs:nil
                                                                                         andGotoPage:URLOrContentID
                                                                                         withOptions:options];
    return pageVC;
}

-(PxePlayerPageViewController*)renderCustomPlaylist:(NSArray*)urls withOptions:(PxePlayerPageViewOptions*)options
{
    PxePlayerPageViewController* pageVC = [[PxePlayerPageViewController alloc] initWithDataInterface:self.dataInterface
                                                                                  customPlaylistURLs:urls
                                                                                         andGotoPage:nil
                                                                                         withOptions:options];
    return pageVC;
}

-(PxePlayerPageViewController*)renderCustomPlaylist:(NSArray*)urls andJumpToPage:(NSString*)URLOrContentID withOptions:(PxePlayerPageViewOptions*)options
{
    PxePlayerPageViewController* pageVC = [[PxePlayerPageViewController alloc] initWithDataInterface:self.dataInterface
                                                                                  customPlaylistURLs:urls
                                                                                         andGotoPage:URLOrContentID
                                                                                         withOptions:options];
    return pageVC;
}

- (PxeContext*) getCurrentContext
{
    return [self getCurrentContextForContextId:self.dataInterface.contextId];
}

- (PxeContext*) getCurrentContextForContextId:(NSString*)contextId
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    PxeContext *currentContext;
    
    NSArray *contextResults = [dataManager fetchEntities:@[@"context_id",@"search_index_id"]
                                                forModel:NSStringFromClass([PxeContext class])
                                           withPredicate:[NSPredicate predicateWithFormat:@"context_id == %@", contextId]
                                              resultType:NSManagedObjectResultType
                                             withSortKey:nil
                                            andAscending:YES
                                              fetchLimit:1
                                              andGroupBy:nil];
    if([contextResults count])
    {
        currentContext = contextResults[0]; //just grab that first book and set it
    }
    
    return currentContext;
}

#pragma mark - Google Analytics

- (void) dispatchGAIEventWithCategory:(NSString*)category
                               action:(NSString*)action
                                label:(NSString*)label
                                value:(NSNumber*)value
{
    if (! self.googleAnalyticsManager)
    {
        [self setUpGoogleAnalytics];
    }
    [self.googleAnalyticsManager dispatchGAIEventWithCategory:category
                                                       action:action
                                                        label:label
                                                        value:value
                                                forTrackerKey:[self getPxeEnvironmentNameForType:[self getPxeEnvironmentType]]];
    
}

- (void) dispatchGAIScreenEventForPage:(NSString*)pageURL
{
    if (! self.googleAnalyticsManager)
    {
        [self setUpGoogleAnalytics];
    }
    if (pageURL)
    {
        [self.googleAnalyticsManager dispatchGAIScreenEventForPage:pageURL
                                                     forTrackerKey:[self getPxeEnvironmentNameForType:[self getPxeEnvironmentType]]];
    }
}

#pragma mark - Glossary

- (id) parseGlossaryManagedData:(NSArray*)glossaryArray
{
    NSMutableArray *glossaryTerms = [NSMutableArray array];
    
    for (PxeGlossary *glossary in glossaryArray) {
        NSDictionary *glossaryObj = @{
                                      @"term" : glossary.term,
                                      @"definition" : glossary.definition,
                                      @"key" : glossary.key
                                      };
        
        [glossaryTerms addObject:glossaryObj];
    }
    
    return  glossaryTerms;

}

- (BOOL) insertGlossaryItems:(NSArray*)glossaryObjs
{
    return [self insertGlossaryItems:glossaryObjs
                   withDataInterface:self.dataInterface];
}

- (BOOL) insertGlossaryItems:(NSArray*)glossaryObjs
           withDataInterface:(PxePlayerDataInterface*)dataInterface
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
    
    for(NSDictionary *glossaryObj in glossaryObjs)
    {
        PxeGlossary *glossaryDetail = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeGlossary class])
                                                                    inManagedObjectContext:objectContext];
        
        if ((id)[glossaryObj objectForKey:@"definition"] == [NSNull null])
        {
            glossaryDetail.definition = @"";
        } else {
            glossaryDetail.definition = [glossaryObj objectForKey:@"definition"];
        }
        if ((id)[glossaryObj objectForKey:@"meaning"] == [NSNull null])
        {
            glossaryDetail.term = @"";
        } else {
            glossaryDetail.term = [glossaryObj objectForKey:@"term"];
        }
        glossaryDetail.key = [glossaryObj objectForKey:@"key"];
        glossaryDetail.context = [self getCurrentContextForContextId:dataInterface.contextId];
        DLog(@"glossaryDetail.context: %@", glossaryDetail.context);
        DLog(@"glossaryDetail.key: %@", glossaryDetail.key);
        DLog(@"glossaryDetail.term: %@", glossaryDetail.term);
        DLog(@"glossaryDetail.definition: %@", glossaryDetail.definition);
        if(![dataManager save])
        {
            return NO; //oops failed!
        }
    }
    
    return YES;
}

-(void)getGlossaryWithCompletionHandler:(void (^)(NSArray*, NSError*))handler
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    //is it already downloaded?
    if([dataManager fetchGlossaryforContextId:self.dataInterface.contextId].count > 0)
    {
        DLog(@"[dataManager fetchGlossary].count > 0, contextID: %@", self.dataInterface.contextId);
        PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
        
        NSArray * glossaryTerms = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeGlossary class])
                                                         withSortKey:@"term"
                                                           ascending:YES
                                                       withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", self.dataInterface.contextId]
                                                          fetchLimit:0
                                                          resultType:NSManagedObjectResultType];
        
        if(glossaryTerms.count > 0)
        {
            if (handler)
            {
                handler([self parseGlossaryManagedData:glossaryTerms],nil);
            }
        } else {
            if (handler)
            {
                handler(nil,[PxePlayerError errorForCode:PxePlayerGlossaryNotFound]);
            }
        }
    } else { //go get it
        DLog(@"contextID: %@", self.dataInterface.contextId);
        DLog(@"indexID: %@", self.dataInterface.indexId);
        if (self.dataInterface.indexId)
        {
            if([Reachability isReachable])
            {
                NSDictionary *query = @{@"contextId":self.dataInterface.indexId};
                
                [PxePlayerInterface downloadGlossary:query withCompletionHandler:^(id glossaryTerms, NSError *error) {
                    
                    if ([glossaryTerms count] > 0)
                    {
                        [self insertGlossaryItems:glossaryTerms];
                    }
                    if (handler)
                    {
                        handler(glossaryTerms,error);
                    }
                }];
            } else {
                if (handler)
                {
                    handler(nil,[PxePlayerError errorForCode:PxePlayerNetworkUnreachable]);
                }
            }
        }
        else
        {
            if (handler)
            {
                handler(nil,[PxePlayerError errorForCode:PxePlayerGlossaryNotFound]);
            }
        }
    }
}

- (BOOL) deleteGlossaryOnDevice
{
    BOOL didComplete = YES;
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *objectContext = [dataManager getObjectContext];
    
    NSArray * glossaryTerms = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeGlossary class])
                                                     withSortKey:@"term"
                                                       ascending:YES
                                                   withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", self.dataInterface.contextId]
                                                      fetchLimit:0
                                                      resultType:NSManagedObjectResultType];
    
    if(glossaryTerms.count > 0)
    {
        for (PxeGlossary *glossaryTerm  in glossaryTerms)
        {
            [objectContext deleteObject:glossaryTerm];
        }
        
        if(![dataManager save])
        {
            didComplete = NO;
        }
    }
    
    return didComplete;
}

- (void) refreshGlossaryOnDeviceWithCompletionHandler:(void (^)(NSArray *, NSError *))handler
{
    if ([self deleteGlossaryOnDevice])
    {
        [self getGlossaryWithCompletionHandler:nil];
    }
}

#pragma mark -

-(NSArray*)getTocTree:(NSString*)parentId
{
    return [[PxePlayerDataManager sharedInstance] fetchTocTree:parentId forContextId:self.dataInterface.contextId];
}

-(NSArray*)getCustomBasketTree:(NSString*)parentId
{
    DLog(@"Context ID: %@ ::: parentID: %@", self.dataInterface.contextId, parentId);
    return [[PxePlayerDataManager sharedInstance] fetchBasketTree:parentId forContextId:self.dataInterface.contextId];
}

- (BOOL) currentContextHasCustomBasket
{
    BOOL hasCustomBasket = NO;
    NSArray *customBasketAR = [self getCustomBasketTree:@"root"];
    NSLog(@"customBasketAR: %@", customBasketAR);
    if (customBasketAR)
    {
        if ([customBasketAR count] > 0)
        {
            hasCustomBasket = YES;
        }
    }
    return hasCustomBasket;
}

-(NSUInteger)getTotalPageEntry
{
    return [[PxePlayerDataManager sharedInstance] fetchCount:NSStringFromClass([PxePageDetail class])
                                                    property:@"pageId"
                                                forContextId:self.dataInterface.contextId];
}

-(NSDictionary*)getPageDetails:(NSString*)property withValue:(NSString*)value
{
    NSLog(@"property: %@:::value: %@", property, value);
    return [[PxePlayerDataManager sharedInstance] fetchEntity:property
                                                 forContextId:self.dataInterface.contextId
                                                     forModel:NSStringFromClass([PxePageDetail class])
                                                    withValue:value];
}

- (NSDictionary*) getPageDetails:(NSString*)property containingValue:(NSString*)value
{
    NSLog(@"property: %@:::value: %@", property, value);
    return [[PxePlayerDataManager sharedInstance] fetchEntity:property
                                                 forContextId:self.dataInterface.contextId
                                                     forModel:NSStringFromClass([PxePageDetail class])
                                              containingValue:value];
}

- (BOOL) usingPlaylist
{
    if(self.dataInterface.masterPlaylist)
    {
        return YES;
    }
    return NO;
}

- (NSString*) getPXEVersion
{
    NSString *pxeVersion;
    
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"PxeReaderResources"
                                               withExtension:@"bundle"];
    
    if (bundleURL)
    {
        pxeVersion = [[NSBundle bundleWithURL:bundleURL] objectForInfoDictionaryKey:@"CFBundleVersion"];
    }
    
    return pxeVersion;
}

#pragma mark - User
- (void) storePxePlayerUser:(PxePlayerUser*)pxePlayerUser
{
    [[PxePlayerDataManager sharedInstance] readPxeUserWithData:pxePlayerUser withCompletionHandler:^(NSArray *pxeUsers, NSError *err) {
        if (! err)
        {
            if (!pxeUsers || [pxeUsers count] == 0)
            {
                DLog(@"NEW USER");
                [[PxePlayerDataManager sharedInstance] createPxeUserWithData:pxePlayerUser withCompletionHandler:^(PxeUser *pxeUser, NSError *err) {
                    if (err)
                    {
                        DLog(@"Error creating PxeUser");
                    }
                }];
            }
            else
            {
                [[PxePlayerDataManager sharedInstance] updatePxeUserWithData:pxePlayerUser withCompletionHandler:^(PxeUser *pxeUser, NSError *err) {
                    if (err)
                    {
                        DLog(@"Error updating PxeUser");
                    }
                }];
            }
        }
        else
        {
            DLog(@"Error reading PxeUser");
        }
    }];
}

@end

#pragma mark - Bookmark
@implementation PxePlayer (Bookmarks)

#pragma mark - Bookmark Offline
- (void) getBookmarksOnDevice:(void (^)(PxePlayerBookmarks*, NSError*))handler
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    DLog(@"contextId: %@", self.dataInterface.contextId);
    NSArray *allBookmarks = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeBookMark class])
                                                   withSortKey:@"title"
                                                     ascending:YES
                                                 withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", self.dataInterface.contextId]
                                                    fetchLimit:NO
                                                    resultType:NSManagedObjectResultType];
    DLog(@"allBookmarks: %@", allBookmarks);
    if(allBookmarks.count > 0)
    {
        PxePlayerBookmarks *bookmarks = [[PxePlayerBookmarks alloc] init];
        bookmarks.contextId = nil;
        bookmarks.identityId = nil;
        
        for (PxeBookMark *bm in allBookmarks)
        {
            PxePlayerBookmark *bookmark = [[PxePlayerBookmark alloc] init];
            bookmark.uri = bm.url;
            bookmark.bookmarkTitle = bm.title;
            bookmark.createdTimestamp = [NSNumber numberWithDouble:[bm.created timeIntervalSince1970]];
            
            [bookmarks.bookmarks addObject:bookmark];
        }
        
        handler(bookmarks,nil);
    }else{
        handler(nil,[PxePlayerError errorForCode:PxePlayerParseError]);
    }
}

-(NSArray*)getMarkedDeletedBookmarks{
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSArray *bookmarks = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeBookMark class])
                                                withSortKey:@"title"
                                                  ascending:YES
                                              withPredicate:[NSPredicate predicateWithFormat:@"markedDelete == 1"]
                                                 fetchLimit:NO
                                                 resultType:NSManagedObjectResultType];
    
    return bookmarks;
}

-(NSArray*)getQueuedBookmarks{
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSArray *bookmarks = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeBookMark class])
                                                withSortKey:@"title"
                                                  ascending:YES
                                              withPredicate:[NSPredicate predicateWithFormat:@"queued == 1"]
                                                 fetchLimit:NO
                                                 resultType:NSManagedObjectResultType];
    
    return bookmarks;
}

- (BOOL) deleteAllBookmarksForCurrentBook
{
    DLog(@"DELETE ALL BOOKMARKS FOR CURRENT BOOK");
    return [self deleteAllBookmarksForContextId:self.dataInterface.contextId];
}

- (BOOL) deleteAllBookmarksForContextId:(NSString*)contextId
{
    DLog(@"DELETE ALL BOOKMARKS FOR CONTEXT ID: %@", contextId);
    BOOL didComplete = YES;
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
    
    NSPredicate *deleteBookmarksPredicate = [NSPredicate predicateWithFormat:@"queued == 0 && markedDelete == 0 && context.context_id == %@", contextId];
    DLog(@"deleteBookmarksPredicate: %@", deleteBookmarksPredicate);
    NSArray *bookmarks = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeBookMark class])
                                                withSortKey:@"title"
                                                  ascending:YES
                                              withPredicate:deleteBookmarksPredicate
                                                 fetchLimit:NO
                                                 resultType:NSManagedObjectResultType];
    
    if(bookmarks.count > 0)
    {
        for (PxeBookMark *bmark  in bookmarks)
        {
            [objectContext deleteObject:bmark];
        }
        
        if(![dataManager save])
        {
            didComplete = NO;
        }
    }
    DLog(@"Bookmarks DELETE COMPLETE");
    return didComplete;
}

-(BOOL)modifyBookmark:(PxePlayerAddBookmark*)bookmarkObj
         forContextId:(NSString*)contextId
             isDelete:(BOOL)isDelete
                isNew:(BOOL)isNew
{
    BOOL didComplete = YES;
    
    if (!contextId)
    {
        contextId = self.dataInterface.contextId;
    }
    DLog(@"contextId: %@", contextId);
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
//    DLog(@"isDelete: %@", isDelete?@"YES":@"NO");
//    DLog(@"isNew: %@", isNew?@"YES":@"NO");
    if(isDelete || !isNew)
    {
        NSArray *bmarks = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeBookMark class])
                                                 withSortKey:@"title"
                                                   ascending:YES
                                               withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@ && url == %@", contextId, bookmarkObj.uri] fetchLimit:NO
                                                  resultType:NSManagedObjectResultType];
        if(isDelete){
            //Delete
            for (PxeBookMark *bookmarkDetail  in bmarks)
            {
                if(bookmarkDetail.markedDelete && [Reachability isReachable])
                { //if NOT online just mark it delete and wait til we are online
                    [objectContext deleteObject:bookmarkDetail];
                }else{
                    bookmarkDetail.markedDelete = @(bookmarkObj.markedDelete);
                }
            }
        } else {
            //Update (! isNew)
            for (PxeBookMark *bookmarkDetail  in bmarks)
            {
                bookmarkDetail.title = bookmarkObj.bookmarkTitle;
                bookmarkDetail.url = bookmarkObj.uri; //relative only
                bookmarkDetail.created = [NSDate dateWithTimeIntervalSince1970:[bookmarkObj.createdTimestamp doubleValue]];
                bookmarkDetail.context = [self getCurrentContextForContextId:contextId];
                bookmarkDetail.queued = @(bookmarkObj.queued); //used for offline queuing
                bookmarkDetail.markedDelete = @(bookmarkObj.markedDelete); //used for offline queuing
            }
        }
        
    } else {
        //Add New
        PxeBookMark *bookmarkDetail = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeBookMark class]) inManagedObjectContext:objectContext];
        
        bookmarkDetail.title = bookmarkObj.bookmarkTitle;
        bookmarkDetail.url = bookmarkObj.uri; //relative only
        bookmarkDetail.created = [NSDate dateWithTimeIntervalSince1970:[bookmarkObj.createdTimestamp doubleValue]];
        bookmarkDetail.context = [self getCurrentContextForContextId:contextId];
        bookmarkDetail.queued = @(bookmarkObj.queued); //used for offline queuing
        bookmarkDetail.markedDelete = @(bookmarkObj.markedDelete); //used for offline queuing
    }
    if(![dataManager save])
    {
        didComplete = NO;
    }

    return didComplete;
    
}

-(void)checkBookmarkOnDevice:(PxePlayerBookmarkQuery*) query withCompletionHandler:(void (^)(PxePlayerCheckBookmark*, NSError*))handler
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    DLog(@"uri: %@", query.uri);
    query.uri = [[PxePlayer sharedInstance] formatRelativePathForTOC:query.uri];
    NSArray *bookmarks = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeBookMark class]) withSortKey:@"title" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@ && url == %@", self.dataInterface.contextId, query.uri] fetchLimit:NO resultType:NSManagedObjectResultType];
    
    PxePlayerCheckBookmark* bookmarkStatus = [[PxePlayerCheckBookmark alloc] init];
    
    if(bookmarks.count > 0)
        bookmarkStatus.isBookmarked = @(YES);//nsnumber
    else
        bookmarkStatus.isBookmarked = @(NO);//nsnumber
    
    bookmarkStatus.forPageUrl = query.uri;
    
    handler(bookmarkStatus,nil);
}

- (void) addBookmarksOnDevice:(NSArray*)bookmarks
{
    //warning removing this causes dups.
    if(![self deleteAllBookmarksForCurrentBook])
    {
        DLog(@"ERROR Deleting bookmarks!");
    }
    //Now go update the DB with all the little bookmarks
    for (PxePlayerAddBookmark *bookmarkObj in bookmarks)
    {
        if(![self modifyBookmark:bookmarkObj forContextId:self.dataInterface.contextId isDelete:NO isNew:YES])
        {
            DLog(@"Bookmark did not save");
        }
    }
}

- (void) addBookmarksOnDevice:(NSArray*)bookmarks withDataInterface:(PxePlayerDataInterface*)dataInterface
{
    //warning removing this causes dups.
    if(![self deleteAllBookmarksForContextId:dataInterface.contextId])
    {
        DLog(@"ERROR Deleting bookmarks!");
    }
    //Now go update the DB with all the little bookmarks
    for (PxePlayerAddBookmark *bookmarkObj in bookmarks)
    {
        DLog(@"bookmarkObject: %@", bookmarkObj);
        if(![self modifyBookmark:bookmarkObj forContextId:dataInterface.contextId isDelete:NO isNew:YES])
        {
            DLog(@"Bookmark did not save");
        }
    }
}

-(void) addBookmarkOnDevice:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler
{
    PxePlayerAddBookmark *addBookmark = [[PxePlayerAddBookmark alloc] init];
    addBookmark.uri = query.uri;
    addBookmark.bookmarkTitle = query.bookmarkTitle;
    addBookmark.createdTimestamp = query.createdTimestamp;
    addBookmark.queued = ![Reachability isReachable];
    addBookmark.baseURL = query.baseURL;

    [self modifyBookmark:addBookmark forContextId:self.dataInterface.contextId isDelete:NO isNew:YES];
    
    //we are offline so we need to update UI
    if (handler)
    {
        handler(addBookmark,nil);
    }
}


-(void) deleteBookmarkOnDevice:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler{
    
    PxePlayerAddBookmark *bookmark = [[PxePlayerAddBookmark alloc] init];
    bookmark.uri = query.uri;
    bookmark.bookmarkTitle = query.bookmarkTitle;
    bookmark.createdTimestamp = query.createdTimestamp;
    bookmark.markedDelete = YES;
    bookmark.contextID = self.dataInterface.contextId;
    bookmark.baseURL = query.baseURL;
    
    [self modifyBookmark:bookmark forContextId:self.dataInterface.contextId isDelete:YES isNew:NO];
    
    if (handler)
    {
        //we are offline so we need to update UI
        handler(bookmark,nil);
    }
}

-(void) editBookmarkOnDevice:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler
{
    PxePlayerAddBookmark *bookmark = [[PxePlayerAddBookmark alloc] init];
    bookmark.uri = query.uri;
    bookmark.bookmarkTitle = query.bookmarkTitle; //new title
    bookmark.createdTimestamp = query.createdTimestamp;
    bookmark.queued = ![Reachability isReachable];
    bookmark.contextID = self.dataInterface.contextId;
    bookmark.baseURL = query.baseURL;
    
    [self modifyBookmark:bookmark forContextId:self.dataInterface.contextId isDelete:NO isNew:NO];
    
    if (handler)
    {
        handler(bookmark,nil);
    }
}

-(void)queueOfflineForCompletion
{
    //do delete first
    [self queueBookmarkForDeletion];
    
    [self queueBookmarkForAddition];
}

-(void)queueBookmarkForDeletion{
    
    //get all bookmarks in queued state (YES)
    NSArray *bookmarks = [self getMarkedDeletedBookmarks];
    
    if(bookmarks.count >0)
    {
        //make an array of pxeplayerbookmarkquery's
        for(PxeBookMark *book in bookmarks){
            PxePlayerBookmarkQuery* bq = [[PxePlayerBookmarkQuery alloc] init];
            bq.contextID = book.context.context_id;
            bq.bookUUID = book.context.context_id;//what is this???
            //TODO: This is set twice...here and at the bottom
            bq.uri = book.url;
            bq.bookmarkTitle = book.title;
            bq.authToken = self.currentPxePlayerUser.authToken;
            bq.userUUID = self.currentPxePlayerUser.identityId;
            bq.createdTimestamp = [NSNumber numberWithDouble:[book.created timeIntervalSince1970]];
            bq.baseURL = [self getOnlineBaseURL];
            
            [PxePlayerInterface deleteBookmark:bq withCompletionHandler:^(PxePlayerBookmark *bookmark, NSError *error) {

                if(!error){
                    if(![self modifyBookmark:(PxePlayerAddBookmark*)bookmark forContextId:self.dataInterface.contextId isDelete:YES isNew:NO]){
                        NSLog(@"Delete Failed.");
                    }
                }
            }];
        }
    }
}
 
-(void)queueBookmarkForAddition
{
    //get all bookmarks in queued state (YES)
    NSArray *bookmarks = [self getQueuedBookmarks];
    
    if(bookmarks.count >0)
    {
        NSMutableArray * queries = [@[]mutableCopy];
        //make an array of pxeplayerbookmarkquery's
        for(PxeBookMark *book in bookmarks)
        {
            PxePlayerBookmarkQuery* bq = [[PxePlayerBookmarkQuery alloc] init];
            bq.contextID = book.context.context_id;
            bq.bookUUID = book.context.context_id;//what is this???
            bq.uri = book.url;
            bq.bookmarkTitle = book.title;
            bq.authToken = self.currentPxePlayerUser.authToken;
            bq.userUUID = self.currentPxePlayerUser.identityId;
            bq.createdTimestamp = [NSNumber numberWithDouble:[book.created timeIntervalSince1970]];
            bq.baseURL = [self getOnlineBaseURL];
            
            [queries addObject:bq];
        }
        
        [PxePlayerInterface addBulkBookmark:queries withCompletionHandler:^(NSArray *bulkBookmarks, NSError *error) {
            //if successful toggle queued
            if(!error){
                for(PxePlayerAddBookmark *bookmark in bulkBookmarks){
                    bookmark.queued = NO;
                    if(![self modifyBookmark:bookmark forContextId:self.dataInterface.contextId isDelete:NO isNew:NO]){
                        NSLog(@"Toggle Failed.");
                    }
                }
            }
        }];
    }
}

#pragma mark - Bookmarks Online

-(void)getBookmarksWithCompletionHandler:(void (^)(PxePlayerBookmarks*, NSError*))handler
{
    if([Reachability isReachable])
    {
        PxePlayerBookmarkQuery* bq = [[PxePlayerBookmarkQuery alloc] init];
        bq.bookUUID = self.dataInterface.contextId;
        bq.authToken = self.currentPxePlayerUser.authToken;
        bq.userUUID = self.currentPxePlayerUser.identityId;
        bq.baseURL = [self getOnlineBaseURL];
        DLog(@"getBookmarks for url: %@", bq.baseURL);
        [PxePlayerInterface getBookmarks:bq withCompletionHandler:^(PxePlayerBookmarks *bookmarks, NSError *error) {
            [self addBookmarksOnDevice:bookmarks.bookmarks];
            if (handler)
            {
                handler(bookmarks, error);
            }
        }];
    } else {
        //get it out of the DB
        [self getBookmarksOnDevice:^(PxePlayerBookmarks *bookmarks, NSError *error) {
            //now toss it back up
            if (handler)
            {
                handler(bookmarks, error);
            }
        }];
    }
}

- (void) addBookmarkWithTitle:(NSString*)bookmarkTitle
                       andURL:(NSString*)url
        withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler
{
    DLog(@"url: %@", url);
    if ([Reachability isReachable])
    {
        if(url)
        {
            PxePlayerBookmarkQuery* bq = [[PxePlayerBookmarkQuery alloc] init];
            bq.bookUUID = self.dataInterface.contextId;
            bq.uri = [self formatRelativePathForJavascript:[self removeBaseUrlFromUrl:url]];
            DLog(@"uri: %@", bq.uri);
            bq.bookmarkTitle = bookmarkTitle;
            bq.authToken = self.currentPxePlayerUser.authToken;
            bq.userUUID = self.currentPxePlayerUser.identityId;
            bq.createdTimestamp = @([TimeStamp intValue]);
            bq.baseURL = [self getOnlineBaseURL];
            
            [PxePlayerInterface addBookmark:bq withCompletionHandler:^(PxePlayerBookmark *bm, NSError *error) {
                [self dispatchGAIEventWithCategory:@"bookmark"
                                            action:@"addBookmark"
                                             label:bq.uri
                                             value:nil];
                [self addBookmarkOnDevice:bq withCompletionHandler:^(PxePlayerBookmark *bm, NSError *error) {
                    if (handler)
                    {
                        handler(bm,error);
                    }
                }];
            }];
        }
    }
    else
    {
        // **** NEED THIS UNTIL OFFLINE SYNC ****
        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Adding bookmark not available while offline.", @"Adding bookmark not available while offline.")};
        NSError *error = [PxePlayerError errorForCode:PxePlayerNetworkUnreachable errorDetail:errorDict];
        handler(nil, error);
    }
}

-(void)checkBookmarkWithURL:(NSString*)url withCompletionHandler:(void (^)(PxePlayerCheckBookmark*, NSError*))handler
{
    DLog(@"url: %@", url);
    if(url)
    {
        PxePlayerBookmarkQuery* bq = [[PxePlayerBookmarkQuery alloc] init];
        bq.bookUUID = self.dataInterface.contextId;
        bq.authToken = self.currentPxePlayerUser.authToken;
        bq.userUUID = self.currentPxePlayerUser.identityId;
        bq.uri = [self formatRelativePathForJavascript:[self removeBaseUrlFromUrl:url]];
        bq.baseURL = [self getOnlineBaseURL];
        
        if([Reachability isReachable])
        {
            [PxePlayerInterface checkBookmark:bq withCompletionHandler:handler];
        } else {
            [self checkBookmarkOnDevice:bq withCompletionHandler:handler];
        }
    }
}

-(void)editBookmarkWithTitle:(NSString*)bookmarkTitle andURL:(NSString*)url withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler
{
    // **** TEMPORARY DISABLE UNTIL OFFLINE SYNC ****
    if ([Reachability isReachable])
    {
        if(url)
        {
            PxePlayerBookmarkQuery* bq = [[PxePlayerBookmarkQuery alloc] init];
            bq.bookUUID = self.dataInterface.contextId;
            bq.authToken = self.currentPxePlayerUser.authToken;
            bq.userUUID = self.currentPxePlayerUser.identityId;
            bq.bookmarkTitle = bookmarkTitle;
            bq.uri = [self formatRelativePathForJavascript:[self removeBaseUrlFromUrl:url]];
            bq.baseURL = [self getOnlineBaseURL];
            
            [PxePlayerInterface editBookmark:bq withCompletionHandler:^(PxePlayerBookmark *bm, NSError *error) {
                if([self isDownloaded:self.dataInterface.contextId])
                {
                    [self editBookmarkOnDevice:bq withCompletionHandler:^(PxePlayerBookmark *bm, NSError *error)
                     {
                         if (handler)
                         {
                             handler(bm,error);
                         }
                     }];
                } else {
                    if (handler)
                    {
                        handler(bm,error);
                    }
                }
             }];
        }
    }
    else
    {
        // **** TEMPORARY DISABLE UNTIL OFFLINE SYNC ****
        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Editing bookmark not available while offline.", @"Editing bookmark not available while offline.")};
        NSError *error = [PxePlayerError errorForCode:PxePlayerNetworkUnreachable errorDetail:errorDict];
        handler(nil, error);
    }
}

-(void)deleteBookmarkWithURL:(NSString*)url withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler
{
    // **** TEMPORARY DISABLE UNTIL OFFLINE SYNC ****
    if ([Reachability isReachable])
    {
        if(url)
        {
            PxePlayerBookmarkQuery* bq = [[PxePlayerBookmarkQuery alloc] init];
            bq.bookUUID = self.dataInterface.contextId;
            bq.authToken = self.currentPxePlayerUser.authToken;
            bq.userUUID = self.currentPxePlayerUser.identityId;
            bq.uri = [self formatRelativePathForJavascript:[self removeBaseUrlFromUrl:url]];
            bq.baseURL = [self getOnlineBaseURL];
            
            [PxePlayerInterface deleteBookmark:bq withCompletionHandler:^(PxePlayerBookmark *bm, NSError *error) {
                [self dispatchGAIEventWithCategory:@"bookmark"
                                            action:@"deleteBookmark"
                                             label:bq.uri
                                             value:nil];
                
                if([self isDownloaded:self.dataInterface.contextId])
                {
                    [self deleteBookmarkOnDevice:bq withCompletionHandler:^(PxePlayerBookmark *bm, NSError *error) {
                        if (handler)
                        {
                            handler(bm,error);
                        }
                    }];
                } else {
                    if (handler)
                    {
                        handler(bm,error);
                    }
                }
            }];
        }
    }
    else
    {
        // **** NEED THIS UNTIL OFFLINE SYNC ****
        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Deleting bookmark not available while offline.", @"Deleting bookmark not available while offline.")};
        NSError *error = [PxePlayerError errorForCode:PxePlayerNetworkUnreachable errorDetail:errorDict];
        handler(nil, error);
    }
}

- (void) refreshBookmarksOnDeviceWithCompletionHandler:(void (^)(PxePlayerBookmarks *, NSError *))handler
{
    if([self deleteAllBookmarksForCurrentBook])
    {
        [self getBookmarksWithCompletionHandler:handler];
    }
}

@end

#pragma mark - Search

@implementation PxePlayer (Search)

- (void) submitTOCUrlForIndexingWithCompletionHandler:(void (^)(NSString*, NSError*))handler
{
    // If the indexId exists (submitted by client app)
    if (self.dataInterface.indexId)
    {
        handler(self.dataInterface.indexId, nil);
        return;
    }
    if(![Reachability isReachable])
    {
        handler(nil, [PxePlayerError errorForCode:PxePlayerNetworkUnreachable]);
        return;
    }
    DLog(@"dataInterface.indexId: %@", self.dataInterface.indexId);
#ifdef DEBUG
    [self markLoadTime:@"START - Submitting TOC for Indexing"];
#endif
    //Always has to be online TOC path
    NSString *tocURL;
    
    NSString *tocPath = self.dataInterface.tocPath;
    // Is it a toc.xhtml or toc.ncx?
    if ([tocPath rangeOfString:@"toc.ncx"].location != NSNotFound)
    {
        // Strip leading / from tocPath if it exist
        if ([[tocPath substringToIndex:1] isEqualToString:@"/"] )
        {
            tocPath = [tocPath substringFromIndex:1];
        }
        DLog(@"tocPath: %@", tocPath);
        tocURL = [NSString stringWithFormat:@"%@%@", [self getOnlineBaseURL], tocPath];
    }
    else
    {
        // ASSUMING that the toc path is the full toc.xhtml
        tocURL = tocPath;
    }
    DLog(@"tocURL: %@", tocURL);
    tocURL = [tocURL stringByReplacingOccurrencesOfString: @"http:/" withString:@"https:/"];
    
    PxePlayerSearchNCXQuery *query = [[PxePlayerSearchNCXQuery alloc] init];
    query.authToken = self.currentPxePlayerUser.authToken;
    query.indexContent = YES;
    query.urls = @[tocURL];
    query.userUUID = self.currentPxePlayerUser.identityId;
    
    [PxePlayerInterface submitTOCUrlForIndexing:query withCompletionHandler:handler];
}

-(void)submitUrlsForIndexing:(NSArray*)urls withCompletionHandler:(void (^)(NSString*, NSError*))handler
{
    //for now if they try this offline disallow
    if(![Reachability isReachable])
    {
        handler(nil, [PxePlayerError errorForCode:PxePlayerNetworkUnreachable]);
        return;
    }
    
    if (! urls || [urls count] == 0)
    {
        handler(nil, [PxePlayerError errorForCode:PxePlayerImproperInput]);
        return;
    }
    
    PxePlayerSearchURLsQuery *sq = [[PxePlayerSearchURLsQuery alloc] init];
    sq.contentURLs = urls;
    sq.authToken = self.currentPxePlayerUser.authToken;
    sq.userUUID = self.currentPxePlayerUser.identityId;
    
    [PxePlayerInterface submitUrlsForIndexing:sq withCompletionHandler:handler];
}

- (void) searchContent:(NSString*)searchTerm
                  from:(NSInteger)resultStartOffset
              withSize:(NSInteger)numberOfResults
 withCompletionHandler:(void (^)(PxePlayerSearchPages*, NSError*))handler
{
    DLog(@"searchTerm: %@", searchTerm);
    DLog(@"identityId: %@", self.dataInterface.identityId);
    DLog(@"indexId: %@", self.dataInterface.indexId );
    //for now if they try this offline disallow
    if(![Reachability isReachable])
    {
        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Search not available offline.", @"Search not available offline.")};
        NSError *error = [PxePlayerError errorForCode:PxePlayerNetworkUnreachable errorDetail:errorDict];
        handler(nil, error);
        return;
    }
    
    if (self.dataInterface.indexId == nil)
    {
        NSString *indexId = [self getIndexIdOnDevice];
        NSLog(@"indexId: %@", indexId);
        if (! indexId)
        {
            self.dataInterface.indexId = indexId;
        }
        else
        {
            [self submitTOCUrlForIndexingWithCompletionHandler:^(NSString *indexId, NSError *err)
             {
                 if(!err)
                 {
                     DLog(@"indexId: %@", indexId);
                     self.dataInterface.indexId = indexId;
                     
                     PxePlayerSearchBookQuery *sq = [[PxePlayerSearchBookQuery alloc] init];
                     sq.bookId = self.dataInterface.contextId;
                     sq.authToken = self.currentPxePlayerUser.authToken;
                     sq.userUUID = self.currentPxePlayerUser.identityId;
                     sq.indexId = self.dataInterface.indexId;
                     sq.pageNumber = resultStartOffset;
                     sq.maxResults = numberOfResults;
                     sq.searchTerm = searchTerm;
                     
                     [PxePlayerInterface searchContentInBook:sq withCompletionHandler:handler];
                 }
                 else
                 {
                     self.dataInterface.indexId = nil;
                     NSError *error = [PxePlayerError errorForCode:PxePlayerSearchNotInitialized];
                     handler(nil, error);
                     return;
                 }
             }];
        }
    }
    
    PxePlayerSearchBookQuery *sq = [[PxePlayerSearchBookQuery alloc] init];
    sq.bookId = self.dataInterface.contextId;
    sq.authToken = self.currentPxePlayerUser.authToken;
    sq.userUUID = self.currentPxePlayerUser.identityId;
    sq.indexId = self.dataInterface.indexId;
    sq.pageNumber = resultStartOffset;
    sq.maxResults = numberOfResults;
    sq.searchTerm = searchTerm;
    
    [PxePlayerInterface searchContentInBook:sq withCompletionHandler:handler];
    
    [self dispatchGAIEventWithCategory:@"search"
                                action:@"submit"
                                 label:searchTerm
                                 value:nil];
}

- (NSString *) getIndexIdOnDevice
{
    NSString *indexId = nil;
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSPredicate *contextPredicate = [NSPredicate predicateWithFormat:@"context_id == %@", self.dataInterface.contextId];
    
    NSArray *fetchedIndex = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeContext class])
                                                   withSortKey:@"context_id"
                                                     ascending:YES
                                                 withPredicate:contextPredicate
                                                    fetchLimit:NO
                                                    resultType:NSManagedObjectResultType];
    if (fetchedIndex)
    {
        if ([fetchedIndex count] > 0)
        {
            indexId = fetchedIndex[0];
        }
    }
    
    return indexId;
}

@end

#pragma mark - Annotations

@implementation PxePlayer (Annotations)

#pragma mark - Annotations - Online
- (void) getAnnotationsWithCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    DLog(@">>>>>>>>>>GETANNOTATIONS<<<<<<<<<<")
    if([Reachability isReachable])
    {
        DLog(@">>>>>>>>>>REACHABLE<<<<<<<<<<");
        PxePlayerNavigationsQuery *query = [[PxePlayerNavigationsQuery alloc] init];
        query.bookUUID = self.dataInterface.contextId;
        query.authToken = self.currentPxePlayerUser.authToken;
        query.userUUID = self.currentPxePlayerUser.identityId;
        
        //put this in a thread
        [PxePlayerInterface getAnnotationsForContext:query withCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error) {
            [self addAnnotationsToDevice:annotationsTypes withCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error)
                  {
                      if (handler)
                      {
                          handler(annotationsTypes,error);
                      }
                  }];
             }];
    }
    else
    {
        DLog(@"Got to read ANNOTATIONS!");
        //get it out of the DB
        [self readAnnotationsOnDeviceWithCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error) {
            //now toss it back up
            if(handler)
            {
                handler(annotationsTypes, error);
            }
        }];
    }
}

- (void) getAnnotationsForPage:(NSString*)pageURI withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler
{
    [self getAnnotationsTypesOnDeviceForContextId:self.dataInterface.contextId
                                       forPageURI:pageURI
                            withCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error) {
                                //now toss it back up
                                if (handler)
                                {
                                    handler(annotationsTypes, error);
                                }
                            }];
}

- (void) getAnnotationsForContent:(NSString* )contentID withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler
{
    PxePlayerContentAnnotationsQuery *query = [[PxePlayerContentAnnotationsQuery alloc] init];
    query.bookUUID = self.dataInterface.contextId;
    query.authToken = self.currentPxePlayerUser.authToken;
    query.userUUID = self.currentPxePlayerUser.identityId;
    query.contentID = contentID;
    
    [PxePlayerInterface getAnnotationsForContent:query withCompletionHandler:handler];
}

- (void) addAnnotationsArray:(NSArray *)annotations
                forContentID:(NSString *)contentID
       withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    PxePlayerAddAnnotationQuery *query = [[PxePlayerAddAnnotationQuery alloc] init];
    query.bookUUID = self.dataInterface.contextId;
    query.authToken = self.currentPxePlayerUser.authToken;
    query.userUUID = self.currentPxePlayerUser.identityId;
    query.contentId = contentID;
    query.annotations = [NSMutableArray arrayWithArray:annotations];
    
    [PxePlayerInterface addAnnotation:query withCompletionHandler:handler];
}

-(void)updateAnnotations:(NSArray*)annotations forContentID:(NSString*)contentID withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler
{
    PxePlayerAddAnnotationQuery *query = [[PxePlayerAddAnnotationQuery alloc] init];
    query.bookUUID = self.dataInterface.contextId;
    query.authToken = self.currentPxePlayerUser.authToken;
    query.userUUID = self.currentPxePlayerUser.identityId;
    query.contentId = contentID;
    query.annotations = [NSMutableArray arrayWithArray:annotations];
    
    [PxePlayerInterface updateAnnotation:query withCompletionHandler:handler];
}

-(void)deleteAnnotationForContentID:(NSString*)contentID WithCompletionHandler:(void (^)(PxePlayerDeleteAnnotation*, NSError*))handler
{
    PxePlayerNoteDeleteQuery *query = [[PxePlayerNoteDeleteQuery alloc] init];
    query.bookUUID = self.dataInterface.contextId;
    query.authToken = self.currentPxePlayerUser.authToken;
    query.userUUID = self.currentPxePlayerUser.identityId;
    query.contentId = contentID;
    query.annotationDttm = @"";
    
    [PxePlayerInterface deleteAnnotation:query withCompletionHandler:handler];
}

- (void) refreshAnnotationsOnDeviceWithCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    if([self deleteAnnotationsOnDevice:nil])
    {
        [self getAnnotationsWithCompletionHandler:handler];
    }
}

#pragma mark - Annotations - Offline
- (void) addAnnotationsToDevice:(PxePlayerAnnotationsTypes *)annotationsTypes withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    [self addAnnotationsToDevice:annotationsTypes
                    forContextId:self.dataInterface.contextId
           withCompletionHandler:handler];
}

- (void) addAnnotationsToDevice:(PxePlayerAnnotationsTypes *)annotationsTypes
                   forContextId:(NSString*)contextId
          withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    DLog(@"annotationsTypes annotationsTypes annotationsTypes \n%@", annotationsTypes);
    // Take it off of the main thread but call the handler on main thread
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
//    dispatch_async(queue, ^{
        if (annotationsTypes.myAnnotations.contentsAnnotations)
        {
            NSError *addMyAnnotationsError;
            [self updateAnnotationsOnDevice:annotationsTypes.myAnnotations
                               forContextId:contextId
                                  withError:&addMyAnnotationsError];
            if(addMyAnnotationsError)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(nil,addMyAnnotationsError);
                });
                return;
            }
        }
        if ([annotationsTypes.sharedAnnotationsArray count] > 0)
        {
            for (PxePlayerAnnotations *annotations in annotationsTypes.sharedAnnotationsArray)
            {
                NSError *addSharedAnnotationsError;
                [self updateAnnotationsOnDevice:annotations
                                   forContextId:contextId
                                      withError:&addSharedAnnotationsError];
                if(addSharedAnnotationsError)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(nil,addSharedAnnotationsError);
                    });
                    return;
                }
            }
        }
//        dispatch_sync(dispatch_get_main_queue(), ^{
            handler(annotationsTypes, nil);
//        });
//    });
}

- (void) readAnnotationsOnDeviceWithCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler
{
    [self getAnnotationsTypesOnDeviceForContextId:self.dataInterface.contextId
                                       forPageURI:nil
                            withCompletionHandler:handler];
}

- (void) readAnnotationsOnDeviceForContextId:(NSString*)contextId
                       withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler
{
    [self getAnnotationsTypesOnDeviceForContextId:contextId
                                       forPageURI:nil
                            withCompletionHandler:handler];
}

- (BOOL) updateAnnotationsOnDevice:(PxePlayerAnnotations *)pxePlayerAnnotations
                      forContextId:(NSString*)contextId
                         withError:(NSError **) error
{
    BOOL didComplete = YES;
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSDictionary *updateAnnotationsDict = pxePlayerAnnotations.contentsAnnotations;
    DLog(@"updateAnnotationsDict: %@", updateAnnotationsDict);
    for (NSString *key in updateAnnotationsDict)
    {
        // First Insert/Update the Annotations Object if it doesn't exist
        NSPredicate *annotationsPredicate = [NSPredicate predicateWithFormat:@"contents_uri == %@", key];
        
        NSArray *annotationsResults = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeAnnotations class])
                                                             withSortKey:@"contents_uri"
                                                               ascending:YES
                                                           withPredicate:annotationsPredicate
                                                              fetchLimit:NO
                                                              resultType:NSManagedObjectResultType];
        
        if ([annotationsResults count] > 0)
        {
            // Annotations Exists
            PxeAnnotations *pxeAnnotations = [annotationsResults objectAtIndex:0];
            
            // Now Save individual Annotation managed objects
            NSArray *annotationArray = [updateAnnotationsDict objectForKey:key];
            
            for (PxePlayerAnnotation *pxePlayerAnnotation in annotationArray)
            {
                // Check if Annotation exists
                // Build MAIN 'AND' Predicate with little Predicates
                NSPredicate *predicateContentsURI = [NSPredicate predicateWithFormat:@"(annotations.contents_uri == %@)", key];
                NSPredicate *predicateSelectedText = [NSPredicate predicateWithFormat:@"(selected_text == %@)", pxePlayerAnnotation.selectedText];
                NSPredicate *predicateContextId = [NSPredicate predicateWithFormat:@"(annotations.context.context_id == %@)", pxeAnnotations.context.context_id];
                NSPredicate *predicateRange = [NSPredicate predicateWithFormat:@"(range == %@)", pxePlayerAnnotation.range];
                
                NSPredicate *annotationPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateContentsURI, predicateSelectedText, predicateContextId, predicateRange]];
                DLog(@"Predicate: %@", annotationPredicate);
                // Fetch Request
                NSArray *results = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeAnnotation class])
                                                          withSortKey:@"annotation_datetime"
                                                            ascending:YES
                                                        withPredicate:annotationPredicate
                                                           fetchLimit:1
                                                           resultType:NSManagedObjectResultType];
                DLog(@"results: %@", results);
                if([results count] > 0)
                {
                    // Update Existing Annotation
                    PxeAnnotation *pxeAnnotation = [results objectAtIndex:0];
                    pxeAnnotation.color_code = pxePlayerAnnotation.colorCode;
                    pxeAnnotation.content_id = pxePlayerAnnotation.contentId;
                    if (pxePlayerAnnotation.labels)
                    {
                        pxeAnnotation.labels = [pxePlayerAnnotation.labels componentsJoinedByString:@"_,_"];
                    }
                    pxeAnnotation.note_text = pxePlayerAnnotation.noteText;
                }
                else
                {
                    // Create New Annotation
                    [self insertNewAnnotationOnDeviceFromData:pxePlayerAnnotation
                                               forAnnotations:pxeAnnotations];
                }
            }
        }
        else
        {
            // Annotations Object doesn't exist so insert and insert all new annotation objects with it
            [self insertNewAnnotationsOnDevice:pxePlayerAnnotations
                                  forContextId:contextId];
        }
    }
    if(![dataManager save])
    {
        didComplete = NO;
        if (error != NULL)
        {
            NSError *underlyingError = [PxePlayerError errorForCode:PxePlayerPersistantDataError];
            NSDictionary * errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Unable to save Annotation Updates",@"Unable to save Annotation Updates"),
                                         NSUnderlyingErrorKey : underlyingError};
            
            *error = [[NSError alloc] initWithDomain:PxePlayerErrorDomain
                                                code:underlyingError.code
                                            userInfo:errorDict];
        }
    }
    
    return didComplete;
}

- (BOOL) deleteAnnotationsOnDevice:(PxePlayerAnnotations *)pxePlayerAnnotations
{
    BOOL didComplete = YES;
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *managedObjectContext = [dataManager getObjectContext];
    
    if (pxePlayerAnnotations)
    {
        NSDictionary *deleteAnnotationsDict = pxePlayerAnnotations.contentsAnnotations;
        for (NSString *key in deleteAnnotationsDict)
        {
            // Retrieve Annotations
            NSPredicate *uriPredicate = [NSPredicate predicateWithFormat:@"contents_uri == %@", key];
            NSPredicate *contextPredicate = [NSPredicate predicateWithFormat:@"context.context_id == %@", [self getCurrentContext]];
            NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"context.user.identity_id == %@", [self getIdentityID]];
            
            NSPredicate *annotationsPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[uriPredicate, contextPredicate, userPredicate]];
            
            NSArray *annotationsResults = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeAnnotations class])
                                                                 withSortKey:@"contents_uri"
                                                                   ascending:YES
                                                               withPredicate:annotationsPredicate
                                                                  fetchLimit:NO
                                                                  resultType:NSManagedObjectResultType];
            // Delete the first one
            [managedObjectContext deleteObject:[annotationsResults objectAtIndex:0]];
            
            if(![dataManager save])
            {
                didComplete = NO;
            }
        }
    }
    else
    {
        // Delete Everything
        DLog(@"DELETING EVERYTHING");
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([PxeAnnotations class])];
        fetchRequest.resultType = NSManagedObjectIDResultType;
        
        NSArray *objectIDs = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        for (NSManagedObjectID *objectID in objectIDs)
        {
            [managedObjectContext deleteObject:[managedObjectContext objectWithID:objectID]];
        }
        
        if(![dataManager save])
        {
            didComplete = NO;
        }
    }
    return didComplete;
}

/**
 
 */
- (BOOL) deleteAnnotationOnDeviceWithResult:(NSDictionary*)result withError:(NSError **)error
{
    DLog(@"result: %@", result);
    BOOL didComplete = YES;
    
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *managedObjectContext = [dataManager getObjectContext];
    
    //GET the Annotation
    NSPredicate *contextPredicate = [NSPredicate predicateWithFormat:@"annotations.context.context_id == %@", [result objectForKey:@"contextId"]];
    NSPredicate *uriPredicate = [NSPredicate predicateWithFormat:@"annotations.contents_uri == %@", [result objectForKey:@"uri"]];
    NSPredicate *identityPredicate = [NSPredicate predicateWithFormat:@"annotations.annotations_identity_id == %@", [result objectForKey:@"identityId"]];

    NSDate *dateStamp = [NSDate dateWithTimeIntervalSince1970:[[result objectForKey:@"annotationDttm"] doubleValue]];
    NSPredicate *dateStampPredicate = [NSPredicate predicateWithFormat:@"annotation_datetime == %@", dateStamp];
    
    NSPredicate *annotationPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[uriPredicate, contextPredicate, identityPredicate, dateStampPredicate]];

    NSArray *annotationResults = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeAnnotation class])
                                                        withSortKey:nil
                                                          ascending:YES
                                                      withPredicate:annotationPredicate
                                                         fetchLimit:NO
                                                         resultType:NSManagedObjectResultType];
    if ([annotationResults count] > 0)
    {
        for(PxeAnnotation *pxeAnnotation in annotationResults)
        {
            // Delete the first one
            [managedObjectContext deleteObject:pxeAnnotation];
            
            if(![dataManager save])
            {
                didComplete = NO;
                if (error != NULL)
                {
                    *error = [PxePlayerError errorForCode:PxePlayerParseError];
                }
            }
        }
    }
    
    if (error != NULL)
    {
        *error = [PxePlayerError errorForCode:PxePlayerParseError];
    }
    
    return didComplete;
}

- (BOOL) insertNewAnnotationsOnDeviceFromTypes:(PxePlayerAnnotationsTypes *)annotationsTypes
{
    if (annotationsTypes.myAnnotations)
    {
        if (! [self insertNewAnnotationsOnDevice:annotationsTypes.myAnnotations])
        {
            return NO;
        }
    }
    if (annotationsTypes.sharedAnnotationsArray)
    {
        for (PxePlayerAnnotations *sharedAnnotations in annotationsTypes.sharedAnnotationsArray)
        {
            if (! [self insertNewAnnotationsOnDevice:sharedAnnotations])
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL) insertNewAnnotationsOnDevice:(PxePlayerAnnotations *)pxePlayerAnnotations
{
    return [self insertNewAnnotationsOnDevice:pxePlayerAnnotations forContextId:self.dataInterface.contextId];
}

- (BOOL) insertNewAnnotationsOnDevice:(PxePlayerAnnotations *)pxePlayerAnnotations
                         forContextId:(NSString*)contextId
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *objectContext = [dataManager getObjectContext];
    
    NSDictionary* annotationsDict = pxePlayerAnnotations.contentsAnnotations;
    DLog(@"annotationsDict: %@", annotationsDict);
    for (NSString* key in annotationsDict)
    {
        PxeContext *context = [self getCurrentContextForContextId:contextId];
        
        PxeAnnotations *pxeAnnotations = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeAnnotations class])
                                                                       inManagedObjectContext:objectContext];
        
        pxeAnnotations.is_my_annotation = [NSNumber numberWithBool:pxePlayerAnnotations.isMyAnnotations];
        pxeAnnotations.contents_uri = key;
        pxeAnnotations.context = context;
        pxeAnnotations.annotations_identity_id = pxePlayerAnnotations.annotationsIdentityId;
        
        [context addAnnotations:[NSSet setWithObjects:pxeAnnotations, nil]];
        
        NSArray *annotationArray = [annotationsDict objectForKey:key];
        
        for (PxePlayerAnnotation *pxePlayerAnnotation in annotationArray)
        {
            [self insertNewAnnotationOnDeviceFromData:pxePlayerAnnotation
                                       forAnnotations:pxeAnnotations];
        }
        
        if(![dataManager save])
        {
            return NO;
        }
    }
    
    return YES;
}

- (PxeAnnotation *) insertNewAnnotationOnDeviceFromData:(PxePlayerAnnotation*)pxePlayerAnnotation
                                         forAnnotations:(PxeAnnotations *)pxeAnnotations
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *objectContext = [dataManager getObjectContext];
    
    PxeAnnotation *pxeAnnotation = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeAnnotation class])
                                                                 inManagedObjectContext:objectContext];
    
    NSDate *dateStamp = [NSDate dateWithTimeIntervalSince1970:[pxePlayerAnnotation.annotationDttm doubleValue]];
    pxeAnnotation.annotation_datetime  = dateStamp;
    pxeAnnotation.color_code           = pxePlayerAnnotation.colorCode;
    pxeAnnotation.is_mathml            = [NSNumber numberWithBool:pxePlayerAnnotation.isMathML];
    
    DLog(@"pxePlayerAnnotation.labels: %@", pxePlayerAnnotation.labels);
    if (pxePlayerAnnotation.labels)
    {
        pxeAnnotation.labels           = [pxePlayerAnnotation.labels componentsJoinedByString:@"_,_"]; // valueForKey:@"description"] ;
    }
    
    pxeAnnotation.note_text            = pxePlayerAnnotation.noteText;
    pxeAnnotation.selected_text        = pxePlayerAnnotation.selectedText;
    pxeAnnotation.range                = pxePlayerAnnotation.range;
    pxeAnnotation.shareable            = [NSNumber numberWithBool:pxePlayerAnnotation.shareable];
    
    pxeAnnotation.queued               = [NSNumber numberWithBool:NO];
    pxeAnnotation.marked_for_delete    = [NSNumber numberWithBool:NO];
    
    pxeAnnotation.annotations          = pxeAnnotations;
    
    [pxeAnnotations addAnnotation:[NSSet setWithObjects:pxeAnnotation, nil]];
    
    if(![dataManager save])
    {
        NSLog(@"Error saving annotations to device...");
        return nil;
    }
    
    return pxeAnnotation;
}

- (void) getAnnotationsTypesOnDeviceForContextId:(NSString*)contextId
                                      forPageURI:(NSString *)pageURI
                           withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    [self getAnnotationsTypesOnDeviceForPageURI:pageURI
                                      contextId:contextId
                                     identityId:self.currentUser.identityId
                          withCompletionHandler:handler];
}

- (void) getAnnotationsTypesOnDeviceForPageURI:(NSString *)pageURI
                                     contextId:(NSString *)contextId
                                    identityId:(NSString *)identityId
                         withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    DLog(@"pageURI: %@", pageURI);
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSPredicate *annotationPredicate;
    
    NSPredicate *identityPredicate = [NSPredicate predicateWithFormat:@"annotations.context.user.identity_id == %@", identityId];
    NSPredicate *contextPredicate = [NSPredicate predicateWithFormat:@"annotations.context.context_id == %@", contextId];
    if (pageURI)
    {
        NSPredicate *contentsPredicate = [NSPredicate predicateWithFormat:@"annotations.contents_uri == %@", pageURI];
        
        annotationPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[contextPredicate, identityPredicate, contentsPredicate]];
    }
    else
    {
        annotationPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[contextPredicate, identityPredicate]];
    }
    
    NSArray *fetchedAnnotations = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeAnnotation class])
                                                         withSortKey:@"annotations.context.context_id"
                                                           ascending:YES
                                                       withPredicate:annotationPredicate
                                                          fetchLimit:NO
                                                          resultType:NSManagedObjectResultType];
    if (fetchedAnnotations)
    {
        DLog(@"fetchedAnnotations: %@", fetchedAnnotations);
        PxePlayerAnnotationsTypes *annotationsTypes = [PxePlayerAnnotationsTypes new];
        
        // myContentsAnnotations
        PxePlayerAnnotations *myPxePlayerAnnotations = [PxePlayerAnnotations new];
        myPxePlayerAnnotations.isMyAnnotations = YES;
        myPxePlayerAnnotations.contextId = self.dataInterface.contextId;
        myPxePlayerAnnotations.annotationsIdentityId = self.currentPxePlayerUser.identityId;
        DLog(@"Identity ID: %@",self.currentPxePlayerUser.identityId );
        // sharedContentsAnnotations
        NSMutableArray *sharedPxePlayerAnnotationsArray = [NSMutableArray new];
        
        if(fetchedAnnotations.count > 0)
        {
            // Fill the Annotation Objects Annotation Dictionary with arrays of individual annotations
            for (PxeAnnotation *pxeAnnotation in fetchedAnnotations)
            {
                // Get array of PxePlayerAnnotation objects from the PxePlayerAnnotations object
                NSMutableArray *annotationsArray;
                if (pxeAnnotation.annotations.is_my_annotation)
                {
                    annotationsArray = [myPxePlayerAnnotations.contentsAnnotations objectForKey:pxeAnnotation.annotations.contents_uri];
                }
                else
                {
                    for (PxePlayerAnnotations *sharedPxePlayerAnnotations in sharedPxePlayerAnnotationsArray)
                    {
                        NSArray *contentsArray = [sharedPxePlayerAnnotations.contentsAnnotations objectForKey:pxeAnnotation.annotations.contents_uri];
                        if(contentsArray)
                        {
                            annotationsArray = [contentsArray mutableCopy];
                            break;
                        }
                    }
                }
                if (! annotationsArray)
                {
                    annotationsArray = [NSMutableArray new];
                }
                DLog(@"pxeAnnotation dttm: %@", [pxeAnnotation.annotation_datetime description]);
                DLog(@"pxeAnnotation.note_text: %@", pxeAnnotation.note_text);
                // Create the PxePlayerAnnotation object and add it to the array
                PxePlayerAnnotation *pxePlayerAnnotation  = [[PxePlayerAnnotation alloc] init];
                pxePlayerAnnotation.annotationDttm        = [NSString stringWithFormat:@"%.0f", [pxeAnnotation.annotation_datetime timeIntervalSince1970]];
                pxePlayerAnnotation.colorCode             = pxeAnnotation.color_code;
                pxePlayerAnnotation.contentId             = pxeAnnotation.content_id;
                pxePlayerAnnotation.isMathML              = [pxeAnnotation.is_mathml boolValue];
                pxePlayerAnnotation.labels                = [pxeAnnotation.labels componentsSeparatedByString:@"_,_"];
                pxePlayerAnnotation.noteText              = pxeAnnotation.note_text;
                pxePlayerAnnotation.range                 = pxeAnnotation.range;
                pxePlayerAnnotation.selectedText          = pxeAnnotation.selected_text;
                pxePlayerAnnotation.shareable             = [pxeAnnotation.shareable boolValue];
                pxePlayerAnnotation.uri                   = pxeAnnotation.annotations.contents_uri;
                
                DLog(@"pxePlayerAnnotation dttm: %@", pxePlayerAnnotation.noteText);
                DLog(@"pxePlayerAnnotation.note_text: %@", pxeAnnotation.note_text);
                [annotationsArray addObject:pxePlayerAnnotation];
                
                // Stick it back in to the PxePlayerAnnotations' contentsAnnotations dictionary
                if (pxeAnnotation.annotations.is_my_annotation)
                {
                    [myPxePlayerAnnotations.contentsAnnotations setObject:annotationsArray forKey:pxeAnnotation.annotations.contents_uri];
                }
                else
                {
                    PxePlayerAnnotations *sharedPxePlayerAnnotations;
                    for (PxePlayerAnnotations *sharedAnnotations in sharedPxePlayerAnnotationsArray)
                    {
                        NSArray *contentsArray = [sharedAnnotations.contentsAnnotations objectForKey:pxeAnnotation.annotations.contents_uri];
                        if (contentsArray)
                        {
                            [sharedAnnotations.contentsAnnotations setObject:annotationsArray forKey:pxeAnnotation.annotations.contents_uri];
                            sharedPxePlayerAnnotations = sharedAnnotations;
                            break;
                        }
                    }
                    if (sharedPxePlayerAnnotations)
                    {
                        [sharedPxePlayerAnnotationsArray addObject:sharedPxePlayerAnnotations];
                    }
                    else
                    {
                        sharedPxePlayerAnnotations = [PxePlayerAnnotations new];
                        sharedPxePlayerAnnotations.isMyAnnotations = NO;
                        sharedPxePlayerAnnotations.contextId = self.dataInterface.contextId;
                        sharedPxePlayerAnnotations.annotationsIdentityId = pxeAnnotation.annotations.annotations_identity_id;
                        
                        [sharedPxePlayerAnnotationsArray addObject:sharedPxePlayerAnnotations];
                    }
                }
            }
        }
        annotationsTypes.myAnnotations = myPxePlayerAnnotations;
        annotationsTypes.sharedAnnotationsArray = sharedPxePlayerAnnotationsArray;
        
        handler(annotationsTypes,nil);
    }
    else
    {
        handler(nil,[PxePlayerError errorForCode:PxePlayerParseError]);
    }
}

- (PxePlayerAnnotation *)getAnnotationOnDeviceForAnnotationData:(NSDictionary *)annotationData onPage:(NSString *)uri
{
    DLog(@"AnnotationData: %@", annotationData);
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSPredicate *identityPredicate = [NSPredicate predicateWithFormat:@"annotations.context.user.identity_id == %@", [self getIdentityID]];
    NSPredicate *contextPredicate = [NSPredicate predicateWithFormat:@"annotations.context.context_id == %@", [self getContextID]];
    NSPredicate *uriPredicate = [NSPredicate predicateWithFormat:@"annotations.contents_uri == %@", [self formatRelativePathForTOC:uri]];
    
//    Annotation Data
//    NSDate *dateStamp = [NSDate dateWithTimeIntervalSince1970:[[annotationData objectForKey:@"annotationDttm"] doubleValue]];
//    NSPredicate *dateStampPredicate = [NSPredicate predicateWithFormat:@"annotation_datetime == %@", dateStamp];

    NSDictionary *dataDict = (NSDictionary*)[annotationData objectForKey:@"data"];
    NSPredicate *rangePredicate = [NSPredicate predicateWithFormat:@"range == %@", [dataDict objectForKey:@"range"]];
    
    NSPredicate *selectedTextPredicate = [NSPredicate predicateWithFormat:@"selected_text == %@", [dataDict objectForKey:@"selectedText"]];
    
    NSArray *predicateArray = @[uriPredicate,
                                contextPredicate,
                                identityPredicate,
                                rangePredicate,
                                selectedTextPredicate];
   
    NSPredicate *annotationPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    
    DLog(@"annotationPredicate: %@", annotationPredicate);
    
    NSArray *fetchedAnnotation = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeAnnotation class])
                                                        withSortKey:@"annotations.context.context_id"
                                                          ascending:YES
                                                      withPredicate:annotationPredicate
                                                         fetchLimit:NO
                                                         resultType:NSManagedObjectResultType];
    DLog(@"fetchedAnnotations: %@", fetchedAnnotation);
    
    if ([fetchedAnnotation count] == 0)
    {
        return nil;
    }
    PxeAnnotation *pxeAnnotation = [fetchedAnnotation objectAtIndex:0];
    DLog(@"pxeAnnotation.note_text: %@", pxeAnnotation.note_text);
    PxePlayerAnnotation *pxePlayerAnnotation  = [[PxePlayerAnnotation alloc] init];
    pxePlayerAnnotation.annotationDttm        = [NSString stringWithFormat:@"%.0f", [pxeAnnotation.annotation_datetime timeIntervalSince1970]];
    pxePlayerAnnotation.colorCode             = pxeAnnotation.color_code;
    pxePlayerAnnotation.contentId             = pxeAnnotation.content_id;
    pxePlayerAnnotation.isMathML              = [pxeAnnotation.is_mathml boolValue];
    pxePlayerAnnotation.labels                = [pxeAnnotation.labels componentsSeparatedByString:@"_,_"];
    pxePlayerAnnotation.range                 = pxeAnnotation.range;
    pxePlayerAnnotation.selectedText          = pxeAnnotation.selected_text;
    pxePlayerAnnotation.shareable             = [pxeAnnotation.shareable boolValue];
    [pxePlayerAnnotation setDecodedNoteText:pxeAnnotation.note_text];
    DLog(@"pxePlayerAnnotation.noteText: %@", pxePlayerAnnotation.noteText);
    DLog(@"pxePlayerAnnotation: %@", pxePlayerAnnotation);
    return pxePlayerAnnotation;
}

@end


#pragma mark - Media
@implementation PxePlayer (Medias)

-(void)getMedia:(NSString*)type withCompletionHandler:(void (^)(NSArray*, NSError*))handler
{
    PxePlayerMediaQuery *query = [[PxePlayerMediaQuery alloc] init];
    query.bookUUID = self.dataInterface.contextId;
    query.authToken = self.currentPxePlayerUser.authToken;
    query.userUUID = self.currentPxePlayerUser.identityId;
    query.mediaType = type;
    query.startIndex = -1;
    query.totalResult = 50;
    query.indexId = self.dataInterface.indexId;
    
    [PxePlayerInterface getMedia:query withCompletionHandler:handler];
}

@end
#pragma mark - Base URL Manipulation

@implementation PxePlayer (BaseURL)

// TODO: This might have to be eliminated since the base url is not always determined by the download.
// This might change when syncing is in place. For that we might always work with the local resources
// if the ePub has been downloaded
-(NSString*)getBaseURL
{
    //base url is relative to online or offline
    if([self isDownloaded:self.dataInterface.assetId])
    {
        DLog(@"PXEPLAYER THINKS IT'S DOWNLOADED: %@", self.dataInterface.assetId);
        if([Reachability isReachable])
        {
            return [self.dataInterface onlineBaseURL];
        }
        return [self.dataInterface offlineBaseURL]; //this is the path to the epub NOT the epub/OPS..
    }
    return [self.dataInterface onlineBaseURL]; //this is the path to the OPS usually
}

-(NSString*)getOnlineBaseURL
{
    //this is the path to the OPS usually but does not include the OPS
    DLog(@"contextId: %@", self.dataInterface.contextId);
    NSString *onBaseURL = self.dataInterface.onlineBaseURL;
    if (!onBaseURL || [onBaseURL isKindOfClass:[NSNull class]])
    {
        onBaseURL = [self getOnlineBaseURLFromTOCAbsoluteURL:self.dataInterface.tocPath];
        if (onBaseURL && ![onBaseURL isKindOfClass:[NSNull class]])
        {
            self.dataInterface.onlineBaseURL = onBaseURL;
        }
    }
    DLog(@"self.dataInterface.onlineBaseURL:%@", self.dataInterface.onlineBaseURL);
    return onBaseURL;
}

- (void) setOnlineBaseURL:(NSString *)baseURL forContextId:(NSString*)contextId
{
    if([self.dataInterface.contextId isEqualToString:contextId])
    {
        self.dataInterface.onlineBaseURL = baseURL;
        
        [[PxePlayerDataManager sharedInstance] updateContext:self.dataInterface.contextId
                                                   attribute:@"context_base_url"
                                                   withValue:baseURL];
    }
}

-(NSString*)getOfflineBaseURL
{
    //this is the path to the OPS usually but does not include the OPS
    return [self.dataInterface offlineBaseURL];
}

- (NSString*)removeBaseUrlFromUrl:(NSString *)url
{
    if([url rangeOfString:@"http:/"].location != NSNotFound || [url rangeOfString:@"https:/"].location != NSNotFound)
    {
        // Strip off http/https schemes because sometimes the service doesn't return properly (https)
        NSURL *urlURL = [NSURL URLWithString:url];
        if (urlURL)
        {
            url = [url stringByReplacingOccurrencesOfString:[urlURL scheme] withString:@""];
        }
        
        NSString *baseURLString = @"";
        NSURL *baseURL = [NSURL URLWithString:[self getOnlineBaseURL]];
        if (baseURL)
        {
            baseURLString = [[self getOnlineBaseURL] stringByReplacingOccurrencesOfString:[baseURL scheme] withString:@""];
            url = [url stringByReplacingOccurrencesOfString:baseURLString withString:@""];
        }
        
        // Make sure relative url does not begin with slash
        NSString *firstChar = [url substringToIndex:1];
        if ([firstChar isEqualToString:@"/"])
        {
            url = [NSString stringWithFormat:@"/%@", url];
        }
        DLog(@"onlineBaseURL: %@", baseURLString);
        DLog(@"url: %@", url);
    }
    else
    {
        NSString *baseURL = [self getOfflineBaseURL];
        if (baseURL)
        {
            url = [url stringByReplacingOccurrencesOfString:[self getOfflineBaseURL] withString:@""];
        }
        
        url = [url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    
    NSString *searchString;
    // Remove leading ":"
    searchString = [url substringToIndex:1];
    if ([searchString isEqualToString:@":"])
    {
        url = [url substringFromIndex:[searchString length]];
    }
    // Remove a leading "/"
    searchString = [url substringToIndex:1];
    if ([searchString isEqualToString:@"/"])
    {
        url = [url substringFromIndex:[searchString length]];
    }
//    // Remove leading OPS/ from url
//    NSString *ops = @"OPS/";
//    if ([url rangeOfString:ops].location != NSNotFound)
//    {
//        url = [url substringFromIndex:[ops length]];
//    }
    return url;
}

- (NSString*) prependBaseURL:(NSString*)url forOnline:(BOOL)online
{
    DLog(@"url incoming: %@...online: %@", url, online?@"YES":@"NO");
    BOOL urlNeedsScheme;
    NSString *baseURL;
    
    if (online)
    {
        urlNeedsScheme = ([url rangeOfString:@"http:/"].location == NSNotFound && [url rangeOfString:@"https:/"].location == NSNotFound);
        baseURL = [self getOnlineBaseURL];
        DLog(@"baseURL: %@", baseURL);
    }
    else
    {
        urlNeedsScheme = ([url rangeOfString:@"file:/"].location == NSNotFound);
        baseURL = [self getOfflineBaseURL];
    }
    
    if(urlNeedsScheme)
    {
        if([baseURL length] > 1)
        {
            // Remove slash at the end of base url
            if ([baseURL characterAtIndex:[baseURL length] -1] == '/')
            {
                baseURL = [baseURL substringToIndex:[baseURL length]-1];
            }
            
            // Remove Slash at beginning of relative path
            //TODO: This step shouldn't be necessary - BT 7/21/15
            if ([url characterAtIndex:0] == '/')
            {
                url = [url substringFromIndex:1];
            }
            
            // if relative path doesn't have "OPS" then concatenate with it
            if ([url rangeOfString:@"OPS"].location == NSNotFound) {
                url = [[baseURL stringByAppendingString:@"/OPS/"] stringByAppendingString:url];
            }
            else
            {
                url = [[baseURL stringByAppendingString:@"/"] stringByAppendingString:url];
            }
        }
    }
    DLog(@"url outgoing: %@", url);
    return url;
}

- (NSString *) formatRelativePathForJavascript:(NSString*)uri
{
    // Remove '/' at beginning of relative path uri
    if ([uri characterAtIndex:0] == '/')
    {
        uri = [uri substringFromIndex:1];
    }
    
    // Add leading "OPS/" to uri
    NSString *ops = @"OPS/";
    if ([uri rangeOfString:ops].location == NSNotFound)
    {
        uri = [NSString stringWithFormat:@"OPS/%@", uri];
    }
    
    return uri;
}

- (NSString *) formatRelativePathForTOC:(NSString *)uri
{
    // Remove a leading "/"
    if ([uri characterAtIndex:0] == '/')
    {
        if ([uri length] > 1)
        {
            uri = [uri substringFromIndex:1];
        }
    }
    
    NSString *ops = @"OPS/";
    NSRange opsRange = [uri rangeOfString:ops];
//    if ([self.dataInterface.tocPath rangeOfString:@"toc.ncx"].location != NSNotFound)
//    {
//        // Remove leading OPS/ from url for toc.ncx
//        // NOT ANYMORE? - 10/30/15
//        if (opsRange.location != NSNotFound)
//        {
//            uri = [uri substringFromIndex:(opsRange.location + opsRange.length)];
//        }
//    } else {
        // Remove everything up until the OPS for toc.xhtml
        if (opsRange.location != NSNotFound)
        {
            uri = [uri substringFromIndex:opsRange.location ];
        }
//    }
    
    return uri;
}

- (NSString *) getOnlineBaseURLFromTOCAbsoluteURL:(NSString*)tocURL
{
    NSString *onlineBaseURL = @"";
    DLog(@"tocURL: %@", tocURL);
    NSArray *splitURL = [tocURL componentsSeparatedByString:@"OPS/"];
    
    if ([splitURL count] > 1)
    {
        onlineBaseURL = [splitURL objectAtIndex:0];
    }
    
    return onlineBaseURL;
}

- (NSString*) forceSecureScheme:(NSString*)url
{
    url = [url stringByReplacingOccurrencesOfString: @"http:/" withString:@"https:/"];
    
    return url;
}

#pragma Mark Manifest and Manifest Items

-(void) retrieveManifestItemsForDataInterface:(PxePlayerDataInterface*)dataInterface
                         withCompletionHandler:(void (^)(PxePlayerManifest*, NSError*))completionHandler
{
    if (![self isTOCDownloadedForContext:dataInterface.contextId]) { //if no TOC yet - then download
        
        [self updateDataInterface:dataInterface onComplete:^(BOOL success, NSError *error) {
            if (success) {
                DLog(@"Successfully download TOC - will show chapters to download!");
                
                [self getManifestFromStoreForDataInterface:dataInterface withCompletionHandler:^(PxePlayerManifest *manifest, NSError *error) {
                    
                    completionHandler(manifest, error);
                }];
            }
            else
            {
                DLog(@"Failure downloading TOC");
                completionHandler(nil, error);
            }
        }];
    }
    else
    {
        [self getManifestFromStoreForDataInterface:dataInterface withCompletionHandler:^(PxePlayerManifest *manifest, NSError *error) {
            
            completionHandler(manifest, error);
        }];
    }
}



- (void) getManifestFromStoreForDataInterface:(PxePlayerDataInterface*)dataInterface
                  withCompletionHandler:(void (^)(PxePlayerManifest*, NSError*))completionHandler
{
    PxeManifest *dbManifest;
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSArray *manifests = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeManifest class])
                                                withSortKey:nil
                                                  ascending:NO
                                              withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", dataInterface.contextId]
                                                 fetchLimit:0
                                                 resultType:NSManagedObjectResultType];
    dbManifest = [manifests firstObject];
    
    if (!dbManifest)
    {
        completionHandler([self addBookToManifestFromDataInterface:dataInterface], [PxePlayerError errorForCode:PxePlayerNoManifestFoundInStore]);
        return;
    }
    
    PxePlayerManifest *manifest = [self translateManifestFromDBObject:dbManifest];
    manifest.contextId = dataInterface.contextId;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSArray *manifestItems = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeManifestChunk class])
                                                     withSortKey:nil
                                                       ascending:NO
                                                   withPredicate:[NSPredicate predicateWithFormat:@"manifest == %@", dbManifest]
                                                      fetchLimit:0
                                                      resultType:NSManagedObjectResultType];
    
    for (PxeManifestChunk *manifestItem in manifestItems)
    {
        [items addObject:[self translateManifestItemFromDBObject:manifestItem]];
    }
    
    manifest.items = items;
    
    completionHandler(manifest, nil);
}

- (PxePlayerManifest*) addBookToManifestFromDataInterface:(PxePlayerDataInterface*)dataInterface
{
    PxePlayerManifest *manifest = [PxePlayerManifest new];
    manifest.contextId = dataInterface.contextId;
    manifest.fullUrl = dataInterface.ePubURL;
    
    PxePlayerManifestItem *manifestItem = [PxePlayerManifestItem new];
    manifestItem.assetId = dataInterface.contextId;
    manifestItem.title = PXEPLAYER_BOOK_TITLE_AS_ASSET;
    manifestItem.fullUrl = dataInterface.ePubURL;
    
    manifest.items = [[NSArray alloc] initWithObjects:manifestItem, nil];
    
    return manifest;
}

-(PxePlayerManifest*) translateManifestFromDBObject:(PxeManifest*)dbManifest
{
    PxePlayerManifest *manifest = [PxePlayerManifest new];
    
    manifest.baseUrl = dbManifest.base_url;
    manifest.bookTitle = dbManifest.title;
    manifest.epubFileName = dbManifest.src;
    manifest.totalSize = dbManifest.total_size;
    manifest.fullUrl = [NSString stringWithFormat:@"%@%@",dbManifest.base_url,dbManifest.src];
    
    return  manifest;
}

-(PxePlayerManifestItem*) translateManifestItemFromDBObject:(PxeManifestChunk*)dbManifestItem
{
    PxePlayerManifestItem *manifestItem = [PxePlayerManifestItem new];
    
    manifestItem.baseUrl = dbManifestItem.base_url;
    manifestItem.epubFileName = dbManifestItem.src;
    manifestItem.title = dbManifestItem.title;
    manifestItem.size = dbManifestItem.size;
    manifestItem.assetId = dbManifestItem.chunk_id;
    manifestItem.isDownloaded = [dbManifestItem.is_downloaded boolValue];
    manifestItem.fullUrl = [NSString stringWithFormat:@"%@%@",dbManifestItem.base_url,dbManifestItem.src];
    
    return manifestItem;
}

@end
