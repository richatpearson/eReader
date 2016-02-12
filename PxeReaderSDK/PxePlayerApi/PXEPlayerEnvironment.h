//
//  PXEPlayerEnvironment.h
//  PxeReader
//
//  Created by Tomack, Barry on 10/28/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PxePlayerEnvironment)
{
    PxePlayerEnvironment_QA         = 0,
    PxePlayerEnvironment_Staging,
    PxePlayerEnvironment_Production,
    PxePlayerEnvironment_Dev
};

@interface PXEPlayerEnvironment : NSObject

/*---------------------------------------------------*/

/**
 PXE base url
 */
extern NSString* const PXE_Base_URL;
/**
 *  Glossary base url
 */
extern NSString* const PXE_Glossary_API;
/**
Login api url
 */
extern NSString* const PXE_Login_API;

/**
 Old Test login api url
 */
extern NSString* const PXE_Old_Login_API;

/**
 Bookshelf api url
 */
extern NSString* const PXE_Bookshelf_API;

/**
 Book navigations api url
 */
extern NSString* const PXE_BookNavigation_API;

/**
 Book table of content api url
 */
extern NSString* const PXE_BookTOC_API;

/**
 Custom navigation api url
 */
extern NSString* const PXE_BookCustomNavigation_API;

/**
 Book cover page api url
 */
extern NSString* const PXE_BookCoverPage_API;

/**
 Book chapters api url
 */
extern NSString* const PXE_BookChapters_API;

/**
 Book pages api url
 */
extern NSString* const PXE_BookPages_API;

/**
 Book bookmarks api url
 */
extern NSString* const PXE_Bookmarks_API;


/**
 Add bookmark api url
 */
extern NSString* const PXE_AddBookmarks_API;
/**
 *  Add Bulk bookmark api url
 */
extern NSString* const PXE_AddBulkBookmarks_API;
/**
 Book check bookmark api url
 */
extern NSString* const PXE_CheckBookmarks_API;

/**
 Book edit bookmark api url
 */
extern NSString* const PXE_EditBookmark_API;

/**
 Book delete bookmark api url
 */
extern NSString* const PXE_DeleteBookmark_API;

/**
 Book get annotations api url
 */
extern NSString* const PXE_GetAnnotations_API;

/**
 Book get content annotations api url
 */
extern NSString* const PXE_GetContentAnnotations_API;

/**
 Add annotations api url
 */
extern NSString* const PXE_AddAnnotations_API;

/**
 Update annotations api url
 */
extern NSString* const PXE_UpdateAnnotatons_API;

/**
 Delete annotation api url
 */
extern NSString* const PXE_DeleteAnnotations_API;

/**
 Add note api url
 */
extern NSString* const PXE_AddNote_API;

/**
 Delete note api url
 */
extern NSString* const PXE_DeleteNote_API;

/**
 Refresh auth token api url
 */
extern NSString* const PXE_RefreshAuthToken_API;

/**
 Search book content api url
 */
extern NSString* const PXE_SearchBookContent_API;

/**
 Initialize the search operation api url
 */
extern NSString* const PXE_InitSearch_API;

/**
 Retrieving media types api url
 */
extern NSString* const PXE_MediaTypes_API;

/**
 Retreiving all medias api url
 */
extern NSString* const PXE_AllMedia_API;

/**
 Retrieving media content api url
 */
extern NSString* const PXE_Media_API;

/**
 
 */
extern NSString* const PXE_CustomTOC_API;

/**
 
 */
extern NSString* const PXE_CustomBasketTOC_API;

/**
 
 */
extern NSString* const PXE_TOC_API;

/**
 
 */
extern NSString* const PXE_Manifest_API;

/*---------------------------------------------------*/

/**
 Method name POST
 */
extern NSString* const PXE_Post;// @"POST"

/**
 Method name GET
 */
extern NSString* const PXE_Get;//  @"GET"

/**
 Method name PUT
 */
extern NSString* const PXE_Put; // @"PUT"

/**
 Method name DELETE
 */
extern NSString* const PXE_Delete; // @"DELETE"


@end
