//
//  PxePlayerDataFetcher.m
//  PxeReader
//
//  Created by Tomack, Barry on 8/18/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayerDataFetcher.h"
#import "PxePlayerDataInterface.h"
#import "PXEPlayerMacro.h"
#import "Reachability.h"
#import "PxePlayerError.h"
#import "PxePlayer.h"
#import "PxePlayerSearchNCXQuery.h"
#import "PxePlayerSearchURLsQuery.h"
#import "PxePlayerUser.h"
#import "PxePlayerInterface.h"
#import "PxePlayerTocParser.h"
#import "PxePlayerNCXCDParser.h"
#import "PxePlayerXHTMLParser.h"
#import "PxePlayerJSONCustomBasketParser.h"
#import "PxePlayerJSONTOCParser.h"
#import "PxePlayerManifestParser.h"
#import "PxeManifest.h"
#import "PxePlayerDataManager.h"
#import "PxePlayerMasterPlaylistParser.h"
#import "PxePlayerBookmarkQuery.h"
#import "PxeGlossary.h"

@interface PxePlayerDataFetcher ()

@property (nonatomic, strong) PxePlayerDataInterface *dataInterface;

@end

@implementation PxePlayerDataFetcher

- (instancetype) initWithDataInterface:(PxePlayerDataInterface *)dataInterface
{
    if(self = [super init])
    {
        [self storeDataInterface:dataInterface];
    }
    return self;
}

- (void) storeDataInterface:(PxePlayerDataInterface *)dataInterface
{
    self.dataInterface = dataInterface;
    
    PxePlayerUser * currUser = [[PxePlayer sharedInstance] createCurrentUserFromDataInterface:dataInterface];
    
    [[PxePlayerDataManager sharedInstance] createCurrentContextWithDataInterface:dataInterface
                                                                     currentUser:currUser
                                                                     withHandler:^(PxeContext *pxeContext, NSError *err){
                                                                         if (err)
                                                                         {
                                                                             //TODO: What to do if error creating context?
                                                                             DLog(@"ERROR UPDATING DATAINTERFACE: %@", err);
                                                                         }
                                                                     }];
}

