//
//  NTInterface.m
//  NTApi
//
//  Created by Satyanarayana on 6/28/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerInterface.h"
#import "PxePlayerRestConnector.h"
#import "PxePlayerQueryParser.h"
#import "PxePlayerParser.h"
#import "PxePlayerUser.h"
#import "PxePlayerTocQuery.h"
#import "PxePlayerToc.h"
#import "PxePlayerBookQuery.h"
#import "PxePlayerBookShelf.h"
#import "PxePlayerChaptersQuery.h"
#import "PxePlayerChapters.h"
#import "PxePlayerBookmarkQuery.h"
#import "PxePlayerBookmark.h"
#import "PxePlayerCheckBookmark.h"
#import "PxePlayerNotes.h"
#import "PxePlayerAnnotationsQuery.h"
#import "PxePlayerContentAnnotationsQuery.h"
#import "PxePlayerAnnotations.h"
#import "PxePlayerAnnotationsTypes.h"
#import "PxePlayerAddAnnotationQuery.h"
#import "PxePlayerDeleteAnnotation.h"
#import "PxePlayerNoteDeleteQuery.h"
#import "PxePlayerSearchBookQuery.h"
#import "PxePlayerSearchURLsQuery.h"
#import "PxePlayerNavigationsQuery.h"
#import "PxePlayerMediaQuery.h"
#import "PxePlayerPagesQuery.h"
#import "PxePlayerPage.h"
#import "PxePlayer.h"
#import "PxePlayerSearchPages.h"
#import "PxePlayerError.h"
#import "PXEPlayerMacro.h"
#import "PXEPlayerEnvironment.h"
#import "Reachability.h"
#import "PxePlayerDownloadManager.h"
#import "PxePlayerBookmarks.h"
#import "NSString+Extension.h"

NSTimeInterval const NetworkRequestTimeout = 10.0;

@implementation PxePlayerInterface

+(void)getTOC:(PxePlayerTocQuery*)query withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_BookTOC_API, query.bookUUID];
    
    NSDictionary *params = [PxePlayerQueryParser parseTOCQuery:query];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Get completionHandler:^(id receivedObj, NSError *error) {
        PxePlayerToc *toc = nil;
        if(!error)
        {
            toc = [PxePlayerParser parseTOC:receivedObj];
        }
        if (handler)
        {
            handler(toc,error);
        }
    }];
}

+(void)getBookShelf:(PxePlayerBookQuery*)query withCompletionHandler:(void (^)(PxePlayerBookShelf*, NSError*)) handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_Bookshelf_API, query.userUUID];
    
    NSDictionary *params = [PxePlayerQueryParser parseBookShelfQuery:query];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Get completionHandler:^(id receivedObj, NSError *error)
     {
         PxePlayerBookShelf* bookShelf = nil;
         if(!error) {
             bookShelf = [PxePlayerParser parseBookShelf:receivedObj];
         }
         if (handler)
         {
             handler(bookShelf, error);
         }
     }];
}

+(void)getChapters:(PxePlayerChaptersQuery*)query withCompletionHandler:(void (^)(PxePlayerChapters*, NSError*))handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_BookChapters_API, query.bookUUID];
    
    NSDictionary *params = [PxePlayerQueryParser parseChaptersQuery:query];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Get completionHandler:^(id receivedObj, NSError *error)
     {
         PxePlayerChapters *chapters = nil;
         if(!error) {
             chapters = [PxePlayerParser parseChapter:receivedObj];
         }
         if (handler)
         {
             handler(chapters, error);
         }
     }];
}
#pragma mark - Glossary

+(void)getGlossary:(NSString*)apiURL withCompletionHandler:(void (^)(id, NSError*))handler
{
    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Method has been deprecated. Use downloadGlossary:withCompletionHandler:", @"Method has been deprecated. Use downloadGlossary:withCompletionHandler:")};
    
    NSError *error = [PxePlayerError errorForCode:PxePlayerGeneralError errorDetail:errorDictionary];
    
    if(error){
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey:NSLocalizedString(@"No Glossary items found.", nil)};
        error = [PxePlayerError errorForCode:PxePlayerGeneralError errorDetail:errorDictionary];
    }
    
    if (handler)
    {
        handler(nil, error);
    }
}

