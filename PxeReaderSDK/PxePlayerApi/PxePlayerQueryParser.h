//
//  NTQueryParser.h
//  NTApi
//
//  Created by Saro Bear on 02/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

@class PxePlayerTocQuery;
@class PxePlayerChaptersQuery;
@class PxePlayerPagesQuery;
@class PxePlayerAnnotationsQuery;
@class PxePlayerBookQuery;
@class PxePlayerNavigationsQuery;
@class PxePlayerBookmarkQuery;
@class PxePlayerAddAnnotationQuery;
@class PxePlayerSearchNCXQuery;
@class PxePlayerSearchURLsQuery;
@class PxePlayerSearchBookQuery;


@interface PxePlayerQueryParser : NSObject

+(NSDictionary*) parseTOCQuery:(PxePlayerTocQuery*)query;


/*
 @method             parseChaptersQuery:
 
 @abstract
                     Performs parsing PxePlayerChaptersQuery,
                     returning the formatted NSDictionary object.
 
 @discussion
                     This method performs parsing of PxePlayerChaptersQuery object into appropriate
                     NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerChaptersQuery
                     The PxePlayerChaptersQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
                     Returns NSDictionary object after parsing.
 
 */
+(NSDictionary*) parseChaptersQuery:(PxePlayerChaptersQuery*)query;


/*
 @method             parsePagesQuery:
 
 @abstract
                     Performs parsing PxePlayerPagesQuery,
                     returning the formatted NSDictionary object.
                     
 @discussion
                     This method performs parsing of PxePlayerPagesQuery object into appropriate
                     NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerPagesQuery
                     The PxePlayerPagesQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
                     Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parsePagesQuery:(PxePlayerPagesQuery*)query;


/*
 @method             parseBookShelfQuery:
 
 @abstract
                     Performs parsing PxePlayerBookQuery,
                     returning the formatted NSDictionary object.
                     
 @discussion
                     This method performs parsing of PxePlayerBookQuery object into appropriate
                     NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
                     The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
                     Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseBookShelfQuery:(PxePlayerBookQuery*)query;


/*
 @method             parseNavigationsQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseNavigationsQuery:(PxePlayerNavigationsQuery*)query;


/*
 @method             parseBookmarkQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseBookmarkQuery:(PxePlayerNavigationsQuery*)query;


/*
 @method             parseAddBookmarkQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseAddBookmarkQuery:(PxePlayerBookmarkQuery*)query;
/**
 *  Used to Parse a bulk query
 *
 *  @param queries NSArray
 *
 *  @return NSArray
 */
+(NSDictionary*)parseAddBulkBookmarkQuery:(NSArray*)queries;

/*
 @method             parseNotesQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseNotesQuery:(PxePlayerNavigationsQuery*)query;

/**
 
 */
+(NSDictionary*) parseAnnotationsQuery:(PxePlayerAnnotationsQuery*)query;

/*
 @method             parseAddAnnotationQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseAddAnnotationQuery:(PxePlayerAddAnnotationQuery*)query;


/*
 @method             parseUpdateAnnotationQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseUpdateAnnotationQuery:(PxePlayerAddAnnotationQuery*)query;


/*
 @method             parseSearchBookQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseSearchBookQuery:(PxePlayerSearchBookQuery*)query;


/*
 @method             parseInitSearchNCXQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */

+(NSDictionary*) parseInitSearchNCXQuery:(PxePlayerSearchNCXQuery*)query;


/*
 @method             parseInitSearchURLsQuery:
 
 @abstract
 Performs parsing PxePlayerBookQuery,
 returning the formatted NSDictionary object.
 
 @discussion
 This method performs parsing of PxePlayerBookQuery object into appropriate
 NSDictionary object and returns it as expected by the server.
 
 @param
 PxePlayerBookQuery
 The PxePlayerBookQuery object that needs to be sent to the server.
 
 @result
 NSDictionary
 Returns NSDictionary object after parsing.
 
 */


+(NSDictionary*) parseInitSearchURLsQuery:(PxePlayerSearchURLsQuery*)query;


@end
