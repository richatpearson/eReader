//
//  NTApplication.h
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerManifest.h"
#import "PxePlayerEnvironmentContext.h"

@class PxePlayerUser;
@class PxePlayerDataInterface;
@class PxePlayerPageViewController;
@class PxePlayerBookmarks;
@class PxePlayerBookmark;
@class PxePlayerCheckBookmark;
@class PxePlayerSearchPages;
@class PxePlayerAnnotation;
@class PxePlayerAnnotations;
@class PxePlayerAnnotationsTypes;
@class PxePlayerDeleteAnnotation;
@class PxePlayerPageViewOptions;

@interface PxePlayer : NSObject

typedef void (^isSuccess)(BOOL success);

# pragma mark Instantiation

/*!
 @method         sharedInstance:
 
 @abstract
                 Renders PxePlayer shared instance of the UI Library.
 
 @discussion
                 This method instantiate PxePlayer and returns singleton object of the UI Library.
 
 @resultcurren
                 Singleton object of the UI Library.
 */

+(id)sharedInstance;

#ifdef DEBUG
- (void) markLoadTime:(NSString*)timeToMark;
- (void) markLoadComplete;
#endif
/**
 
 */
- (BOOL) updatePxeEnvironment:(PxePlayerEnvironmentContext *)environment error:(NSError**)error;

- (NSString*) getWebAPIEndpoint;
- (NSString*) getSearchServerEndpoint;
- (NSString*) getPxeServicesEndpoint;
- (NSString*) getPxeSDKEndpoint;
- (PxePlayerEnvironmentType) getPxeEnvironmentType;
- (NSString*) getPxeEnvironmentNameForType:(PxePlayerEnvironmentType)environmentType;

/*!
 @method
 updateDataInterface:
 
 @abstract
 Set all primary data required to do all API services.
 
 @discussion
 Service API's would use these data to communicate with the server.
 
 @result
 Data's would be in primary memory for external access.
 */

-(void)updateDataInterface:(PxePlayerDataInterface *)interface
                  finished:(isSuccess)success __attribute((deprecated("Use method updateDataInterface:onComplete: instead")));

/**
 
 */
- (void) updateDataInterface:(PxePlayerDataInterface *)interface
                  onComplete:(void (^)(BOOL success, NSError *error))handler;

/**
 
 */
- (PxePlayerUser*) createCurrentUserFromDataInterface:(PxePlayerDataInterface *)dataInterface;

/*!
 @method
 renderPagesWithOptions:
 
 @abstract
 Render the Page of HTML content.
 
 @discussion
 Render HTML content downloaded from the URL's collected from the NCX content.
 
 @result
 Page of HTML content would be rendered into the UIWebview.
 */

-(PxePlayerPageViewController*)renderWithOptions:(PxePlayerPageViewOptions*)options;


/*!
 @method
 renderWithPage:withOptions:
 
 @abstract
 Render the Page of HTML content.
 
 @discussion
 Render HTML content downloaded from the independent URL.
 
 @result
 Page of HTML content would be rendered into the UIWebview.
 */

-(PxePlayerPageViewController*)renderPage:(NSString*)URLOrContentID withOptions:(PxePlayerPageViewOptions*)options;


/*!
 @method
 renderPagesWithURLs:withOptions:
 
 @abstract
 Render the Page of HTML content.
 
 @discussion
 Render HTML content downloaded from the URL's collected from the array of URL.
 
 @result
 Page of HTML content would be rendered into the UIWebview.
 */

-(PxePlayerPageViewController*)renderCustomPlaylist:(NSArray*)urls withOptions:(PxePlayerPageViewOptions*)options;


/*!
 @method
 renderPagesWithURLs:andJumpToPage:withOptions:
 
 @abstract
 Render the Page of HTML content.
 
 @discussion
 Render HTML content downloaded from the URL's collected from the array of URL and starts with predefined page.
 
 @result
 Page of HTML content would be rendered into the UIWebview.
 */

-(PxePlayerPageViewController*)renderCustomPlaylist:(NSArray*)urls andJumpToPage:(NSString*)URLOrContentID withOptions:(PxePlayerPageViewOptions*)options;