+ (void) downloadGlossary:(NSDictionary*)query withCompletionHandler:(void (^)(id, NSError*))handler
{
    NSString *apiURL = [NSString stringWithFormat:PXE_Glossary_API, [[PxePlayer sharedInstance] getSearchServerEndpoint], query[@"indexId"]];
    DLog(@"apiURL: %@", apiURL);
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:@{} method:PXE_Get completionHandler:^(id receivedObj, NSError *error) {
        
        if(!error)
        {
            NSArray *glossaryArray = [PxePlayerParser parseGlossary:receivedObj];
            if (handler)
            {
                handler(glossaryArray, error);
            }
        }
    }];
}

#pragma mark - Bookmarks
+ (void) getBookmarks:(PxePlayerNavigationsQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmarks*, NSError*))handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_Bookmarks_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID];
    
    NSDictionary *params = [PxePlayerQueryParser parseBookmarkQuery:query];
    //    DLog(@"URL: %@",apiURL);
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Get completionHandler:^(id receivedObj, NSError *error) {
        PxePlayerBookmarks *bookmarks = nil;
        if(!error)
        {
            DLog(@"receivedObj: %@", receivedObj);
            bookmarks = [PxePlayerParser parseBookmark:receivedObj];
            for (PxePlayerBookmark *bookMark in bookmarks.bookmarks)
            {
                bookMark.uri = [[PxePlayer sharedInstance] formatRelativePathForJavascript:bookMark.uri];
            }
        }else{
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey:NSLocalizedString(@"No Bookmark items found.", nil)};
            error = [PxePlayerError errorForCode:PxePlayerGeneralError errorDetail:errorDictionary];
        }
        
        if (handler)
        {
            handler(bookmarks, error);
        }
    }];
}

+ (void) addBulkBookmark:(NSArray*)queries withCompletionHandler:(void (^)(NSArray*, NSError*))handler{
    
    NSString* apiURL = [NSString stringWithFormat:PXE_AddBulkBookmarks_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint]];
    NSDictionary *params = [PxePlayerQueryParser parseAddBulkBookmarkQuery:queries];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL
                                      withParams:params
                                          method:PXE_Post
                               completionHandler:^(id receivedObj, NSError *error) {
                                   NSArray *addBookmarks = nil;
                                   if(!error)
                                   {
                                       addBookmarks = [PxePlayerParser parseBulkAddBookmark:receivedObj];
                                       for (PxePlayerBookmark *bookMark in addBookmarks)
                                       {
                                           bookMark.uri = [[PxePlayer sharedInstance] formatRelativePathForTOC:bookMark.uri];
                                       }
                                   }
                                   
                                   if (handler)
                                   {
                                       handler(addBookmarks, error);
                                   }
                               }];
}

+ (void) addBookmark:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_AddBookmarks_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID];
    //    DLog(@"url: %@", apiURL);
    NSDictionary *params = [PxePlayerQueryParser parseAddBookmarkQuery:query];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL
                                      withParams:params
                                          method:PXE_Post
                               completionHandler:^(id receivedObj, NSError *error) {
                                   PxePlayerBookmark *addBookmark = nil;
                                   if(!error)
                                   {
                                       addBookmark = [PxePlayerParser parseAddBookmark:receivedObj];
                                       addBookmark.uri = [[PxePlayer sharedInstance] formatRelativePathForTOC:addBookmark.uri];
                                   }
                                   
                                   if (handler)
                                   {
                                       handler(addBookmark, error);
                                   }
                               }];
}

