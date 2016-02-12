//
//  NTParser.m
//  NTApi
//
//  Created by Satyanarayana on 6/28/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "PxePlayerParser.h"
#import "PxePlayerUser.h"
#import "PxePlayerToc.h"
#import "PxePlayerBookShelf.h"
#import "PxePlayerBook.h"
#import "PxePlayerChapters.h"
#import "PxePlayerChapter.h"
#import "PxePlayerBookmarks.h"
#import "PxePlayerCheckBookmark.h"
#import "PxePlayerAddBookmark.h"
#import "PxePlayerDeleteBookmark.h"
#import "PxePlayerEditBookmark.h"
#import "PxePlayerNotes.h"
#import "PxePlayerAnnotations.h"
#import "PxePlayerAnnotationsTypes.h"
#import "PxePlayerDeleteAnnotation.h"
#import "PxePlayerSearchPages.h"
#import "PxePlayerAnnotation.h"
#import "PxePlayerSearchPages.h"
#import "PxePlayerSearchPage.h"
#import "PxePlayerMedia.h"
#import "PxePlayerMediaCrumb.h"
#import "PXEPlayerMacro.h"
#import "NSString+Extension.h"

#pragma mark - Bookshelf macros

NSString* const PXEBookShelfEntries     = @"entries";
NSString* const PXEBookTitle            = @"title";
NSString* const PXEIndexId             = @"indexId";
NSString* const PXEBookISBN             = @"isbn";
NSString* const PXEBookEdition          = @"edition";
NSString* const PXEBookCoverImageURL    = @"coverImageUrl";
NSString* const PXEBookThumbURL         = @"thumbnailImageUrl";
NSString* const PXEBooklastAccess       = @"lastAccessTs";
NSString* const PXEBookActive           = @"active";
NSString* const PXEBookExpirationDate   = @"expirationDate";
NSString* const PXEBookIsExpired        = @"expired";
NSString* const PXEBookIsWarningPeriod  = @"inWarningPeriod";
NSString* const PXEBookCopyRights       = @"rights";
NSString* const PXEBookSubject          = @"subject";
NSString* const PXEBookPublisher        = @"publisher";
NSString* const PXEBookAuthor           = @"creator";
NSString* const PXEBookDate             = @"date";
NSString* const PXEBookLanguage         = @"language";
NSString* const PXEBookDesc             = @"description";
NSString* const PXEBookTocUrl           = @"toc";
NSString* const PXEBookUUID             = @"bookId";
NSString* const PXEBookFavorite         = @"favorite";
NSString* const PXEBookWithAnnotations  = @"withAnnotations";
NSString* const PXEBookEPUBName         = @"filename";


#pragma mark - Chapters macros

NSString* const PXEChapterUUID          = @"chapterUUID";
NSString* const PXEChapterTitle         = @"title";
NSString* const PXEChapterFrontMatter   = @"frontMatter";
NSString* const PXEChapterBackMatter    = @"backMatter";
NSString* const PXEChapterPageUUIDs     = @"pageUuids";


#pragma mark - Bookmarks macros

NSString* const PXEBookmarkData         = @"data";
NSString* const PXEBookmarks            = @"bookmarks";
NSString* const PXEBookmarkTitle        = @"title";
NSString* const PXEBookmarkUri          = @"uri";
NSString* const PXEBookmarkIdentityId   = @"identityId";
NSString* const PXEBookmarkContextId    = @"contextId";
NSString* const PXEBookmarkCreateTimeStamp = @"createdTimestamp";


#pragma mark - Annotation macros

NSString* const PXEAnnotationsUserTags = @"myContentsAnnotations";
NSString* const PXEAnnotationsSharedTags = @"sharedContentsAnnotations";


#pragma mark - Search macros

NSString* const PXESearchParentTag  = @"hits";
NSString* const PXESearchPageUrl    = @"url";
NSString* const PXESearchPageTitle  = @"title";
NSString* const PXESearchPageDesc   = @"contentPreview";
NSString* const PXESearchTotalPages = @"totalHits";
NSString* const PXESearchWordHits   = @"wordHits";