- (void) fetchDataWithCompletionHandler:(void (^)(BOOL success, NSError *error))handler
{
    // Only retrieve if you're online
    if ([Reachability isReachable])
    {
        if (self.dataInterface.masterPlaylist)
        {
            [self retrievePlaylistWithDataInterface:self.dataInterface
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
            [self retrieveTOCWithDataInterface:self.dataInterface
                                  whenFinished:^(BOOL success) {
                                      NSError *err;
                                      if(!success)
                                      {
                                          err = [PxePlayerError errorForCode:PxePlayerTOCError];
                                      }
                                      if (handler)
                                      {
                                          handler(success, err);
                                      }
                                  }];
        }
    }
    else
    {
        NSArray *tocTree = [[PxePlayerDataManager sharedInstance] fetchTocTree:@"root"
                                                                  forContextId:self.dataInterface.contextId];
        NSError *err;
        BOOL inDB = NO;
        if ([tocTree count] > 0)
        {
            inDB = YES;
        }
        else
        {
            err = [PxePlayerError errorForCode:PxePlayerPlaylistError];
        }
        handler(inDB, err);
    }
}

- (void) retrieveTOCWithDataInterface:(PxePlayerDataInterface*)dInterface
                         whenFinished:(isSuccess)success
{
    DLog(@"Cache data: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    [self submitTOCUrlForIndexingWithCompletionHandler:^(NSString *indexId, NSError *err)
     {
         if(err)
         {
             self.dataInterface.indexId = nil;
         }
         else
         {
             DLog(@"indexID: %@", indexId);
             self.dataInterface.indexId = indexId;
             [[PxePlayerDataManager sharedInstance] updateContext:dInterface.contextId
                                                        attribute:@"search_index_id"
                                                        withValue:indexId];
         }
         
         // Get The TOC Parser
         BOOL useNCX = [dInterface.tocPath rangeOfString:@"toc.ncx"].location == NSNotFound?NO:YES;
         
         if (useNCX)
         {
             DLog(@"=======================================================================TOC.NCX");
             [self fetchNCXTOCAndWhenFinished:^(BOOL ncxSuccess)
              {
                  DLog(@"ncxSuccess: %@", ncxSuccess?@"YES":@"NO");
                  /** HACK ALERT - See PxePlayer*/
                  dInterface.tocPath = [dInterface.tocPath stringByReplacingOccurrencesOfString:@"toc.ncx"
                                                                                     withString:@"xhtml/toc.xhtml"];
                  [self fetchCustomBasketDataFromXHTMLWithDataInterface:self.dataInterface whenFinished:^(BOOL customBasketSuccess)
                   {
                       // Convert back to ncx from xhtml
                       dInterface.tocPath = [dInterface.tocPath stringByReplacingOccurrencesOfString:@"xhtml/toc.xhtml"
                                                                                          withString:@"toc.ncx"];
                       success(ncxSuccess);
                   }];
                  success(ncxSuccess);
              }];
         }
         else
         {
             DLog(@"=======================================================================TOC.XHTML");
             // First, check the TOC API
             // Second, check for the toc.xhtml file
             // Third, check if there's a toc.ncx
             [self fetchTOCDataFromTOCAPI:dInterface whenFinished:^(BOOL tocAPISuccess)
              {
                  DLog(@"tocAPISuccess: %@", tocAPISuccess?@"YES":@"NO");
                  if (tocAPISuccess)
                  {
                      [self fetchCustomBasketDataFromCustomTOCAPIWithDataInterface:self.dataInterface whenFinished:^(BOOL customBasketSuccess)
                       {
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
                               [self fetchCustomBasketDataFromXHTMLWithDataInterface:self.dataInterface whenFinished:^(BOOL customBasketSuccess)
                                {
                                    success(xhtmlSuccess);
                                }];
                           }
                           else
                           {
                               dInterface.tocPath = [dInterface.tocPath stringByReplacingOccurrencesOfString:@"xhtml/toc.xhtml"
                                                                                                  withString:@"toc.ncx"];
                               [self storeDataInterface:dInterface];
                               
                               [self fetchNCXTOCAndWhenFinished:^(BOOL ncxSuccess)
                                {
                                    success(ncxSuccess);
                                }];
                           }
                       }];
                  }
              }];
         }
     }];
}

- (void) retrievePlaylistWithDataInterface:(PxePlayerDataInterface*)dInterface
                              whenFinished:(isSuccess)success
{
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
     }];
}

- (void) submitTOCUrlForIndexingWithCompletionHandler:(void (^)(NSString*, NSError*))handler
{
    if(![Reachability isReachable])
    {
        handler(nil, [PxePlayerError errorForCode:PxePlayerNetworkUnreachable]);
        return;
    }
    // If Client App has supplied the indexId, then don't bother trying to get a new one
    if (self.dataInterface.indexId)
    {
        handler(self.dataInterface.indexId, nil);
        return;
    }
    
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
        tocURL = [NSString stringWithFormat:@"%@%@", self.dataInterface.onlineBaseURL, tocPath];
    }
    else
    {
        //ASSUMING that the toc path is the full toc.xhtml
        tocURL = tocPath;
    }
    tocURL = [tocURL stringByReplacingOccurrencesOfString: @"http:/" withString:@"https:/"];
    
    PxePlayerUser *currentUser = [[PxePlayer sharedInstance] currentUser];
    
    PxePlayerSearchNCXQuery *query = [[PxePlayerSearchNCXQuery alloc] init];
    query.authToken = currentUser.authToken;
    query.indexContent = YES;
    query.urls = @[tocURL];
    query.userUUID = currentUser.identityId;
    
    [PxePlayerInterface submitTOCUrlForIndexing:query withCompletionHandler:handler];
}

