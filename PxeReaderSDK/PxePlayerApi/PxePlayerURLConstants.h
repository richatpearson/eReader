//
//  URLConstants.h
//  NTApi
//
//  Created by Satyanarayana on 28/06/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#ifndef NTApi_URLConstants_h
#define NTApi_URLConstants_h

///**
// An extern variable for web api url
// */
//extern NSString *webAPIURL;
//
///**
// An extern variable for CM services api url
// */
//extern NSString *cmAPIURL;
//
///**
// An extern variable for pxe services url
// */
//extern NSString *pxeServicesURL;
//
///**
// A macro for base url string
// */
//#define BASEURL_STRING @"PxePlayerBaseURL"
//
///**
// A macro for base url
// */
//#define BASE_URL @""
//
///**
// A macro for base table of content url
// */
//#define BASE_TOC_URL [[NSUserDefaults standardUserDefaults] valueForKey:BASEURL_STRING]
//
/**
 A macro for login api url - Used by eText WebClient
 DEPRECATED - Use PXEPlayerEnvironment.PXE_Login_API
 */
#define LOGIN_API  @"nextext-api/api/account/login?withIdpResponse=true"
//
///**
// A macro for test login api url
// */
//#define OLD_LOGIN_API  @"nextext-api/api/nextext/users/%@/login"
//
///**
// A macro for bookshelf api url
// */
//#define BOOK_SHELF_API @"nextext-api/api/nextext/users/%@/bookshelf"
//
///**
// A macro for book navigations api url
// */
//#define BOOK_NAVIGATIONS_API @"nexttextweb/api/users/%@/books/%@/navigations"
//
///**
// A macro for book table of content api url
// */
//#define BOOK_TOC_API @"nexttextweb/api/books/%@/navigations/jsonArray?type=toc"
//
///**
// A macro for custom navigation api url
// */
//#define BOOK_CUSTOM_NAVIGATION_API @"nexttextweb/api/books/%@/navigations/jsonArray?type=toc&origin=origin"
//
///**
// A macro for book cover page api url
// */
//#define BOOK_COVER_PAGE_API @"nexttextweb/api/books/%@/coverPage/json?userUuid=%@"
//
///**
// A macro for book chapters api url
// */
//#define BOOK_CHAPTERS_API @"nexttextweb/api/books/%@/chapters"
//
///**
// A macro for book pages api url
// */
//#define BOOK_PAGES_API @"nexttextweb/api/books/%@/chapters/%@/pages/%@/json"
//
///**
// A macro for book bookmarks api url
// */
//#define BOOK_BOOKMARKS_API @"%@services-api/api/context/%@/identities/%@/bookmarks"
//
///**
// A macro for add bookmark api url
// */
//#define BOOK_ADD_BOOKMARK_API @"%@services-api/api/context/%@/identities/%@/bookmarks"
//
///**
// A macro for book check bookmark api url
// */
//#define BOOK_CHECK_BOOKMARK_API @"%@services-api/api/context/%@/identities/%@/bookmarks?uri=%@"
//
///**
// A macro for book edit bookmark api url
// */
//#define BOOK_EDIT_BOOKMARK_API @"%@services-api/api/context/%@/identities/%@/bookmarks"
//
///**
// A macro for book delete bookmark api url
// */
//#define BOOK_DELETE_BOOKMARK_API @"%@services-api/api/context/%@/identities/%@/bookmarks?uri=%@"
//
///**
// A macro book get annotations api url
// */
//#define BOOK_GET_ANNOTATIONS_API @"%@services-api/api/context/%@/identities/%@/annotations?withShared=%@"
//
///**
// A macro for book get content annotations api url
// */
//#define BOOK_GET_CONTENT_ANNOTATIONS_API @"%@services-api/api/context/%@/identities/%@/annotations?uri=%@&withShared=%@"
//
///**
// A macro for add annotations api url
// */
//#define BOOK_ADD_ANNOTATION_API @"%@services-api/api/context/%@/identities/%@/annotations"
//
///**
// A macro for update annotations api url
// */
//#define BOOK_UPDATE_ANNOTATION_API @"%@services-api/api/context/%@/identities/%@/annotations"
//
///**
// A macro for book delete annotation api url
// */
//#define BOOK_DELETE_ANNOTATION_API @"%@services-api/api/context/%@/identities/%@/annotations?contentId=%@&annotationDttm=%@"
//
///**
// A macro for book add note api url
// */
//#define BOOK_ADD_NOTE_API @"%@nexttextweb/api/users/%@/books/%@/chapters/%@/pages/%@/notes"
//
///**
// A macro for book delete api url
// */
//#define BOOK_DELETE_NOTE_API @"%@nexttextweb/api/users/%@/books/%@/chapters/%@/pages/%@/notes/%@"
//
///**
// A macro for refresh auth token api url
// */
//#define REFRESH_AUTHTOKEN_API @"/users/identity/refresh"
//
///**
// A macro for search book content api url
// */
//#define SEARCH_BOOK_CONTENT @"%@pxereader-cm/api/cm/search/?indexId=%@&q=%@&s=%ld&n=%ld"
//
///**
// A macro for initialise the search operation api url
// */
//#define SEARCH_INIT @"%@pxereader-cm/api/cm/ingest"
//
///**
// A macro for retrieving media types api url
// */
//#define MEDIA_TYPES @"nexttextweb/api/books/%@/media-types"
//
///**
// A macro for retreiving all medias api url
// */
//#define ALL_MEDIAS @"nexttextweb/api/books/%@/allMedias"
//
///**
// A macro for retrieving media content api url
// */
//#define MEDIA @"%@pxereader-cm/api/cm/navigation?type=%@&indexId=%@&s=%ld&n=%ld"
//
///**
// A macro for sms authentication api url
// */
//#define SMS_AUTHENTICATION @"http://login.cert.pearsoncmg.com/sso/SSOServlet2?cmd=login&okurl=http://certapachelb-344900366.us-west-1.elb.amazonaws.com/nexttextweb/nexttextAuthenticationSuccessMobile.htm?values=scenario::1::nextTextSession::nextTextSession::invokeType::standalone::isIPad::N&errurl=http://certapachelb-344900366.us-west-1.elb.amazonaws.com/nexttextweb/nexttextIntegrationErrorMobile.htm?values=cause::loginfailure::scenario::1::nextTextSession::nextTextSession::invokeType::standalone::isIPad::N&loginurl=http://certapachelb-344900366.us-west-1.elb.amazonaws.com/nexttextweb/nexttextIntegrationErrorMobile.htm?values=cause::login::scenario::1::nextTextSession::nextTextSession::invokeType::standalone::isIPad::N&siteid=11444&isCourseAware=N&encPassword=N&loginname=%@&password=%@"
//
///**
// A macro for rumba authentication api url
// */
//#define RUMBA_AUTHENTICATION @"https://sso.rumba.int.pearsoncmg.com/sso/loginService?service=http://nexttextint1-147866391.us-west-1.elb.amazonaws.com/nexttextweb/schoolHomeMobile.htm&gateway=true&username=%@&password=%@"
//
///**
// A macro for table of content test api url
// */
//#define TOC_TEMP_URL @"http://eps.prsn.us/tutorial/api/file/982668d3-d3e7-43b1-8719-52d9445be872/content/planetepub/ChangingPlanet/OPS/toc.ncx"

#pragma mark - Error Codes

/**
 A macro for error code server error url
 */
#define kErrServerError 2

/**
 A macro for error code wrong JSON format
 */
#define kErrWrongJSON 3

/**
 A macro for error code wrong JSON data composed to post
 */
#define kErrWrongJSONPost 4

/**
 A macro for error code server request denial
 */
#define kErrRequestDenial 5

/**
 A macro for error code network down
 */
#define kErrNetworkDown 6

/**
 A macro for error code parse error occured
 */
#define kParseError 7

/**
 A macro for method name POST - Used by eText WebClient
 DEPRECATED - Use PXEPlayerEnvironment.PXE_Post
 */
//#define POST @"POST"
//
///**
// A macro for method name GET
// */
//#define GET  @"GET"
//
///**
// A macro for method name PUT
// */
//#define PUT @"PUT"
//
///**
// A macro for method name DELETE 
// */
//#define DELETE @"DELETE"

#endif
