//
//  NTInterface.h
//  NTApi
//
//  Created by Satyanarayana on 6/28/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerDataInterface.h"

@class PxePlayerUser;
@class PxePlayerToc;
@class PxePlayerTocQuery;
@class PxePlayerBookShelf;
@class PxePlayerChapters;
@class PxePlayerChaptersQuery;
@class PxePlayerPagesQuery;
@class PxePlayerPage;
@class PxePlayerBookQuery;
@class PxePlayerNavigationsQuery;
@class PxePlayerNavigation;
@class PxePlayerBookmarkQuery;
@class PxePlayerBookmarks;
@class PxePlayerBookmark;
@class PxePlayerNotes;
@class PxePlayerNotesQuery;
@class PxePlayerHighlights;
@class PxePlayerHighlightsQuery;
@class PxePlayerEditBookMarkQuery;
@class PxePlayerAnnotationsQuery;
@class PxePlayerAddNoteQuery;
@class PxePlayerNoteDeleteQuery;
@class PxePlayerAddHighlightQuery;
@class PxePlayerHighlightDeleteQuery;
@class PxePlayerAddBookmark;
@class PxePlayerDeleteBookmark;
@class PxePlayerEditBookmark;
@class PxePlayerSearchBookQuery;
@class PxePlayerSearchPages;
@class PxePlayerMediaType;
@class PxePlayerMediaQuery;
@class PxePlayerDeleteBookmarkQuery;
@class PxePlayerContentAnnotationsQuery;
@class PxePlayerCheckBookmark;
@class PxePlayerAddAnnotationQuery;
@class PxePlayerAnnotations;
@class PxePlayerAnnotationsTypes;
@class PxePlayerDeleteAnnotation;
@class PxePlayerSearchNCXQuery;
@class PxePlayerSearchURLsQuery;

@interface PxePlayerInterface : NSObject

/*
 @method             getTOC:withCompletionHandler:
 
 @abstract
                     Performs Retrieving Book's TOC request,
                     returning the formatted PxePlayerToc object.
 
 @discussion
                     This method initiates a request, identifies
                     the error status, and based on error status, it will
                     parse the json object received into appropriate
                     PxePlayerToc object and returns it.
                     
 @param
 query
 
                     
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
+(void)getTOC:(PxePlayerTocQuery*)query withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler;


/*
 @method             getBookShelf:withCompletionHandler:
 
 @abstract
                     Performs Get BookShelf request,
                     returning the formatted NTBookShelf object.
                     
 @discussion
                     This method initiates a request, identifies
                     the error status, and based on error status, it will
                     parse the json object received into appropriate
                     NTBookShelf object and returns it.
                     
 @param
 query
 
                     
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
+(void)getBookShelf:(PxePlayerBookQuery*)query withCompletionHandler:(void (^)(PxePlayerBookShelf*, NSError*)) handler;


/*
 @method             getChapters:withCompletionHandler:
 
 @abstract
                     Performs Retrieving Book's Chapters request,
                     returning the formatted PxePlayerChapter object.
                     
 @discussion
                     This method initiates a request, identifies
                     the error status, and based on error status, it will
                     parse the json object received into appropriate
                     PxePlayerChapter object and returns it.
                     
 @param
 query
 
                     
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
+(void)getChapters:(PxePlayerChaptersQuery*)query withCompletionHandler:(void (^)(PxePlayerChapters*, NSError*))handler;



/*
 @method             getBookmarks:withCompletionHandler:
 
 @abstract
                     Performs retrieving Bookmarks request,
                     returning the formatted PxePlayerBookmarks object.
 
 @discussion
                     This method initiates a request, identifies
                     the error status, and based on error status, it will
                     parse the json object received into appropriate
                     PxePlayerBookmarks object and returns it.
 
 @param
 query
 
 
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
+(void)getBookmarks:(PxePlayerNavigationsQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmarks*, NSError*))handler;


/*
 @method             addBookmark:withCompletionHandler:
 
 @abstract
                     Performs adding Bookmark request,
                     returning the formatted PxePlayerAddBookmark object.
 
 @discussion
                     This method initiates a request, identifies
                     the error status, and based on error status, it will
                     parse the json object received into appropriate
                     PxePlayerAddBookmark object and returns it.
 
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

+(void)addBookmark:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler;

/**
 *  Does a bulk bookmark add.
 *
 *  @param queries NSArray
 *  @param handler The completion handler block which will be executed when the data is received from the request sent.
 */
+(void)addBulkBookmark:(NSArray*)queries withCompletionHandler:(void (^)(NSArray*, NSError*))handler;