- (void) submitUrlsForIndexing:(NSArray*)urls withCompletionHandler:(void (^)(NSString*, NSError*))handler
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
    PxePlayerUser *currentUser = [[PxePlayer sharedInstance] currentUser];
    
    PxePlayerSearchURLsQuery *sq = [[PxePlayerSearchURLsQuery alloc] init];
    sq.contentURLs = urls;
    sq.authToken = currentUser.authToken;
    sq.userUUID = currentUser.identityId;
    
    [PxePlayerInterface submitUrlsForIndexing:sq withCompletionHandler:handler];
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

- (void) fetchCustomBasketDataFromCustomTOCAPIWithDataInterface:(PxePlayerDataInterface*)dataInterface whenFinished:(isSuccess)success
{
    PxePlayerJSONCustomBasketParser *customBasketParser = [[PxePlayerJSONCustomBasketParser alloc] init];
    
    [customBasketParser parseCustomBasketDataFromDataInterface:dataInterface withHandler:^(id receivedNavigator, NSError *error)
     {
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

- (void) fetchCustomBasketDataFromXHTMLWithDataInterface:(PxePlayerDataInterface*)dataInterface whenFinished:(isSuccess)success
{
    PxePlayerJSONCustomBasketParser *customBasketParser = [[PxePlayerJSONCustomBasketParser alloc] init];
    
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

- (void) fetchTOCDataFromTOCAPI:(PxePlayerDataInterface*)dataInterface whenFinished:(isSuccess)success
{
    PxePlayerTocParser *tocParser = [[PxePlayerJSONTOCParser alloc] init];
    
    [tocParser parseTOCDataFromDataInterface:self.dataInterface
                                 withHandler:^(id receivedNavigator, NSError *error)
     {
         if(error)
         {
             success(NO);
         }
         else
         {
             if(receivedNavigator)
             {
                 [self storeManifestDataForDataInterface:dataInterface
                                             tocChapters:[self retrieveTOCLevelOneAsChapters:receivedNavigator]
                                       completionHandler:^(BOOL manifestSuccess) {
                                           if (manifestSuccess)
                                           {
                                               DLog(@"Success storing manifest and chunks!");
                                           }
                                       }];
                 success(YES);
             }
             else
             {
                 success(NO);
             }
         }
     }];
}

#pragma mark Manifest

- (void) storeManifestDataForDataInterface:(PxePlayerDataInterface*)dataInterface
                               tocChapters:(NSDictionary*)chapters
                         completionHandler:(void (^)(BOOL))success
{
    if ([self isManifestInStoreForBook:dataInterface.contextId])
    {
        success(YES);
        return;
    }
    
    NSString *manifestBaseUrl = [[PxePlayer sharedInstance]  getWebAPIEndpoint];
    if (!manifestBaseUrl || [manifestBaseUrl isEqualToString:@""])
    {
        DLog(@"Client did not provide manifest API base url");
        success(NO);
        return;
    }
    
    NSString *manifestApiUrl = [manifestBaseUrl stringByAppendingString:[NSString stringWithFormat:PXE_Manifest_API, dataInterface.contextId]];
    [PxePlayerInterface downloadManifestDataWithUrl:manifestApiUrl
                              withCompletionHandler:^(NSDictionary *manifestDict, NSError *error) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      
                                      if (!error)
                                      {
                                          PxePlayerManifestParser *manifestParser = [PxePlayerManifestParser new];
                                          [manifestParser parseManifestDataDictionary:manifestDict
                                                                        dataInterface:dataInterface
                                                                          tocChapters:(NSDictionary*)chapters
                                                                          withHandler:^(id result, NSError *error) {
                                                                              if (!result)
                                                                              {
                                                                                  DLog(@"ERROR - failed to insert manifest");
                                                                                  success(NO);
                                                                              }
                                                                              else
                                                                              {
                                                                                  success(YES);
                                                                              }
                                                                          }];
                                      }
                                      else
                                      {
                                          success(NO);
                                          DLog(@"Paper API found no manifest for this book.");
                                      }
                                  });
                              }];
}

- (NSDictionary*) retrieveTOCLevelOneAsChapters:(NSDictionary*)toc
{
    return [toc valueForKeyPath:@"toc.items"];
}

//TODO: This should be in DataManager
- (BOOL) isManifestInStoreForBook:(NSString*)contextId
{
    PxeManifest *dbManifest;
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    NSArray *manifests = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeManifest class])
                                                withSortKey:nil
                                                  ascending:NO
                                              withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", contextId]
                                                 fetchLimit:0
                                                 resultType:NSManagedObjectResultType];
    dbManifest = [manifests firstObject];
    
    if (!dbManifest)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark METADATA FETCHES

