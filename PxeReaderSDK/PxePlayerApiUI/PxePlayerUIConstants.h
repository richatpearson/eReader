//
//  PXEPlayerUIConstants.h
//  PXEReaderApiUI
//
//  Created by Saro Bear on 05/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

//TODO: It's starting to get ridiculous to expect client app to listen for all those different error notifcations.
// Should probably change to PXEPLAYER_ERROR_NOTIFICATION and then just include the error in the userInfo dictionary

/**
 A macro fucntion which returns the resource bundle path with resource name appended
 __FILENAME__ file name of the resource
 */
#define BUNDLE_FILE(__FILENAME__) [NSString stringWithFormat:@"%@",__FILENAME__]

/**
 A macro for naming the core data sqlite file
 */
#define CD_DIR    @"CD_Sqlite"

/**
 A macro for indentifying the search id
 */
#define PXE_SEARCH_ID                   @"searchId"

/**
 A macro for book loaded event name added into the NSNotifationCentre
 */
#define PXEPLAYER_BOOK_LOADED           @"onBookLoaded"

/**
 A macro for book loading failed event name added into the NSNotifationCentre
 */
#define PXEPLAYER_BOOK_FAILED           @"onBookLoadingFailed"

/**
 A macro for page loaded event name added into the NSNotifationCentre
 */
#define PXEPLAYER_PAGE_LOADED           @"onPageLoaded"

/**
 A macro for page loading event name added into the NSNotifationCentre
 */
#define PXEPLAYER_PAGE_LOADING          @"onPageLoading"

/**
 A macro for book loading failed event name added into the NSNotifationCentre
 */
#define PXEPLAYER_PAGE_FAILED           @"onPageLoadingFailed"

/**
 A macro for page not found event name added into the NSNotifationCentre
 */
#define PXEPLAYER_PAGE_NOT_FOUND        @"pageNotFound"

/**
 A macro for page set up after loading and ready to do scrolling, such as scroll to highlight
 */
#define PXEPLAYER_PAGE_SETUP_COMPLETE @"onPageSetUpComplete"

/**
 A macro for book reading completed event name added into the NSNotifationCentre
 */
#define PXEPLAYER_BOOK_COMPLETED        @"onBookCompleted"

/**
 A macro for network not found event name
 */
#define PXEPLAYER_INTERNET_WEAK         @"networkNotFound"

/**
 A macro for annotation remove failure event name added into the NSNotifationCentre
 */
#define PXEPLAYER_ANNOTATION_FAILED     @"onAnnotationRemoveFailure"

/**
 A macro for annotation characters exceeed max
 */
#define PXEPLAYER_ANNOTATION_MAX_CHAR     @"onAnnotationMaxChar"

/**
 A macro for annotation added event name added into the NSNotifationCentre
 */
#define PXEPLAYER_ADD_ANNOTATION_EVENT      @"onAnnotationAdd"

/**
 A macro for annotation updated event name added into the NSNotifationCentre
 */
#define PXEPLAYER_UPDATE_ANNOTATION_EVENT   @"onAnnotationUpdate"

/**
 A macro for annotation remove failure event name added into the NSNotifationCentre
 */
#define PXEPLAYER_REMOVE_ANNOTATION_EVENT   @"onAnnotationRemove"

/**
 A macro for search initialized event name added into the NSNotifationCentre
 */
#define PXEPLAYER_SEARCH_INITIALIZED    @"SearchInitialized"

/**
 A macro for search intitialization failed event name added into the NSNotifationCentre
 */
#define PXEPLAYER_SEARCH_INIT_FAILED    @"SearchInitFailed"

/**
 A macro for loaded page event name added into the NSNotifationCentre
 */
#define PXEPLAYER_LOADED_PAGE           @"Loaded_Page"

/**
 A macro for failed loading page URL event name added into the NSNotifationCentre
 */
#define PXEPLAYER_FAILED_PAGE           @"FailedPage_URL"

/**
 A macro for check history found in the stack event name added into the NSNotifationCentre
 */
#define PXEPLAYER_IS_HISTORY        @"IsHistory"

/**
 A macro for gadget event name added into the NSNotifationCentre
 */
#define PXEPLAYER_GADGET_EVENT              @"onGadgetClick"

/**
 A macro for key name for page content auto fit swipe option in UIWebView
 */
#define PXEPLAYER_DID_WEBVIEW_ROTATE         @"webViewDidRotate"

/**
  A macro for key name for page content font size
 */
#define PXEPLAYER_DEFAULT_FONTSIZE 14

/**
 A macro for key name for page content day theme
 */
#define DEFAULT_THEME @"day"

/**
 A macro for key name for page content default theme
 */
#define DEFAULT_THEME_2 @"default"

/**
 A macro for key name for page content sepia theme
 */
#define SEPIA_THEME @"sepia"

/**
 A macro for key name for page content night theme
 */
#define NIGHT_THEME @"night"

/**
 A macro for key name for pxe reader resources file
 */
#define kDataBundleName @"PxeReaderResources"

/**
 A macro for key name for page content default theme
 */
#define PXEPLAYER_DEFAULT_THEME DEFAULT_THEME

/**
 A macro for the default value of  annotate
 */
#define PXEPLAYER_DEFAULT_ANNOTATE  YES
/**
 A macro for the default value of  annotate
 */
#define PXEPLAYER_DEFAULT_MATHML  NO
/**
 
 */
#define PXEPLAYER_VERSION_UPDATE_FAILED @"PxePlayerVersionUpdateFailed"

/**
 A macro for the default value of print page jump support
 */
#define PXEPLAYER_DEFAULT_PRINTPAGEJUMPSUPPORT  NO

/**
 A macro for time in seconds which loading bar would render
 */
#define TIME_TO_REMOVE_LOADING 10.0

#define PXEPLAYER_TOP @"TOP"

#define PXEPLAYER_DIRECTION_UP @"UP"

#define PXEPLAYER_DIRECTION_DOWN @"DOWN"

#define PXEPLAYER_BOTTOM @"BOTTOM"

#define PXEPLAYER_DIRECTION @"direction"

#define PXEPLAYER_POSITION @"position"

#define PXEPLAYER_FIRSTPAGE @"firstPage"

#define PXEPLAYER_LASTPAGE @"lastPage"

#define PXEPLAYER_MIDDLEPAGE @"middlePage"

#define PXEPLAYER_BOOK_TITLE_AS_ASSET @"Download book"

#define PXEPLAYER_NEXTPAGE @"nextPage"

#define PXEPLAYER_PREVIOUSPAGE @"previousPage"

#define PXE_MIN_FONT_SIZE ((int) 10)
#define PXE_MAX_FONT_SIZE ((int) 28)

typedef NS_ENUM(NSInteger, PxePlayerNavigationDirection)
{
    PxePlayerNavNext        = 0,
    PxePlayerNavPrevious    = 1
};

#define PXEPLAYER_ERROR @"error"

/**
 Macro for identifing prior iOS version(s)
 */
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

