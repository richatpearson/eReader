//
//  PXEPlayerEnvironment.m
//  PxeReader
//
//  Created by Tomack, Barry on 10/28/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PXEPlayerEnvironment.h"

@implementation PXEPlayerEnvironment

NSString* const PXE_Base_URL                    = @"PxePlayerBaseURL";

//TODO: Remove nextext references
NSString* const PXE_Glossary_API                = @"%@pxereader-cm/api/cm/glossary?indexId=%@";
NSString* const PXE_Login_API                   = @"nextext-api/api/account/login?withIdpResponse=true";
NSString* const PXE_Old_Login_API               = @"nextext-api/api/nextext/users/%@/login";
NSString* const PXE_Bookshelf_API               = @"nextext-api/api/nextext/users/%@/bookshelf";
NSString* const PXE_BookNavigation_API          = @"nexttextweb/api/users/%@/books/%@/navigations";
NSString* const PXE_BookTOC_API                 = @"nexttextweb/api/books/%@/navigations/jsonArray?type=toc";
NSString* const PXE_BookCustomNavigation_API    = @"nexttextweb/api/books/%@/navigations/jsonArray?type=toc&origin=origin";
NSString* const PXE_BookCoverPage_API           = @"nexttextweb/api/books/%@/coverPage/json?userUuid=%@";
NSString* const PXE_BookChapters_API            = @"nexttextweb/api/books/%@/chapters";
NSString* const PXE_BookPages_API               = @"nexttextweb/api/books/%@/chapters/%@/pages/%@/json";
NSString* const PXE_Bookmarks_API               = @"%@services-api/api/context/%@/identities/%@/bookmarks";
NSString* const PXE_AddBookmarks_API            = @"%@services-api/api/context/%@/identities/%@/bookmarks";
NSString* const PXE_AddBulkBookmarks_API        = @"%@services-api/api/context/identity/bookmarks";
NSString* const PXE_CheckBookmarks_API          = @"%@services-api/api/context/%@/identities/%@/bookmarks?uri=%@";
NSString* const PXE_EditBookmark_API            = @"%@services-api/api/context/%@/identities/%@/bookmarks";
NSString* const PXE_DeleteBookmark_API          = @"%@services-api/api/context/%@/identities/%@/bookmarks?uri=%@";
NSString* const PXE_GetAnnotations_API          = @"%@services-api/api/context/%@/identities/%@/annotations?withShared=%@";
NSString* const PXE_GetContentAnnotations_API   = @"%@services-api/api/context/%@/identities/%@/annotations?uri=%@&withShared=%@";
NSString* const PXE_AddAnnotations_API          = @"%@services-api/api/context/%@/identities/%@/annotations";
NSString* const PXE_UpdateAnnotatons_API        = @"%@services-api/api/context/%@/identities/%@/annotations";
NSString* const PXE_DeleteAnnotations_API       = @"%@services-api/api/context/%@/identities/%@/annotations?contentId=%@&annotationDttm=%@";
NSString* const PXE_AddNote_API                 = @"%@nexttextweb/api/users/%@/books/%@/chapters/%@/pages/%@/notes";
NSString* const PXE_DeleteNote_API              = @"%@nexttextweb/api/users/%@/books/%@/chapters/%@/pages/%@/notes/%@";
NSString* const PXE_RefreshAuthToken_API        = @"/users/identity/refresh";
NSString* const PXE_SearchBookContent_API       = @"%@pxereader-cm/api/cm/search?indexId=%@&q=%@&s=%ld&n=%ld&_=1414709318925";
NSString* const PXE_InitSearch_API              = @"%@pxereader-cm/api/cm/ingest";
NSString* const PXE_MediaTypes_API              = @"nexttextweb/api/books/%@/media-types";
NSString* const PXE_AllMedia_API                = @"nexttextweb/api/books/%@/allMedias";
NSString* const PXE_Media_API                   = @"%@pxereader-cm/api/cm/navigation?type=%@&indexId=%@&s=%ld&n=%ld";
NSString* const PXE_CustomTOC_API               = @"%@services-api/content/1/toc?includesContext=true&tocUrl=%@";
NSString* const PXE_CustomBasketTOC_API         = @"%@services-api/api/toc?url=%@&class=los&id=learning-objectives";
NSString* const PXE_TOC_API                     = @"%@services-api/api/context/%@/toc?itemContext=false&metadata=true&provider=%@&providerType=%@&pageContext=%@&removeDuplicates=%@";
NSString* const PXE_Manifest_API                = @"nextext-api/download/manifest/books/%@";

/*---------------------------------------------------*/

NSString* const PXE_Post    = @"POST";
NSString* const PXE_Get     = @"GET";
NSString* const PXE_Put     = @"PUT";
NSString* const PXE_Delete  = @"DELETE";

@end