+(void)editBookmark:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_EditBookmark_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID];
    
    NSDictionary *params = [PxePlayerQueryParser parseAddBookmarkQuery:query];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Put completionHandler:^(id receivedObj, NSError *error) {
        PxePlayerBookmark *editBookmark = nil;
        if(!error)
        {
            editBookmark = [PxePlayerParser parseEditBookmark:receivedObj];
            editBookmark.uri = [[PxePlayer sharedInstance] formatRelativePathForTOC:editBookmark.uri];
        }
        if (handler)
        {
            handler(editBookmark, error);
        }
    }];
}

+(void)checkBookmark:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerCheckBookmark*, NSError*))handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_CheckBookmarks_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID, query.uri];
    DLog(@"outgoing query.uri: %@", query.uri);
    NSDictionary *params = [PxePlayerQueryParser parseBookmarkQuery:query];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Get completionHandler:^(id receivedObj, NSError *error) {
        __block PxePlayerCheckBookmark* bookmarkStatus = nil;
        if(!error)
        {
            bookmarkStatus = [PxePlayerParser isPageBookmarked:receivedObj];
            bookmarkStatus.forPageUrl = query.uri;
            DLog(@"incoming isBookmarked: %@ bookmarkStatus.forPageUrl: %@", bookmarkStatus.isBookmarked, bookmarkStatus.forPageUrl);
        }
        if (handler)
        {
            handler(bookmarkStatus, error);
        }
    }];
}

+ (void) deleteBookmark:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_DeleteBookmark_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID, query.uri];
    DLog(@"apiURL: %@", apiURL);
    NSDictionary *params = [PxePlayerQueryParser parseBookmarkQuery:query];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Delete completionHandler:^(id receivedObj, NSError *error) {
        PxePlayerBookmark *deleteBookmark = nil;
        if(!error)
        {
            deleteBookmark = [PxePlayerParser parseDeleteBookmark:receivedObj];
            deleteBookmark.uri = [[PxePlayer sharedInstance] formatRelativePathForTOC:deleteBookmark.uri];
        }
        if (handler)
        {
            handler(deleteBookmark, error);
        }
    }];
}

#pragma mark - Annotations

+ (void) getAnnotationsForContext:(PxePlayerNavigationsQuery *)query
            withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseNotesQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_GetAnnotations_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID, @"true"];
    DLog(@"apiURL: %@", apiURL);
    [PxePlayerRestConnector responseWithUrlAsync:apiURL
                                      withParams:params
                                          method:PXE_Get
                               completionHandler:^(id receivedObj, NSError *error)
    {
         PxePlayerAnnotationsTypes *annotationsTypes = [PxePlayerAnnotationsTypes new];
         if(!error)
         {
             DLog(@"receivedObject: %@", receivedObj);
             annotationsTypes = [PxePlayerParser parseAnnotations:receivedObj];
         }
         else{
             NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey:NSLocalizedString(@"No Annotations items found.", nil)};
             error = [PxePlayerError errorForCode:PxePlayerGeneralError errorDetail:errorDictionary];
         }
         if (handler)
         {
             handler(annotationsTypes, error);
         }
     }];
}

+ (void) getAnnotationsForContent:(PxePlayerContentAnnotationsQuery *)query
            withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseNotesQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_GetContentAnnotations_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID, query.contentID, @"false"];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL
                                      withParams:params
                                          method:PXE_Get
                               completionHandler:^(id receivedObj, NSError *error)
     {
         PxePlayerAnnotationsTypes *annotationsTypes = [PxePlayerAnnotationsTypes new];
         if(!error)
         {
             annotationsTypes = [PxePlayerParser parseAnnotations:receivedObj];
         }
         if (handler)
         {
             handler(annotationsTypes, error);
         }
     }];
}