/*!
 @method
 webFileExists:
 @abstract
 Test to see if a URL points at an existing file
 @param 
 NSString, the url to be tested
 @return 
 BOOL Indicates whether or no the file exists
 */
-(BOOL) webFileExists:(NSString*)url;

# pragma mark Getters and Setters

/*!
 @method
 purgeCachedData:
 
 @abstract
 Remove all cached data from the filesystem.
 
 @discussion
 This method removes all cached data from the filesystem.
 
 @result
 Cached data will be cleared.
 */

-(void)purgeCachedData;


/**
  Get the current book contextID
  @return NSString, returns the current book context id
  @see PxePlayerDataInterface
 */
- (NSString*) getContextID;

- (NSString*) getAssetId;

/**
 *  Gets the current user
 *
 *  @return PxePlayerUser
 */
- (PxePlayerUser *) currentUser;

/**
 *  Sets the current User
 *
 *  @param pxePlayerUser PxePlayerUser
 */
- (void) setCurrentUser:(PxePlayerUser *) pxePlayerUser;

/**
  Get the current user IdentityID
  @return NSString , returns the current book identity id
  @see PxePlayerDataInterface
 */
- (NSString*) getIdentityID;

/**
  Get the current book learning context
  @return NSString , returns the current book learning context
  @see PxePlayerDataInterface
 */
- (NSString*) getLearningContext;

/**
 learningContext may have to be reset if for example auth token expires
 */
- (void) resetLearningContext:(NSString*)learningContext;

/**
 Set the current book's index id used for search and glossary
 @param NSString, indexId is a reference to set as a current book's index id.
 @see PxePlayerDataInterface
 */
- (void) setIndexId:(NSString*)indexId;

/**
 
 */
- (NSString*) getIndexId;

/**
 
 */
- (NSString*) getGoogleAnalyticsTrackingIdForKey:(NSString*)key;


/**
 Sets the current annotate state
 @param BOOL
 @see PxePlayerDataInterface
 */
-(void)setAnnotateState:(BOOL)canAnnotate;

/**
 Gets the current annotate state
@return BOOL
 @see PxePlayerDataInterface
 */
-(BOOL)getAnnotateState;

/**
 Sets the current MathML state
 @param BOOL
 @see PxePlayerDataInterface
 */
-(void)setEnableMathML:(BOOL)isMathML;

/**
 Gets the current MathML state
 @return BOOL
 @see PxePlayerDataInterface
 */
-(BOOL)getEnableMathML;

/**
  Get the glossary content of the current book
  @param NSArray, returns the glossary terms
  @param NSError, returns error if glossary download failed
 */
-(void)getGlossaryWithCompletionHandler:(void (^)(NSArray*, NSError*))handler;

/**
 
 */
- (void) refreshGlossaryOnDeviceWithCompletionHandler:(void (^)(NSArray *, NSError *))handler;

/**
 
 */
- (id) parseGlossaryManagedData:(NSArray*)glossaryArray;

/**
 
 */
- (BOOL) insertGlossaryItems:(NSArray*)glossaryObjs;

/**
 
 */
- (BOOL) insertGlossaryItems:(NSArray*)glossaryObjs
           withDataInterface:(PxePlayerDataInterface*)dataInterface;

/**
  Get the current book total number of pages
  @return NSUInteger, returns total number of pages in the book
 */

-(NSUInteger)getTotalPageEntry;

/**
  Get the particular book's page details as a dictionary
  @param NSString, property is reference of particular property of the page to compare the data in Coredata
  @param NSString, value is a reference of value for the property 
  @return NSDictionary , returns the pages details properties and values as a NSDictionary
 */
-(NSDictionary*)getPageDetails:(NSString*)property withValue:(NSString*)value;

/**
 
 */
- (NSDictionary*) getPageDetails:(NSString*)property containingValue:(NSString*)value;

/**
 
 */
- (NSString*) getPXEVersion;


/**
  Get the current book table of contents specific branch of tree
  @param NSString, rootId is a reference to retreive a particular branch from the given root id
  @return NSArray , returns the particular branch of table of contents title from the tree
 */
-(NSArray*)getTocTree:(NSString*)parentId;

/**
 
 */