#pragma mark - Medias macros

NSString* const PXEMediaId          = @"id";
NSString* const PXEMediaMimeType    = @"type";
NSString* const PXEMediaContentFile = @"url";
NSString* const PXEMediaBreadCrumb  = @"breadcrumb";
NSString* const PXEMediaPageURL     = @"pageUrl";


@implementation PxePlayerParser

+(PxePlayerToc*) parseTOC:(NSDictionary *)contents
{
    PxePlayerToc  *toc = [[PxePlayerToc alloc] init];
    
    NSDictionary *navPoints = contents[@"ncx"][@"navMap"];
    toc.tocEntries = [NSArray arrayWithObject:navPoints];
    
    return toc;
}

+(PxePlayerBookShelf*) parseBookShelf:(NSDictionary*)bookshelf
{
    PxePlayerBookShelf* bookShelf = [[PxePlayerBookShelf alloc] init];
    
    NSArray* books = bookshelf[PXEBookShelfEntries];
    for (NSDictionary *book in books)
    {
        PxePlayerBook* pBook    = [[PxePlayerBook alloc] init];
        
        pBook.title             = book[PXEBookTitle];
        pBook.isbn              = book[PXEBookISBN];
        pBook.edition           = book[PXEBookEdition];
        pBook.coverUrl          = book[PXEBookCoverImageURL];
        pBook.thumbUrl          = book[PXEBookThumbURL];
        pBook.lastAccessTs      = book[PXEBooklastAccess];
        pBook.isActive          = [book[PXEBookActive] boolValue];
        pBook.expirationDate    = book[PXEBookExpirationDate];
        pBook.pageURLS          = [NSArray arrayWithArray:book[PXEBookTocUrl]];
        pBook.isExpired         = [book[PXEBookIsExpired] boolValue];
        pBook.isWarningPeriod   = [book[PXEBookIsWarningPeriod]boolValue];
        pBook.copyrightInfo     = book[PXEBookCopyRights];
        pBook.subject           = book[PXEBookSubject];
        pBook.publisher         = book[PXEBookPublisher];
        pBook.author            = book[PXEBookAuthor];
        pBook.date              = book[PXEBookDate];
        pBook.language          = book[PXEBookLanguage];
        pBook.b_description     = book[PXEBookDesc];
        pBook.isFavorite        = [book[PXEBookFavorite] boolValue];
        pBook.withAnnotations   = [book[PXEBookWithAnnotations] boolValue];
        pBook.bookUUID          = book[PXEBookUUID];
        
        [bookShelf.books addObject:pBook];
    }
    
    return bookShelf;
}

+(PxePlayerChapters*) parseChapter:(NSArray *)values
{
    PxePlayerChapters *chapters = [[PxePlayerChapters alloc] init];
    for (NSDictionary *chaps in values)
    {
        PxePlayerChapter *chapter = [[PxePlayerChapter alloc] init];
        chapter.chapterUUID = chaps[PXEChapterUUID];
        chapter.title = chaps[PXEChapterTitle];
        chapter.frontMatter = chaps[PXEChapterFrontMatter];
        chapter.backMatter = chaps[PXEChapterBackMatter];
        chapter.pageUUIDS = chaps[PXEChapterPageUUIDs];
        
        [chapters.chapters addObject:chapter];
    }
    
    return chapters;
}

+ (NSArray*) parseGlossary:(NSDictionary*)json
{
    NSDictionary *glossary = [json objectForKey:@"glossary"];
    DLog(@"glossary: %@", glossary);
    NSMutableArray *glossaryTerms = [NSMutableArray new];
    
    //there was one glossary that was returning <null> so i had to put in this null check.
    if(glossary != (id)[NSNull null] && glossary.count > 0)
    {
        for(NSString *key in glossary)
        {
            NSDictionary *glossaryDef = [glossary objectForKey:key];

            NSMutableDictionary *glossaryObj = [NSMutableDictionary new];
            
            if ([glossaryDef objectForKey:@"term"])
            {
                [glossaryObj setObject:[glossaryDef objectForKey:@"term"] forKey:@"term"];
            }
            if ([glossaryDef objectForKey:@"meaning"])
            {
                [glossaryObj setObject:[glossaryDef objectForKey:@"meaning"] forKey:@"definition"];
            }
            [glossaryObj setObject:key forKey:@"key"];
            
            [glossaryTerms addObject:glossaryObj];
        }
    }
    
    return  glossaryTerms;
}