+ (void) addAnnotation:(PxePlayerAddAnnotationQuery*)query withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseAddAnnotationQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_AddAnnotations_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL
                                      withParams:params
                                          method:PXE_Post
                               completionHandler:^(id receivedObj, NSError *error) {
                                   PxePlayerAnnotationsTypes *annotationsTypes = [PxePlayerAnnotationsTypes new];
                                   if(!error)
                                   {
                                       annotationsTypes = [PxePlayerParser parseAnnotations:receivedObj];
                                   }
                                   if (handler)
                                   {
                                       handler(annotationsTypes, error);
                                   }
                               }];
}

+ (void) updateAnnotation:(PxePlayerAddAnnotationQuery *)query withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseUpdateAnnotationQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_UpdateAnnotatons_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL
                                      withParams:params
                                          method:PXE_Put
                               completionHandler:^(id receivedObj, NSError *error) {
                                   PxePlayerAnnotationsTypes *annotationsTypes = [PxePlayerAnnotationsTypes new];
                                   if(!error)
                                   {
                                       annotationsTypes = [PxePlayerParser parseAnnotations:receivedObj];
                                   }
                                   if (handler)
                                   {
                                       handler(annotationsTypes, error);
                                   }
                               }];
}

+ (void) deleteAnnotation:(PxePlayerNoteDeleteQuery *)query withCompletionHandler:(void (^)(PxePlayerDeleteAnnotation *, NSError *))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseNotesQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_DeleteAnnotations_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], query.bookUUID, query.userUUID, query.contentId, query.annotationDttm];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL
                                      withParams:params
                                          method:PXE_Delete
                               completionHandler:^(id receivedObj, NSError *error) {
                                   PxePlayerDeleteAnnotation *notes = nil;
                                   if(!error){
                                       notes = [PxePlayerParser parseDeleteAnnotation:receivedObj];
                                   }
                                   if (handler)
                                   {
                                       handler(notes, error);
                                   }
                               }];
}

+(void)searchContentInBook:(PxePlayerSearchBookQuery*)query withCompletionHandler:(void (^)(PxePlayerSearchPages*, NSError*))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseSearchBookQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_SearchBookContent_API, [[PxePlayer sharedInstance] getSearchServerEndpoint], query.indexId, [query.searchTerm urlEncodeUsingEncoding:NSUTF8StringEncoding], (long)query.pageNumber, (long)query.maxResults];
    DLog(@"apiURL: %@", apiURL);
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Get completionHandler:^(id receivedObj, NSError *error) {
        PxePlayerSearchPages *results = nil;
        if(!error){
            DLog(@"receivedObj: %@", receivedObj);
            results = [PxePlayerParser parseBookSearch:receivedObj];
            DLog(@"results: %@", results);
            if (query.maxResults > 0) {
                results.totalPages = results.totalResults / query.maxResults + 1;
            } else {
                results.totalPages = 0;
            }
        }
        if (handler)
        {
            handler(results, error);
        }
    }];
}

+(void)submitTOCUrlForIndexing:(PxePlayerSearchNCXQuery*)query withCompletionHandler:(void (^)(NSString*, NSError*))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseInitSearchNCXQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_InitSearch_API,[[PxePlayer sharedInstance] getSearchServerEndpoint]];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Post completionHandler:^(id receivedObj, NSError *error) {
        NSString *results = nil;
        if(!error) {
            results = [(NSDictionary*)receivedObj objectForKey:@"indexId"];
        }
        if (handler)
        {
            handler(results, error);
        }
    }];
}

+(void)submitUrlsForIndexing:(PxePlayerSearchURLsQuery*)query withCompletionHandler:(void (^)(NSString*, NSError*))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseInitSearchURLsQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_InitSearch_API, [[PxePlayer sharedInstance] getSearchServerEndpoint]];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Post completionHandler:^(id receivedObj, NSError *error) {
        NSString *results = nil;
        if(!error){
            results = [(NSDictionary*)receivedObj objectForKey:@"indexId"];
        }
        if (handler)
        {
            handler(results, error);
        }
    }];
}