- (NSArray*) getCustomBasketTree:(NSString*)parentId;

/**
 
 */
- (BOOL) currentContextHasCustomBasket;

/**
 Set the content auth token
 */
-(void)setContentAuthToken:(NSString*)token;
/**
 Gets the contentAutToken
 */
-(NSString*)getContentAuthToken;
/**
 Set the content auth token
 */
-(void)setContentAuthTokenName:(NSString*)tokenName;
/**
 Gets the contentAutToken
 */
-(NSString*)getContentAuthTokenName;
/**
 Client app can reset the authorization token to a newer value
 */
-(void) resetAuthToken:(NSString*)newToken;

/**
 Allows you to reset a current online base path
 */
- (void) resetOnlineBaseURL:(NSString*)newOnlineBaseURL;

/**
 Sets the cookieDomain
 */
- (void) setCookieDomain:(NSString*)domain;
/**
 Gets the cookieDomain
 */
-(NSString*)getCookieDomain;

/**
 Gets the TOC URL should be like toc.ncx or toc.xhtml if online and OPS/toc.ncx or OPS/toc.xhtml if offline
 */
- (NSString*) getTOCURL;

/**
 Gets the TOC URL should be like toc.ncx or toc.xhtml if online and OPS/toc.ncx or OPS/toc.xhtml if offline
 */
- (NSString*) getTOCPath;

/**
 
 */
- (NSString*) getRemoveDuplicatePagesForQueryString;

/**
 
 */
- (BOOL) usingPlaylist;

/**
 Set the content sharable bool
 */
- (void) setAnnotationsSharable:(BOOL)isSharable;

/**
 Gets the bool for sharable
 */
- (BOOL) getAnnotationsSharable;

/**
 *  Gets the Datainterface isoffline bool
 *
 *  @return BOOL
 */
- (BOOL) isDownloaded:(NSString*)assetId;

/**
 
 */
- (PxePlayerDataInterface *) currentDataInterface;

/**
 
 */
- (void) loadUrlInSafari:(NSURL *)url;

/**
 Checks if the TOC pages exist in persistant storage for context id
 */
- (BOOL) isTOCDownloadedForContext:(NSString*)contextId;

- (void) dispatchGAIEventWithCategory:(NSString*)category
                               action:(NSString*)action
                                label:(NSString*)label
                                value:(NSNumber*)value;

- (void) dispatchGAIScreenEventForPage:(NSString*)pageURL;

@end

#pragma mark - Boomkarks

@interface PxePlayer (Bookmarks)

/*!
 @method
 getBookmarksWithCompletionHandler:
 
 @abstract
 Retrieve bookmarked pages reference.
 
 @discussion
 This method just retrieve bookmarked pages reference in the book
 
 @result
 Returns the array of reference of bookmarked pages.
 */

-(void)getBookmarksWithCompletionHandler:(void (^)(PxePlayerBookmarks*, NSError*))handler;

/*!
 
 */
- (void) getBookmarksOnDevice:(void (^)(PxePlayerBookmarks*, NSError*))handler;


/*!
 @method
 addBookmarkWithTitle:andPageId:withCompletionHandler
 
 @abstract
 Add page as bookmarked.
 
 @discussion
 This method mark the page as bookmarked.
 
 @result
 Returns whether page has bookmarked or not.
 */

-(void)addBookmarkWithTitle:(NSString*)bookmarkTitle andURL:(NSString*)url withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler;

/*!
 
 */
- (void) addBookmarksOnDevice:(NSArray*)bookmarks;

/*!
 
 */
- (void) addBookmarksOnDevice:(NSArray*)bookmarks withDataInterface:(PxePlayerDataInterface*)dataInterface;

/*!
 @method
 checkBookmarkWithId:WithCompletionHandler:
 
 @abstract
 Check correponding page has bookmarked or not.
 
 @discussion
 This method checks the page has bookmarked or not.
 
 @result
 Returns the page has bookmarked or not.
 */

-(void)checkBookmarkWithURL:(NSString*)contentID withCompletionHandler:(void (^)(PxePlayerCheckBookmark*, NSError*))handler;

