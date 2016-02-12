//
//  NTQueryParser.m
//  NTApi
//
//  Created by Saro Bear on 02/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerQueryParser.h"
#import "PxePlayerChaptersQuery.h"
#import "PxePlayerPagesQuery.h"
#import "PxePlayerBookQuery.h"
#import "PxePlayerBookmarkQuery.h"
#import "PxePlayerTocQuery.h"
#import "PxePlayerAnnotationsQuery.h"
#import "PxePlayerAddAnnotationQuery.h"
#import "PxePlayerAnnotation.h"
#import "PxePlayerSearchNCXQuery.h"
#import "PxePlayerSearchURLsQuery.h"

@implementation PxePlayerQueryParser


#pragma mark - Public methods

+(NSDictionary*) parseTOCQuery:(PxePlayerTocQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];

   // queryDic[@"authToken"] = query.authToken;
    
    return queryDic;
}

+(NSDictionary*) parseChaptersQuery:(PxePlayerChaptersQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"authToken"] = query.authToken;
   
    return queryDic;
}

+(NSDictionary*) parsePagesQuery:(PxePlayerPagesQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"authToken"] = query.authToken;
    
    return queryDic;
}

+(NSDictionary*) parseBookShelfQuery:(PxePlayerBookQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"authToken"] = query.authToken;
    
    return queryDic;
}

+(NSDictionary*) parseNavigationsQuery:(PxePlayerNavigationsQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"authToken"] = query.authToken;
    
    return queryDic;
}

+(NSDictionary*) parseBookmarkQuery:(PxePlayerNavigationsQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"authToken"] = query.authToken;
    
    return queryDic;
}

+(NSDictionary*)parseAddBulkBookmarkQuery:(NSArray*)queries{

    NSMutableArray *bookmarks = [@[]mutableCopy];
    //an array of bookmark
    for (PxePlayerBookmarkQuery *query in queries) {
        NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        queryDic[@"uri"] = query.uri;
        queryDic[@"title"] = query.bookmarkTitle;
        queryDic[@"contentId"] = query.bookUUID;
        queryDic[@"contextId"] = query.contextID;
        queryDic[@"identityId"] = query.userUUID;
        
        [bookmarks addObject:queryDic];
    }
    
    return @{@"bookmarks":bookmarks};
}

+(NSDictionary*) parseAddBookmarkQuery:(PxePlayerBookmarkQuery*)query
{
    
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    queryDic[@"uri"] = query.uri;
    queryDic[@"title"] = query.bookmarkTitle;
    //queryDic[@"authToken"] = query.authToken;
    
    return queryDic;

}

+(NSDictionary*) parseNotesQuery:(PxePlayerNavigationsQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    //queryDic[@"authToken"] = query.authToken;
    
    return queryDic;
}

+(NSDictionary*) parseAnnotationsQuery:(PxePlayerAnnotationsQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"userName"] = query.userName;
    
    return queryDic;
}

+(NSDictionary*) parseAddAnnotationQuery:(PxePlayerAddAnnotationQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
   // queryDic[@"authToken"] = query.authToken;
    queryDic[@"uri"] = query.contentId;
    
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:0];
    for(PxePlayerAnnotation *annotation in query.annotations)
    {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        data[@"range"] = annotation.range;
        data[@"colorCode"] = annotation.colorCode;
        [annotations addObject:data];
    }
    
    queryDic[@"annotations"] = annotations;
    
    return queryDic;
}

+(NSDictionary*) parseUpdateAnnotationQuery:(PxePlayerAddAnnotationQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"authToken"] = query.authToken;
    queryDic[@"contentId"] = query.contentId;
    
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:0];
    for(PxePlayerAnnotation *annotation in query.annotations)
    {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        data[@"range"] = annotation.range;
        data[@"colorCode"] = annotation.colorCode;
        data[@"selectedText"] = annotation.selectedText;
        
        [annotations addObject:data];
    }
    queryDic[@"annotations"] = annotations;
    
    return queryDic;
}

+(NSDictionary*) parseSearchBookQuery:(PxePlayerSearchBookQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"authToken"] = query.authToken;
    
    return queryDic;
}

+(NSDictionary*) parseInitSearchNCXQuery:(PxePlayerSearchNCXQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    queryDic[@"indexContent"] = [NSNumber numberWithBool:query.indexContent];
    queryDic[@"urls"] = query.urls;

    return queryDic;
}

+(NSDictionary*) parseInitSearchURLsQuery:(PxePlayerSearchURLsQuery*)query
{
    NSMutableDictionary *queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //queryDic[@"authToken"] = query.authToken;
    //queryDic[@"contentId"] = query.contentId;
    queryDic[@"urls"] = query.contentURLs;
    
    return queryDic;
}

@end