+ (PxePlayerBookmarks*) parseBookmark:(NSDictionary*)values
{
    PxePlayerBookmarks *bookmarks = [[PxePlayerBookmarks alloc] init];
    NSArray* bookmarksArr = values[PXEBookmarks];
    bookmarks.contextId = values[PXEBookmarkContextId];
    bookmarks.identityId = values[PXEBookmarkIdentityId];
    
    for (NSDictionary *bm in bookmarksArr)
    {
        PxePlayerBookmark *bookmark = [[PxePlayerBookmark alloc] init];
        bookmark.uri            = bm[PXEBookmarkUri];
        bookmark.bookmarkTitle  = bm[PXEBookmarkTitle];
        bookmark.createdTimestamp = bm[PXEBookmarkCreateTimeStamp];
        
        [bookmarks.bookmarks addObject:bookmark];
    }
    
    return bookmarks;
}

+(PxePlayerCheckBookmark*)isPageBookmarked:(NSDictionary*)values
{
    PxePlayerCheckBookmark* bookmark = [[PxePlayerCheckBookmark alloc] init];
    BOOL bookmarked = NO;
    
    if ([values[@"isBookmarked"] boolValue])
    {
        bookmarked = YES;
    }
    
    bookmark.isBookmarked = @(bookmarked); //creates nsnumber from boolean
    
    return bookmark;
}

+(NSArray*) parseBulkAddBookmark:(NSArray*)values{

    NSMutableArray *bookmarks = [@[]mutableCopy];
    for(NSDictionary *bookmark in values){
        PxePlayerAddBookmark *addBookmark = [[PxePlayerAddBookmark alloc] init];
        
        addBookmark.bookmarkTitle   =   bookmark[PXEBookmarkTitle];
        addBookmark.contextID       =   bookmark[PXEBookmarkContextId];
        addBookmark.identityID      =   bookmark[PXEBookmarkIdentityId];
        addBookmark.uri             =   bookmark[PXEBookmarkUri];
        addBookmark.createdTimestamp =  bookmark[PXEBookmarkCreateTimeStamp];
        
        [bookmarks addObject:addBookmark];
    }

    return bookmarks;
}

+(PxePlayerBookmark*)parseAddBookmark:(NSDictionary*)values
{
    PxePlayerAddBookmark *addBookmark = [[PxePlayerAddBookmark alloc] init];
    
    addBookmark.bookmarkTitle   =   values[PXEBookmarkTitle];
    addBookmark.contextID       =   values[PXEBookmarkContextId];
    addBookmark.identityID      =   values[PXEBookmarkIdentityId];
    addBookmark.uri             =   values[PXEBookmarkUri];
    
    return addBookmark;
}

+(NSArray*)parseBulkDeleteBookmark:(NSDictionary*)values{

    NSMutableArray *bookmarks = [@[]mutableCopy];
    for(NSDictionary *bookmark in values){
        PxePlayerAddBookmark *addBookmark = [[PxePlayerAddBookmark alloc] init];
        
        addBookmark.bookmarkTitle   =   bookmark[PXEBookmarkTitle];
        addBookmark.contextID       =   bookmark[PXEBookmarkContextId];
        addBookmark.identityID      =   bookmark[PXEBookmarkIdentityId];
        addBookmark.uri             =   bookmark[PXEBookmarkUri];
        addBookmark.createdTimestamp =  bookmark[PXEBookmarkCreateTimeStamp];
        
        [bookmarks addObject:addBookmark];
    }
    
    return bookmarks;
    
}