/*
 @method             deleteBookmark:withCompletionHandler:
 
 @abstract
                     Performs deleting a Bookmark request,
                     returning the formatted PxePlayerDeleteBookmark object.
 
 @discussion
                     This method initiates a request, identifies
                     the error status, and based on error status, it will
                     parse the json object received into appropriate
                     PxePlayerDeleteBookmark object and returns it.
 
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
+(void)deleteBookmark:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler;

/*
 @method             editBookmark:withCompletionHandler:
 
 @abstract
                     Performs editing a Bookmark request,
                     returning the formatted PxePlayerEditBookmark object.
 
 @discussion
                     This method initiates a request, identifies
                     the error status, and based on error status, it will
                     parse the json object received into appropriate
                     PxePlayerEditBookmark object and returns it.
 
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
+(void)editBookmark:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler;

/*
 @method  getAnnotationsForContext:withCompletionHandler:
 
 @abstract
 Performs retrieving all annotations
 returning the formatted PxePlayerNotes object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerNotes object and returns it.
 
 @param
 PxePlayerNavigationsQuery
 The api model to request.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 PxePlayerNotes
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
+ (void) getAnnotationsForContext:(PxePlayerNavigationsQuery *)query
            withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

/*
 @method  getAnnotationsForContent:withCompletionHandler:
 
 @abstract
 Performs retrieving all annotations
 returning the formatted PxePlayerNotes object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerNotes object and returns it.
 
 @param
 PxePlayerContentAnnotationsQuery
 The api model to request.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 PxePlayerNotes
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
+ (void) getAnnotationsForContent:(PxePlayerContentAnnotationsQuery *)query
            withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

/*
 @method  addAnnotation:withCompletionHandler:
 
 @abstract
 Performs retrieving all annotations
 returning the formatted PxePlayerAnnotations object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerNotes object and returns it.
 
 @param
 PxePlayerAddAnnotationQuery
 The api model to request.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 PxePlayerAnnotations
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
+(void)addAnnotation:(PxePlayerAddAnnotationQuery*)query withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;


/*
 @method  updateAnnotation:withCompletionHandler:
 
 @abstract
 Performs retrieving all annotations
 returning the formatted PxePlayerAnnotations object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerNotes object and returns it.
 
 @param
 PxePlayerAddAnnotationQuery
 The api model to request.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 PxePlayerAnnotations
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
+(void)updateAnnotation:(PxePlayerAddAnnotationQuery*)query withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;


/*
 @method  deleteAnnotation:withCompletionHandler:
 
 @abstract
 Performs retrieving all annotations
 returning the formatted PxePlayerDeleteAnnotation object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerNotes object and returns it.
 
 @param
 PxePlayerNoteDeleteQuery
 The api model to request.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 PxePlayerAnnotations
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
+(void)deleteAnnotation:(PxePlayerNoteDeleteQuery*)query withCompletionHandler:(void (^)(PxePlayerDeleteAnnotation*, NSError*))handler;


/*
 @method  searchContentInBook:withCompletionHandler:
 
 @abstract
 Performs retrieving Bookmarks request,
 returning the formatted PxePlayerBookmarks object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerBookmarks object and returns it.
 
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
+(void)searchContentInBook:(PxePlayerSearchBookQuery*)query withCompletionHandler:(void (^)(PxePlayerSearchPages*, NSError*))handler;


/*
 @method submitTOCUrlForIndexing:withCompletionHandler:
 
 @abstract
 Performs posting ncx url to retrieve search index id
 returning the search index id
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 search index id as a NSString object and returns it.
 
 @param
 PxePlayerSearchNCXQuery
 The api model to request. It wont expect the complete URL.
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
+(void)submitTOCUrlForIndexing:(PxePlayerSearchNCXQuery*)query withCompletionHandler:(void (^)(NSString*, NSError*))handler;


/*
 @method submitUrlsForIndexing:withCompletionHandler:
 
 @abstract
 Performs posting url's for indexing for initialising the searh cm
 returning the formatted PxePlayerBookmarks object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status.
 
 @param
 PxePlayerSearchURLsQuery
 The api model to request. It wont expect the complete URL.
 Only the last part of the URL is expected here. Inside
 the method it will prepare the full URL based on the
 WEBAPI_URL defined in URLConstants
 
 @param
 NSString
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
+(void)submitUrlsForIndexing:(PxePlayerSearchURLsQuery*)query withCompletionHandler:(void (^)(NSString*, NSError*))handler;


/*
 @method getMedia:withCompletionHandler:
 
 @abstract
 Performs retrieving media list request,
 returning the formatted NSArray object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 NSArray object and returns it.
 
 @param
 PxePlayerMediaQuery
 The api model to request. It wont expect the complete URL.
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
+(void)getMedia:(PxePlayerMediaQuery*)query withCompletionHandler:(void (^)(NSArray*, NSError*))handler;

/*
 @method getCustomNavigation:withCompletionHandler:

 @abstract
 Performs retrieving custom navigation table of content list request,
 returning the formatted PxePlayerToc object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerToc object and returns it.
 
 @param
 PxePlayerTocQuery
 The api model to request. It wont expect the complete URL.
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
+(void)getCustomNavigation:(PxePlayerTocQuery*)query withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler;

/*
 @method getTOCFromURL:withCompletionHandler:
 
 @abstract
 Performs retrieving NCX or XHTML table of contents request,
 returning the formatted PxePlayerToc object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerToc object and returns it.
 
 @param
 apiURL
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
+ (void) getTOCFromDataInterface:(PxePlayerDataInterface*)dataInterface
           withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler;

/**
 @method 
 getCustomBasketDataFromDataInterface:withCompletionHandler:
 
 @abstract
 Retrieves the Custom Basket Data from a toc.xhtml at an API URL.
 
 @discussion
 This method is a stop gap for when a a TOC is provided as a toc.ncx but custom 
 baskets are still required and provided in an additional toc.xhtml.
 
 @param
 apiURL
 The URL pointing to the toc.xhtml file.
 
 @param
 handler
 The completion handler block which will be executed
 when the data is received and parsed.

 */