+(void)getMedia:(PxePlayerMediaQuery*)query withCompletionHandler:(void (^)(NSArray*, NSError*))handler
{
    NSDictionary *params = [PxePlayerQueryParser parseNavigationsQuery:query];
    
    NSString* apiURL = [NSString stringWithFormat:PXE_Media_API, [[PxePlayer sharedInstance] getSearchServerEndpoint], query.mediaType, query.indexId, (long)query.startIndex, (long)query.totalResult];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Get completionHandler:^(id receivedObj, NSError *error) {
        NSArray *results = nil;
        if(!error){
            results = [PxePlayerParser parseMedia:receivedObj];
        }
        if (handler)
        {
            handler(results, error);
        }
    }];
}

+(void)getCustomNavigation:(PxePlayerTocQuery*)query withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler
{
    NSString* apiURL = [NSString stringWithFormat:PXE_BookCustomNavigation_API, query.bookUUID];
    
    NSDictionary *params = [PxePlayerQueryParser parseTOCQuery:query];
    
    [PxePlayerRestConnector responseWithUrlAsync:apiURL withParams:params method:PXE_Get completionHandler:^(id receivedObj, NSError *error) {
        PxePlayerToc *toc = nil;
        if(!error)
        {
            toc = [PxePlayerParser parseTOC:receivedObj];
        }
        if (handler)
        {
            handler(toc,error);
        }
    }];
}

+(void)getMasterPlaylistToc:(NSArray *)masterPlaylist withCompletionHandler:(void (^)(PxePlayerToc *, NSError *))handler
{
    PxePlayerToc *toc;
    NSError *error = nil;
    
    toc = [[PxePlayerToc alloc] init];
    toc.tocEntries = masterPlaylist;
    
    if (handler)
    {
        handler(toc,error);
    }
}

+ (void) getTOCFromDataInterface:(PxePlayerDataInterface*)dataInterface
           withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler;
{
    DLog(@"tocURL: %@" , dataInterface.tocPath);
    [PxePlayerRestConnector responseWithDataInterfaceAsync:dataInterface
                           withCompletionHandler:^(id receivedObj, NSError *error)
     {
         //        DLog(@"receivedObj: %@", receivedObj);
         DLog(@"error: %@", error);
         if(!error)
         {
             if (receivedObj)
             {
                 NSDictionary *navPoints = nil;
                 PxePlayerToc  *toc = [[PxePlayerToc alloc] init];
                 
                 if([dataInterface.tocPath hasSuffix:@"ncx"])
                 { //old ncx
                     navPoints = receivedObj[@"ncx"][@"navMap"];
                 }
                 else
                 { //new xhtml
                     if (receivedObj[@"nav"])    
                     {
                         if ([receivedObj[@"nav"] isKindOfClass:[NSArray class]])
                         {
                             // At one time the nav object came in as an array
                             navPoints = receivedObj[@"nav"][0][@"ol"];
                             if(receivedObj[@"nav"][0][@"learning-objectives"])
                             {
                                 toc.customBaskets = [NSArray arrayWithObject:receivedObj[@"nav"][0][@"learning-objectives"]];
                             }
                         }
                         else
                         {
                             // The nav object can arrive as a dictionary...has no custom basket
                             navPoints = receivedObj[@"nav"][@"ol"];
                             if(receivedObj[@"nav"][@"learning-objectives"])
                             {
                                 toc.customBaskets = [NSArray arrayWithObject:receivedObj[@"nav"][@"learning-objectives"]];
                             }
                         }
                     }
                 }
                 if(navPoints)
                 {
                     toc.tocEntries = [NSArray arrayWithObject:navPoints];
                     if (handler)
                     {
                         handler(toc,error);
                     }
                 } else {
                     //                    DLog(@"No Good1: PxePlayerXMLParsingError");
                     if (handler)
                     {
                         handler(nil, [PxePlayerError errorForCode:PxePlayerXMLParsingError]);
                     }
                 }
             }
             else
             {
                 //                DLog(@"No Good2: PxePlayerXMLParsingError");
                 if (handler)
                 {
                     handler(nil, [PxePlayerError errorForCode:PxePlayerXMLParsingError]);
                 }
             }
         }
         else
         {
             // Received error from PxePlayerRestConnector
             DLog(@"Error: %@", error);
             if (handler)
             {
                 handler(nil, error);
             }
         }
     }];
}

