//
//  PxePlayerDataInterface.h
//  PxeReader
//
//  Created by Saro Bear on 06/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXEPlayerEnvironment.h"

typedef NS_ENUM(NSInteger, PxePlayerClientApp)
{
    PxePlayerSampleApp  = 0,
    eText2_K12          = 1,
    eText2_HE           = 2
};


@interface PxePlayerDataInterface : NSObject

/**
 
 */
@property (nonatomic, assign) PxePlayerClientApp clientApp;

/**
 A NSString variable to hold the context title.
 */
@property (nonatomic, strong) NSString  *contextTitle;

/**
 A NSString variable to hold the context id
 */
@property (nonatomic, strong) NSString  *contextId;

/**
 A NSString variable to hold the asset id
 */
@property (nonatomic, strong, getter=getAssetId) NSString *assetId;

/**
 A NSString variable to hold the relative path to the TOC
 */
@property (nonatomic, strong) NSString *tocPath;

/**
 A NSString variable to hold the user id
 */
@property (nonatomic, strong) NSString  *identityId;

/**
 A PxePlayerEnvironment Value. Necessary for things like Google Analytics
 */
@property (nonatomic, assign) PxePlayerEnvironment environment;

/**
 The absolute path to the ePub package (zip) to be downloaded for offline use.
 */
@property (nonatomic, strong) NSString *ePubURL;

/**
 A NSString variable to hold the base URL to the root epub file
 */
@property (nonatomic, strong) NSString  *onlineBaseURL;

/**
 A NSString variable to hold the base URL to the root epub file
 */
@property (nonatomic, strong) NSString  *offlineBaseURL;

/**
 A NSString variable to hold the auth token
 */
@property (nonatomic, strong) NSString  *authToken;

/**
 A NSString variable to hold the index id (formally known as searchIndexId).
 This id is used for searches and for glossary retrieval. If received from 
 the Bookshelf data, override submitting the TOC url to get the IndexId 
 from the service
 */
@property (nonatomic, strong, getter=getIndexId) NSString  *indexId;

/**
 A NSString variable to hold the after cross reference behaviour
 */
@property (nonatomic, strong) NSString  *afterCrossRefBehaviour;

/**
 A NSString variable to hold the learning context information
 */
@property (nonatomic, strong) NSString  *learningContext;

/**
 A NSArray variable to hold the master playlist URL's
 */
@property (nonatomic, strong) NSArray   *masterPlaylist;
/**
 A BOOL that determines if we are able to show annotation pop up menu - Can be moved to PageViewOptions
 */
@property (nonatomic, assign) BOOL showAnnotate;
/**
 A NSString that holds the content auth token used to set in the webview header
 */
@property(nonatomic, strong) NSString *contentAuthToken;
/**
 A NSString that holds the domain of the app url to set as the header cookied (example: las.dev-openclass.com)
 */
@property(nonatomic, strong) NSString *cookieDomain;
/**
 A NSString that holds the name of the authToken
 */
@property(nonatomic, strong) NSString *contentAuthTokenName;
/**
 A BOOL that will set the shareble flag for notes and annotations - Can be moved to PageViewOptions
 */
@property (nonatomic, assign) BOOL annotationsSharable;
/**
 A BOOL that will set the mathML to be used or not - Can be moved to PageViewOptions
 */
@property (nonatomic, assign) BOOL enableMathML;

/**
 Set to YES if you want to let TOC API remove duplicate pages from the data it returns. 
 Part of dataInterface because it involves removing duplicate pages from the data.
 The TOC API (only for ePubs using toc.xhtml) accepts a parameter for removing duplicate pages in the TOC. 
 Pages are considered duplicates if either both URLs are pointing to the same href and have the same parent 
 node (even if the titles for those two pages are different) OR if parent and child node hrefs are the same 
 (i.e. after removing fragment identifier from hrefs). Setting removeDuplicatePages to YES sets the parameter 
 in the querystring to true. The default value is false. If your application uses other services that rely on 
 the full TOC (ex.: servcies that provide a custom playlist built from the existing TOC), use this property 
 with caution.
 */
@property (nonatomic, assign) BOOL removeDuplicatePages;

/**
 return either the tocURL or the master Playlist
 */
- (id) getTocOrPlaylist;

/**
 
 */
- (NSString *) getAssetId;

/**
 This comment is out of date as the specifications change from day to day
 Verified that necessary properties have been set.
 Must have the following?:
    1. ncxURL or masterPlaylist
    4. contextId
    6. afterCrossRefBehaviour ("continue" or "stop")
 */
- (BOOL) verified;

/**
 
 */
- (BOOL) verifyWithError:(NSError **)error;

/**
 
 */
- (NSString *) getBaseURL;

/**
 
 */
- (NSString *) getClientAppName;

@end