+ (void) getCustomBasketDataFromDataInterface:(PxePlayerDataInterface*)dataInterface
                        withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler;

/**
 
 */
+ (void) getCustomBasketDataFromAPIUsingDataInterface:(PxePlayerDataInterface*)dataInterface
                                withCompletionHandler:(void (^)(NSDictionary*, NSError*))handler;

/**
 
 */
+ (void) getTOCDataFromAPIUsingDataInterface:(PxePlayerDataInterface*)dataInterface
                       withCompletionHandler:(void (^)(NSDictionary*, NSError*))handler;

/**
 
 */
+(void)getMasterPlaylistToc:(NSArray*)masterPlaylist withCompletionHandler:(void (^)(PxePlayerToc*, NSError*))handler;

/*
 @method getTOCPage:withCompletionHandler:

 
 @abstract
 Performs retrieving NCX page request,
 returning the formatted PxePlayerPage object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerPage object and returns it.
 
 @param
 PxePlayerPagesQuery
 The api model to request. It wont expect the complete URL.
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
+ (void) getTOCPage:(PxePlayerPagesQuery*)query
      dataInterface:(PxePlayerDataInterface*)dataInterface
  completionHandler:(void (^)(PxePlayerPage*, NSError*))handler;


/*
 @method checkBookmark:withCompletionHandler:
 
 @abstract
 Performs retrieving Bookmarks request,
 returning the formatted PxePlayerCheckBookmark object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 PxePlayerCheckBookmark object and returns it.
 
 @param
 PxePlayerBookmarkQuery
 The api model to request. It wont expect the complete URL.
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
+(void)checkBookmark:(PxePlayerBookmarkQuery*)query withCompletionHandler:(void (^)(PxePlayerCheckBookmark*, NSError*))handler;


/*
 @deprecated use +downloadGlossary:(PxePlayerNavigationsQuery*)query withCompletionHandler:(void (^)(id, NSError*))handler instead
 @method  getGlossary:withCompletionHandler:
 
 @abstract
 Performs retrieving glossary list request,
 returning the list of glossary items as a NSArray object.
 
 @discussion
 This method initiates a request, identifies
 the error status, and based on error status, it will
 parse the json object received into appropriate
 NSAarray object and returns it.
 
 @param
 apiURL
 The api URL to request. It wont expect the complete URL.
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
+(void)getGlossary:(NSString*)apiURL withCompletionHandler:(void (^)(id, NSError*))handler __attribute__((deprecated));

/**
 *  Gets a json list of glossary terms
 *
 *  @param query   NSDictionary
 *  @param handler The completion handler block which will be executed
 when the data is received from the request sent.
 */
+(void)downloadGlossary:(NSDictionary*)query withCompletionHandler:(void (^)(id, NSError*))handler;

/**
 This method gets manifest data for a book. The manifest data contains content asset information which client may wish to download
 selectively
 */
+(void) downloadManifestDataWithUrl:(NSString*)url withCompletionHandler:(void (^)(NSDictionary*, NSError*))handler;

@end