+(PxePlayerBookmark*)parseDeleteBookmark:(NSDictionary*)values
{
    PxePlayerDeleteBookmark *bookmark = [[PxePlayerDeleteBookmark alloc] init];
    
    bookmark.uri        = values[PXEBookmarkUri];
    bookmark.contextID  = values[PXEBookmarkContextId];
    bookmark.identityID = values[PXEBookmarkIdentityId];
    
    return bookmark;
}

+(PxePlayerBookmark*)parseEditBookmark:(NSDictionary*)values
{
    PxePlayerEditBookmark *editBookmark = [[PxePlayerEditBookmark alloc] init];
    
    editBookmark.bookmarkTitle = values[PXEBookmarkTitle];
    editBookmark.uri   = values[PXEBookmarkUri];
    
    return editBookmark;
}

+ (PxePlayerAnnotationsTypes *) parseAnnotations:(NSDictionary*)values
{
    PxePlayerAnnotationsTypes *annotationsTypes = [PxePlayerAnnotationsTypes new];
    //    DLog(@"Annotations: %@", values);
    PxePlayerAnnotations *pxePlayerMyAnnotations;
    NSMutableArray *pxePlayerSharedAnnotationsArray = [NSMutableArray new];
    
    NSDictionary *myContentsAnnotations = (NSDictionary*)[values valueForKeyPath:PXEAnnotationsUserTags];
    if (myContentsAnnotations)
    {
        NSDictionary *myContentsAnnotationsDict = [myContentsAnnotations objectForKey:@"contentsAnnotations"];
        
        if(myContentsAnnotationsDict)
        {
            pxePlayerMyAnnotations = [self parseContentsAnnotations:myContentsAnnotationsDict forShared:NO];
            pxePlayerMyAnnotations.contextId = [myContentsAnnotations objectForKey:@"contextId"];
            pxePlayerMyAnnotations.annotationsIdentityId = [myContentsAnnotations objectForKey:@"identityId"];
        }
    }
    DLog(@"myContentsAnnotations: %@", pxePlayerMyAnnotations);
    NSArray *sharedContentsAnnotationsArray = (NSArray*)[values valueForKeyPath:PXEAnnotationsSharedTags];
    if (sharedContentsAnnotationsArray)
    {
        for (NSDictionary *sharedContentsAnnotations in sharedContentsAnnotationsArray)
        {
            NSDictionary *sharedContentsAnnotationsDict = [sharedContentsAnnotations objectForKey:@"contentsAnnotations"];
            
            if(sharedContentsAnnotationsDict)
            {
                PxePlayerAnnotations *pxePlayerSharedAnnotations = [self parseContentsAnnotations:sharedContentsAnnotationsDict forShared:YES];
                pxePlayerSharedAnnotations.contextId = [sharedContentsAnnotations objectForKey:@"contextId"];
                pxePlayerSharedAnnotations.annotationsIdentityId = [sharedContentsAnnotations objectForKey:@"identityId"];
                
                [pxePlayerSharedAnnotationsArray addObject:pxePlayerSharedAnnotations];
            }
        }
    }
    
    annotationsTypes.myAnnotations = pxePlayerMyAnnotations;
    annotationsTypes.sharedAnnotationsArray = pxePlayerSharedAnnotationsArray;
    
    return annotationsTypes;
}

+ (PxePlayerAnnotations *) parseContentsAnnotations:(NSDictionary *)contents forShared:(BOOL)shared
{
    PxePlayerAnnotations * pxePlayerAnnotations = [PxePlayerAnnotations new];
    
    pxePlayerAnnotations.isMyAnnotations = !shared;
    
    for (NSString *key in contents)
    {
        NSMutableArray *pxeAnnotationArray = [NSMutableArray new];
        
        NSDictionary *annotationsDict = [contents objectForKey:key];
        DLog(@"KEY: %@ ::: Annotations: %@", key, annotationsDict);
        NSArray *annotationsAR = (NSArray*)[annotationsDict objectForKey:@"annotations"];
        if(annotationsAR)
        {
            for (NSDictionary *annotationDict in annotationsAR)
            {
                PxePlayerAnnotation *pxePlayerAnnotation = [self parseAnnotation:annotationDict withKey:key];
                if(pxePlayerAnnotation)
                {
                    [pxeAnnotationArray addObject:pxePlayerAnnotation];
                }
            }
            [pxePlayerAnnotations.contentsAnnotations setObject:pxeAnnotationArray forKey:key];
        }
    }
    
    return pxePlayerAnnotations;
}