+ (void) getCustomBasketDataFromDataInterface:(PxePlayerDataInterface*)dataInterface
                        withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler
{
    NSString* baseURL = dataInterface.onlineBaseURL;
    [[NSUserDefaults standardUserDefaults] setValue:baseURL forKey:PXE_Base_URL];
    
    [PxePlayerRestConnector responseWithDataInterfaceAsync:dataInterface
                                     withCompletionHandler:^(id receivedObj, NSError *error)
     {
         if(!error)
         {
             if (receivedObj)
             {
                 PxePlayerToc  *toc = [[PxePlayerToc alloc] init];
                 //                DLog(@"receivedObj: \n%@", receivedObj);
                 if ([receivedObj objectForKey:@"nav"])
                 {
                     if ([[receivedObj objectForKey:@"nav"] isKindOfClass:[NSArray class]])
                     {
                         // Sometimes the nav object came in as an array
                         //                        DLog(@"It's an array...go figure");
                         //                        DLog(@"Count: %lu", (unsigned long)[receivedObj[@"nav"] count]);
                         if (receivedObj[@"nav"][0][@"learning-objectives"])
                         {
                             toc.customBaskets = [NSArray arrayWithObject:receivedObj[@"nav"][0][@"learning-objectives"]];
                         }
                         else if (receivedObj[@"learning-objectives"])
                         {
                             toc.customBaskets = [NSArray arrayWithObject:receivedObj[@"learning-objectives"]];
                         }
                     }
                     else
                     {
                         // The nav object can arrive as a dictionary...has no "custom basket"
                         if(receivedObj[@"nav"][@"learning-objectives"])
                         {
                             toc.customBaskets = [NSArray arrayWithObject:receivedObj[@"nav"][@"learning-objectives"]];
                         }
                     }
                     //                    DLog(@"toc.customBaskets: %@", toc.customBaskets);
                     if (handler)
                     {
                         handler(toc,error);
                     }
                 }
             }
             else
             {
                 if (handler)
                 {
                     handler(nil, [PxePlayerError errorForCode:PxePlayerXMLParsingError]);
                 }
             }
         }
         else
         {
             if (handler)
             {
                 handler(nil, error);
             }
         }
     }];
}

+ (void) getCustomBasketDataFromAPIUsingDataInterface:(PxePlayerDataInterface*)dataInterface
                                withCompletionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    NSString *customBasketAPI = [NSString stringWithFormat: PXE_CustomBasketTOC_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], dataInterface.tocPath];
    DLog(@"customBasketAPI: %@", customBasketAPI);
    [PxePlayerRestConnector responseDataWithURLAsync:customBasketAPI withCompletionHandler:^(id receivedObj, NSError *error)
     {
         if(!error)
         {
             if (receivedObj)
             {
                 NSError* error;
                 NSDictionary *customBasket = [NSJSONSerialization JSONObjectWithData:receivedObj
                                                                              options:kNilOptions
                                                                                error:&error];
                 if (handler)
                 {
                     handler(customBasket, error);
                 }
             }
             else
             {
                 if (handler)
                 {
                     handler(nil, [PxePlayerError errorForCode:PxePlayerXMLParsingError]);
                 }
             }
         }
         else
         {
             if (handler)
             {
                 handler(nil, error);
             }
         }
     }];
}