/*!
 @method
 editBookmarkWithTitle:andPageId:withCompletionHandler
 
 @abstract
 Edit the properties of the bookmarked page.
 
 @discussion
 This method allow the user to edit the properties of bookmarked page.
 
 @result
 Return whether bookmark has updated with new details or not.
 */

-(void)editBookmarkWithTitle:(NSString*)bookmarkTitle andURL:(NSString*)contentID withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler;


/*!
 @method
 deleteBookmarkWithPageId:WithCompletionHandler:
 
 @abstract
 Remove the bookmark from the page.
 
 @discussion
 This method just remove the bookmark on the page.
 
 @result
 Bookmark on page will be removed.
 */

-(void)deleteBookmarkWithURL:(NSString*)url withCompletionHandler:(void (^)(PxePlayerBookmark*, NSError*))handler;

/**
 *  Public method to be called by the app when the device has come back online
 *
 *  @return BOOL
 */
-(void)queueOfflineForCompletion;

/**
 
 */
- (void) refreshBookmarksOnDeviceWithCompletionHandler:(void (^)(PxePlayerBookmarks *, NSError *))handler;

@end


#pragma mark - Search

@interface PxePlayer (Search)

/**
  Submit the NCX URL for CM indexing to intialize the search and media content preparation .
  @param NSString, url is a reference of NCX URL to be send to server for indexing and media content prepartion .
  @param (void (^)(NSString*, NSError*))handler, is a block which receives the index id for given NCX URL 
  @see completionHandler:(void (^)(NSString*, NSError*))handler;
 */
-(void)submitTOCUrlForIndexingWithCompletionHandler:(void (^)(NSString*, NSError*))handler;


/**
  Get the current book table of contents specific branch of tree
  @param NSString, rootId is a reference to retreive a particular branch from the given root id
  @return NSArray , returns the particular branch of table of contents title from the tree
 */
-(void)submitUrlsForIndexing:(NSArray*)urls withCompletionHandler:(void (^)(NSString*, NSError*))handler;


/*!
 @method
 searchContent:withMaxResults:andPageNumber:withCompletionHandler
 
 @abstract
 Search any content inside the book.
 
 @discussion
 This method search the content in the book and returns the results of pages reference which holds the search content.
 
 @result
 Returns the pages reference having search terms .
 */

-(void)searchContent:(NSString*)searchTerm from:(NSInteger)resultStartOffset withSize:(NSInteger)numberOfResults  withCompletionHandler:(void (^)(PxePlayerSearchPages*, NSError*))handler;

@end


#pragma mark - Annotations

@interface PxePlayer (Annotations)

/*!
 @method
 getAnnotationsWithCompletionHandler:
 
 @abstract
 Get annotations in the page.
 
 @discussion
 This method returns the all annotations in the page.
 
 @result
 Returns the array of annotations reference in the page.
 */
- (void) getAnnotationsWithCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

/**
 
 */
- (void) addAnnotationsToDevice:(PxePlayerAnnotationsTypes *)annotationsTypes
          withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

- (void) addAnnotationsToDevice:(PxePlayerAnnotationsTypes *)annotationsTypes
                   forContextId:(NSString*)contextId
          withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

/**
 
 */
- (void) readAnnotationsOnDeviceWithCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler;

- (void) readAnnotationsOnDeviceForContextId:(NSString*)contextId
                       withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler;

/**
 
 */
- (BOOL) deleteAnnotationsOnDevice:(PxePlayerAnnotations *)pxePlayerAnnotations;

/**
 
 */
- (BOOL) deleteAnnotationOnDeviceWithResult:(NSDictionary*)result withError:(NSError **)error;

/**
 
 */
- (BOOL) updateAnnotationsOnDevice:(PxePlayerAnnotations *)pxePlayerAnnotations
                      forContextId:(NSString*)contextId
                         withError:(NSError **) error;

/**
 
 */
- (void) getAnnotationsForPage:(NSString*)pageURI withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes*, NSError*))handler;

/**
 
 */
- (void) refreshAnnotationsOnDeviceWithCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

/*!
 @method
 getAnnotationsForContentWithCompletionHandler:
 
 @abstract
 Remove all cached data from the filesystem.
 
 @discussion
 This method just remove the all cached data from the filesystem.
 
 @result
 Cached data will be cleared.
 */