+ (PxePlayerAnnotation *) parseAnnotation:(NSDictionary*)values withKey:(NSString*)key
{
    PxePlayerAnnotation *pxePlayerAnnotation  = [PxePlayerAnnotation new];
    pxePlayerAnnotation.annotationDttm        = values[@"annotationDttm"];
    pxePlayerAnnotation.shareable             = [values[@"shareable"] boolValue];
    
    NSDictionary *data = values[@"data"];
    if(data)
    {
        // Sometimes the text contans hard returns
        NSString *note = data[@"noteText"];
        DLog(@"Incoming Note Data: %@", note);
        
        note = [note stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
        note = [note stringByReplacingOccurrencesOfString:@"\\n" withString:@"\r"];
        DLog(@"Outgoing Note Data: %@", note);
        pxePlayerAnnotation.noteText     = note;
        
        pxePlayerAnnotation.range        = data[@"range"];
        pxePlayerAnnotation.colorCode    = data[@"colorCode"];
        pxePlayerAnnotation.selectedText = data[@"selectedText"];
        
        if ([data[@"labels"] isKindOfClass:[NSArray class]])
        {
            pxePlayerAnnotation.labels       = data[@"labels"];
        }
    }
    
    pxePlayerAnnotation.queued          = NO;
    pxePlayerAnnotation.markedDelete    = NO;
    
    pxePlayerAnnotation.uri             = key;
    
    return pxePlayerAnnotation;
}

+(PxePlayerDeleteAnnotation*)parseDeleteAnnotation:(NSDictionary*)values
{
    PxePlayerDeleteAnnotation *notes = [[PxePlayerDeleteAnnotation alloc] init];
    
    /*notes.contextId = values[@"contextId"];
    notes.identityId = values[@"identityId"];
    notes.contentId = values[@"contentId"];
    notes.annotationDttm = values[@"annotationDttm"]; */
    
    return notes;
}


+(PxePlayerSearchPages*)parseBookSearch:(NSDictionary*)values
{
    PxePlayerSearchPages *searchPages = [[PxePlayerSearchPages alloc] init];
    
    NSArray* searchResults = values[PXESearchParentTag];
    for (NSDictionary *searchResult in searchResults)
    {
        PxePlayerSearchPage *searchPage = [[PxePlayerSearchPage alloc] init];
        searchPage.title = searchResult[PXESearchPageTitle];
        searchPage.textSnippet = searchResult[PXESearchPageDesc];
        searchPage.pageUrl = searchResult[PXESearchPageUrl];
        [searchPages.searchedItems addObject:searchPage];
    }

    searchPages.totalResults = [values[PXESearchTotalPages] intValue];
    searchPages.labels = values[PXESearchWordHits];
    return searchPages;
}

+(NSArray*)parseMedia:(NSDictionary*)values
{
    NSMutableArray *medias = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *totalMedias = values[@"media"];
    
    for (NSDictionary *result in totalMedias)
    {
        PxePlayerMedia *media = [[PxePlayerMedia alloc] init];
        
        media.mediaId = result[PXEMediaId];
        media.mimeType = result[PXEMediaMimeType];
        media.contentFile = result[PXEMediaContentFile];
        media.pageURL = result[PXEMediaPageURL];
        
        NSArray *mediaCrumb = result[PXEMediaBreadCrumb];
        
        if(mediaCrumb)
        {
            NSMutableArray *breadCrumbs = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSString *crumb in mediaCrumb)
            {
                PxePlayerMediaCrumb *mediaCr = [[PxePlayerMediaCrumb alloc] init];
                mediaCr.pageUrl = crumb;
                
                [breadCrumbs addObject:mediaCr];
            }
            
            media.breadCrumb = [NSArray arrayWithArray:breadCrumbs];
        }
        
        [medias addObject:media];
    }
    
    return medias;
}

@end