+ (void) getTOCDataFromAPIUsingDataInterface:(PxePlayerDataInterface*)dataInterface
                       withCompletionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    NSString *printPageIndicator = ([dataInterface.tocPath rangeOfString:@"toc.xhtml"].location != NSNotFound) ? @"true" : @"false";
    
    NSString *removeDuplicates = [[PxePlayer sharedInstance] getRemoveDuplicatePagesForQueryString];
    // TODO: Allow for submission of the providerType so that epub is not hardcoded
    NSString *tocAPI = [NSString stringWithFormat: PXE_TOC_API, [[PxePlayer sharedInstance] getPxeServicesEndpoint], dataInterface.contextId, dataInterface.tocPath,@"epub", printPageIndicator, removeDuplicates];
    DLog(@"tocAPI: %@", tocAPI);
    NSDictionary * __block tocDict = [NSDictionary new];
    [PxePlayerRestConnector responseDataWithURLAsync:tocAPI withCompletionHandler:^(id receivedObj, NSError *error)
     {
         if(!error)
         {
             if (receivedObj)
             {
                 NSError* error;
                 tocDict = [NSJSONSerialization JSONObjectWithData:receivedObj
                                                           options:kNilOptions
                                                             error:&error];
                 //                 DLog(@"tocDict: %@", tocDict);
                 if (handler)
                 {
                     handler(tocDict, error);
                 }
             }
             else
             {
                 if (handler)
                 {
                     handler(nil, [PxePlayerError errorForCode:PxePlayerXMLParsingError]);
                 }
             }
         }
         else
         {
             if (handler)
             {
                 handler(nil, error);
             }
         }
     }];
}

-(NSString*) indicatePrintPageOptionForProviderUrl:(NSString*)providerUrl
{
    return ([providerUrl rangeOfString:@"toc.xhtml"].location != NSNotFound) ? @"true" : @"false";
}

+ (void) getTOCPage:(PxePlayerPagesQuery*)query
      dataInterface:(PxePlayerDataInterface*)dataInterface
  completionHandler:(void (^)(PxePlayerPage*, NSError*))handler
{
    //get it from service if not get it from downloaded
    PxePlayerPage *page = [[PxePlayerPage alloc] init];
    DLog(@"contextId: %@", [[PxePlayer sharedInstance] getAssetId]);

    if([Reachability isReachable])
    {
        NSString *apiURL = [[PxePlayer sharedInstance] prependBaseURL:query.pageUrl forOnline:YES];
        
        [PxePlayerRestConnector responseDataWithURLAsync:apiURL withCompletionHandler:^(id receivedObj, NSError *error)
         {
             if(!error) {
                 page.contentFile = [[NSString alloc] initWithData:receivedObj encoding:NSUTF8StringEncoding];
             }
             if (handler)
             {
                 handler(page,error);
             }
         }];
    } else {
        NSError *readError;
        NSString *rootURL = [[PxePlayer sharedInstance] prependBaseURL:query.pageUrl forOnline:NO];
        DLog(@"rootURL: %@", rootURL);
        NSData *pageData = [[PxePlayerDownloadManager sharedInstance] readPage:rootURL dataInterface:dataInterface error:&readError];
        if(!pageData || readError)
        {
            NSLog(@"ERROR: %@",readError);
        }
        page.contentFile = [[NSString alloc] initWithData:pageData encoding:NSUTF8StringEncoding];
        if (handler)
        {
            handler(page,nil);
        }
    }
}

+(void) downloadManifestDataWithUrl:(NSString*)url
              withCompletionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    NSURL *requestUrl = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:NetworkRequestTimeout];
    [request setHTTPMethod:PXE_Get];
    
    [PxePlayerRestConnector performNetworkCallWithRequest:request andCompletionHandler:^(id manifestData, NSError *error)
     {
         if (!error) {
             if (manifestData) {
                 NSError* error;
                 NSDictionary *manifestDict = [NSJSONSerialization JSONObjectWithData:manifestData
                                                                              options:kNilOptions
                                                                                error:&error];
                 if (handler) {
                     handler(manifestDict, nil);
                 }
             }
             else{
                 if (handler) {
                     handler(nil, [PxePlayerError errorForCode:PxePlayerManifestError]);
                 }
             }
         }
         else {
             handler(nil, error);
         }
     }];
}

@end