- (void) fetchBookmarksWithCompletionHandler:(void (^)(PxePlayerBookmarks*, NSError*))handler
{
    if([Reachability isReachable])
    {
        PxePlayerBookmarkQuery* bq = [[PxePlayerBookmarkQuery alloc] init];
        bq.bookUUID = self.dataInterface.contextId;
        bq.authToken = [[PxePlayer sharedInstance] getContentAuthToken];
        bq.userUUID = [[PxePlayer sharedInstance] getIdentityID];
        bq.baseURL = self.dataInterface.onlineBaseURL;
        bq.contextID = self.dataInterface.contextId;
        
        DLog(@"getBookmarks for url: %@", bq.baseURL);
        [PxePlayerInterface getBookmarks:bq withCompletionHandler:^(PxePlayerBookmarks *bookmarks, NSError *error) {
            [[PxePlayer sharedInstance] addBookmarksOnDevice:bookmarks.bookmarks withDataInterface:self.dataInterface];
            if (handler)
            {
                handler(bookmarks, error);
            }
        }];
    } else {
        //get it out of the DB
        [[PxePlayer sharedInstance] getBookmarksOnDevice:^(PxePlayerBookmarks *bookmarks, NSError *error) {
            //now toss it back up
            if (handler)
            {
                handler(bookmarks, error);
            }
        }];
    }
}

- (void) fetchGlossaryWithCompletionHandler:(void (^)(NSArray*, NSError*))handler
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    DLog(@"contextId: %@", self.dataInterface.contextId);
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
                handler([[PxePlayer sharedInstance] parseGlossaryManagedData:glossaryTerms],nil);
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
    else
    { //go get it
        if (self.dataInterface.indexId)
        {
            if([Reachability isReachable])
            {
                NSDictionary *query = @{@"indexId":self.dataInterface.indexId};
                DLog(@"Let's go get some Glossary Terms query: %@", query);
                [PxePlayerInterface downloadGlossary:query withCompletionHandler:^(id glossaryTerms, NSError *error) {
                    
                    if ([glossaryTerms count] > 0)
                    {
                        DLog(@"got a lot of glossary terms %lu", (unsigned long)[glossaryTerms count]);
                        [[PxePlayer sharedInstance] insertGlossaryItems:glossaryTerms
                                                      withDataInterface: self.dataInterface];
                    }
                    if (handler)
                    {
                        handler(glossaryTerms,error);
                    }
                }];
            }
            else
            {
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

- (void) fetchAnnotationsWithCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    if([Reachability isReachable])
    {
        PxePlayerNavigationsQuery *query = [[PxePlayerNavigationsQuery alloc] init];
        query.bookUUID = self.dataInterface.contextId;
        query.authToken = [[PxePlayer sharedInstance] getContentAuthToken];
        query.userUUID = [[PxePlayer sharedInstance] getIdentityID];
        
        [PxePlayerInterface getAnnotationsForContext:query
                               withCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error) {
                                    [[PxePlayer sharedInstance] addAnnotationsToDevice:annotationsTypes
                                                                          forContextId:self.dataInterface.contextId
                                                                 withCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error){
                                         if (handler)
                                         {
                                             handler(annotationsTypes,error);
                                         }
                                     }];
                                }];
    }
    else
    {
        //get it out of the DB
        [[PxePlayer sharedInstance] readAnnotationsOnDeviceForContextId:self.dataInterface.contextId
                                                  withCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error) {
            if(handler)
            {
                handler(annotationsTypes, error);
            }
        }];
    }
}

@end
