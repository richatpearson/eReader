//
//  NTParser.h
//  NTApi
//
//  Created by Satyanarayana on 6/28/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//



@class PxePlayerUser;
@class PxePlayerToc;
@class PxePlayerBookShelf;
@class PxePlayerChapters;
@class PxePlayerBookmarks;
@class PxePlayerBookmark;
@class PxePlayerCheckBookmark;
@class PxePlayerNotes;
@class PxePlayerAnnotations;
@class PxePlayerAnnotationsTypes;
@class PxePlayerDeleteAnnotation;
@class PxePlayerSearchPages;

extern NSString* const PXEBookShelfEntries ;
extern NSString* const PXEBookTitle;
extern NSString* const PXEBookISBN;
extern NSString* const PXEIndexId;
extern NSString* const PXEBookEdition;
extern NSString* const PXEBookCoverImageURL;
extern NSString* const PXEBookThumbURL;
extern NSString* const PXEBooklastAccess;
extern NSString* const PXEBookActive;
extern NSString* const PXEBookExpirationDate;
extern NSString* const PXEBookIsExpired;
extern NSString* const PXEBookIsWarningPeriod;
extern NSString* const PXEBookCopyRights;
extern NSString* const PXEBookSubject;
extern NSString* const PXEBookPublisher;
extern NSString* const PXEBookAuthor;
extern NSString* const PXEBookDate;
extern NSString* const PXEBookLanguage;
extern NSString* const PXEBookDesc;
extern NSString* const PXEBookTocUrl;
extern NSString* const PXEBookUUID;
extern NSString* const PXEBookFavorite;
extern NSString* const PXEBookWithAnnotations;
extern NSString* const PXEBookEPUBName;

extern NSString* const PXEChapterUUID;
extern NSString* const PXEChapterTitle;
extern NSString* const PXEChapterFrontMatter;
extern NSString* const PXEChapterBackMatter;
extern NSString* const PXEChapterPageUUIDs;

extern NSString* const PXEBookmarkData;
extern NSString* const PXEBookmarks;
extern NSString* const PXEBookmarkTitle;
extern NSString* const PXEBookmarkUri;
extern NSString* const PXEBookmarkIdentityId;
extern NSString* const PXEBookmarkContextId;

extern NSString* const PXEAnnotationsUserTags;
extern NSString* const PXEAnnotationsSharedTags;

extern NSString* const PXESearchParentTag;
extern NSString* const PXESearchPageUrl;
extern NSString* const PXESearchPageTitle;
extern NSString* const PXESearchPageDesc;
extern NSString* const PXESearchTotalPages;
extern NSString* const PXESearchWordHits;

@interface PxePlayerParser : NSObject

//TODO: Don't think parseTOC is ever called
/*
 @method             parseTOC:
 
 @abstract
                     Performs parsing the response,
                     returning the formatted PxePlayerToc object.
 
 @discussion
                     This method performs parsing of json object received from server into appropriate
                     PxePlayerToc object and returns it.
 
 @param
 values
                     The values(NSArray-JSON) response from server.
 
 @result
 PxePlayerToc
                     Returns PxePlayerToc object after parsing.
 */
+(PxePlayerToc*) parseTOC:(NSDictionary *)contents;


/*
 @method             parseBookShelf:
 
 @abstract
                     Performs parsing the response,
                     returning the formatted PxePlayerBookShelf object.
 
 @discussion
                     This method performs parsing of json object received from server into appropriate
                     PxePlayerBookShelf object and returns it.
 
 @param
 values
                     The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerBookShelf
                     Returns PxePlayerBookShelf object after parsing.
 */
+(PxePlayerBookShelf*) parseBookShelf:(NSDictionary*) bookshelf;


/*
 @method             parseChapter:
 
 @abstract
                     Performs parsing the response,
                     returning the formatted PxePlayerChapter object.
 
 @discussion
                     This method performs parsing of json object received from server into appropriate
                     PxePlayerChapter object and returns it.
 
 @param
 values
                     The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
                     Returns PxePlayerChapter object after parsing.
 */
+(PxePlayerChapters*) parseChapter:(NSArray *)values;



/*
 @method             parseBookmark:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 */
+(PxePlayerBookmarks*) parseBookmark:(NSDictionary*)values;

/**
 *  Parses a json representation of the glossary into an array version
 *
 *  @param json NSDictionary
 *
 *  @return NSArray
 */
+(NSArray*)parseGlossary:(NSDictionary*)json;

/*
 @method             isPageBookmarked:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 */
+(PxePlayerCheckBookmark*) isPageBookmarked:(NSDictionary*)values;


/*
 @method             parseAddBookmark:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 */
+(PxePlayerBookmark*) parseAddBookmark:(NSDictionary*)values;

/**
 *  parse a bulk bookmark response
 *
 *  @param values NSArray
 *
 *  @return NSArray
 */
+(NSArray*) parseBulkAddBookmark:(NSArray*)values;


/*
 @method             parseDeleteBookmark:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 */
+(PxePlayerBookmark*) parseDeleteBookmark:(NSDictionary*)values;
/*
 @method             parseDeleteBookmark:
 
 @abstract
 Performs parsing the response,
 returning the formatted NSAarray object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 NSArray of PxePlayerChapter objects and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 */
+(NSArray*)parseBulkDeleteBookmark:(NSDictionary*)values;

/*
 @method             parseEditBookmark:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 */
+(PxePlayerBookmark*) parseEditBookmark:(NSDictionary*)values;

/*
 @method             parseAnnotations:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 */
+ (PxePlayerAnnotationsTypes *) parseAnnotations:(NSDictionary *)values;

/*
 @method             parseDeleteAnnotation:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 
 */
+(PxePlayerDeleteAnnotation*) parseDeleteAnnotation:(NSDictionary*)values;

/*
 @method             parseBookSearch:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 
 */
+(PxePlayerSearchPages*) parseBookSearch:(NSDictionary*)values;



/*
 @method             parseMedia:
 
 @abstract
 Performs parsing the response,
 returning the formatted PxePlayerChapter object.
 
 @discussion
 This method performs parsing of json object received from server into appropriate
 PxePlayerChapter object and returns it.
 
 @param
 values
 The values(NSDictionary-JSON) response from server.
 
 @result
 PxePlayerChapter
 Returns PxePlayerChapter object after parsing.
 */
+(NSArray*)parseMedia:(NSDictionary*)values;

@end