- (void) getAnnotationsForContent:(NSString *)contentID withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

/**
 
 */
- (void) getAnnotationsTypesOnDeviceForPageURI:(NSString *)pageURI
                                     contextId:(NSString *)contextId
                                    identityId:(NSString *)identityId
                         withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

/*!
 @method
 addAnnotations:withCompletionHandler:
 
 @abstract
 Add annotation on the page.
 
 @discussion
 This method add the new annotation on the page.
 
 @result
 The annotations will be added into the page.
 */

- (void) addAnnotationsArray:(NSArray *)annotations forContentID:(NSString *)contentID withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;


/*!
 @method
 updateAnnotations:withCompletionHandler:
 
 @abstract
 Update annotations on the page
 
 @discussion
 This method updates the edited details of the existing annotations.
 
 @result
 The annotations on the page will be updated with edited properties.
 */

-(void)updateAnnotations:(NSArray*)annotations forContentID:(NSString*)contentID withCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;


/*!
 @method
 deleteAnnotationWithCompletionHandler:
 
 @abstract
 Delete annotations on the page.
 
 @discussion
 This method remove the annotations on the page.
 
 @result
 The annotation on the page will be removed.
 */

-(void)deleteAnnotationForContentID:(NSString*)contentID WithCompletionHandler:(void (^)(PxePlayerDeleteAnnotation*, NSError*))handler;

/*!
 
 */
- (PxePlayerAnnotation *)getAnnotationOnDeviceForAnnotationData:(NSDictionary *)annotationData onPage:(NSString*)uri;

@end

#pragma mark - Media

/**
  PxePlayer category class for media.
 */

@interface PxePlayer (Media)

/**
  Get the current book media contents
  @param NSString , type as a reference to get the type of media contents
  @param completionHandler:(void (^)(NSArray*, NSError*))handler which returns the array of media contents after media has been downloaded;
  @see PxePlayerInterface
 */
-(void)getMedia:(NSString*)type withCompletionHandler:(void (^)(NSArray*, NSError*))handler;

@end

#pragma Mark - Base URL Manipulations

@interface PxePlayer (BaseURL)

/**
 Will always return the offline base URL if the context has been downloaded (path to the epub NOT the epub/OPS).
 Will return the online base URL otherwise (path to the OPS usually so long as OPS exists)
 */
- (NSString*) getBaseURL;

/**
 Returns the online path to the OPS usually but does not include the OPS
 */
- (NSString*) getOnlineBaseURL;

/**
 Set the online baseURL (obtained through a service such as the TOCAPI) to the OPS usually but does not include the OPS
 */
- (void) setOnlineBaseURL:(NSString *)baseURL forContextId:(NSString*)contextId;

/**
 Returns the offline path to the OPS usually but does not include the OPS
 */
-(NSString*)getOfflineBaseURL;

/**
 Used for obtaining the realtive path of a URL.
 1. If the URL param contains http:/ or https:/, it is assumed that the onlime base URL should be stripped.
 2. If no form of http is present, it is assumed that the offline base URL is to be stripped as well as "file://"
 3. After that, any remaining ":', "/", and "OPS/" at the beginning of the string is removed.
 */
- (NSString*)removeBaseUrlFromUrl:(NSString *)url;

/**
 Prepends the base url (online or offline as indicated by the online BOOL parameter) (including "/OPS") to the relative path url parameter.
 */
- (NSString*) prependBaseURL:(NSString*)url forOnline:(BOOL)online;

/**
 Prepends "OPS/" to the relative uri
 */
- (NSString *) formatRelativePathForJavascript:(NSString*)uri;

/**
 Removes "OPS/" from the relative uri
 */
- (NSString *) formatRelativePathForTOC:(NSString *)uri;

/**
 Must have "/OPS/" in the path
 */
- (NSString *) getOnlineBaseURLFromTOCAbsoluteURL:(NSString*)tocURL;

#pragma Mark Manifest and Manifest Items

- (void) retrieveManifestItemsForDataInterface:(PxePlayerDataInterface*)dataInterface
                          withCompletionHandler:(void (^)(PxePlayerManifest*, NSError*))completionHandler;

@end
