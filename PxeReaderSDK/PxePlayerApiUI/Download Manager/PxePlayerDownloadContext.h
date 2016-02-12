//
//  PxePlayerDownloadContext.h
//  PxeReader
//
//  Created by Mason, Darren J on 11/12/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PxePlayerDownloadStatus)
{
    PxePlayerDownloadPending        = 0,
    PxePlayerDownloadPaused         = 1,
    PxePlayerDownloadingEpubFile    = 2,
    PxePlayerDownloadingTOC         = 3,
    PxePlayerDownloadingMetaData    = 4,
    PxePlayerDownloadingJS          = 5,
    PxePlayerDownloadPageStatus     = 6,
    PxePlayerDownloadCompleted      = 7,
    PxePlayerDownloadError          = 8
};

/**
 *  This class stores the details of a downloading book
 */
@interface PxePlayerDownloadContext : NSObject  /*<NSCoding>*/
/**
 * The id of the context a suppliec by PXE services
 */
@property (nonatomic,strong) NSString *contextId;
/**
 * Generic and unique asset identifier; This could be book id or a chapter id
 */
@property (nonatomic, strong) NSString *assetId;
/**
 * Title for the ePub file (eg, "Chapter 2: Washington Crosses the Delaware")
 */
@property (nonatomic, strong) NSString *fileTitle;
/**
 * Name of the epub
 */
@property (nonatomic, strong) NSString *fileName;
/**
 * URL String of the downloaded file
 */
@property (nonatomic, strong) NSString *downloadSource;
/**
 * URL String of the toc and content
 */
@property (nonatomic, strong) NSString *onlineBaseUrl;
/**
 * A NSURLSessionDownloadTask object that will be used to keep a strong reference to the download task of a file.
 */
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
/**
 * A NSData object that keeps the state of the data downloaded so that if we resume it starts from here
 */
@property (nonatomic, strong) NSData *taskResumeData;
/**
 * Keeps track of the bits that have been downloaded
 */
@property (nonatomic) double downloadProgress;
/**
 * Keeps track of state of the download if it's currently downloading
 */
@property (nonatomic) BOOL isDownloading;
/**
 *  Keeps track of the state of the download if its pause or not
 */
@property (nonatomic) BOOL isPaused;
/**
 * Tells you when your download is done.
 */
@property (nonatomic) BOOL downloadComplete;
/**
 * When a download task is initiated, the NSURLSession assigns it a unique identifier so it can be distinguished among others. 
 * The identifier values start from 0. In this property, we will assign the task identifier value of the downloadTask property 
 * (even though the downloadTask object has its own taskIdentifier property) just for our own convenience during implementation.
 */
@property (nonatomic) unsigned long taskIdentifier;

/**
 * Current PxePlayerDownloadStatus
 * PxePlayerDownloadPending        = 0, - No local Epub file
 * PxePlayerDownloadPaused         = 1, - Download was paused (only ePubFile can be paused at this time).
 * PxePlayerDownloadingEpubFile    = 2, - Epub file is currently downloading
 * PxePlayerDownloadingTOC         = 3, - TOC is downloading and processing
 * PxePlayerDownloadingMetaData    = 4, - Annotations, bookmarks, and glossary are being downloaded and processed
 * PxePlayerDownloadJS             = 5, - Downloading the javscript SDK
 * PxePlayerDownloadPageStatus     = 6, - Update the isDownloaded status for the pages in the book
 * PxePlayerDownloadCompleted      = 7, - Epub file and all necessary data have been downloaded and are ready to be viewed
 * PxePlayerDownloadError          = 8  - An error occured during the download process.
 */
@property (nonatomic, assign) NSUInteger downloadStatus;

// Download Data for local persistence
@property (nonatomic, assign) BOOL epubDownloadComplete;
@property (nonatomic, assign) BOOL tocDownloadComplete;
@property (nonatomic, assign) BOOL annotationDownloadComplete;
@property (nonatomic, assign) BOOL bookmarkDownloadComplete;
@property (nonatomic, assign) BOOL glossaryDownloadComplete;
@property (nonatomic, assign) BOOL pxeJSDownloadComplete;
@property (nonatomic, assign) BOOL downloadPageStatusUpdated;

/**
 *   Original Init object with title and URL string
 *
 *  @param title     title of context
 *  @param source    uri of context
 *  @param pxeSource uri of pxe
 *
 *  @return PxePlayerDownloadContext
 */
- (id) initWithFileTitle:(NSString*)title
          downloadSource:(NSString *)source
           withPxeSource:(NSString *)pxeSource
               contextId:(NSString *)contextId
           onlineBaseUrl:(NSString *)onlineBaseUrl __attribute((deprecated("You can still use this method if you're downlaoding the entire book")));

/**
 *   Init object with title and URL string
 *
 *  @param title     title of context
 *  @param source    uri of context
 *  @param contextId unique Id for book/context
 *  @param assetId   inique ID for asset (i.e.: chapters have a unique asset id, entire book assetId would be the same as the context Id
 *  @param onlineBaseURL the online base url for the context so that toc, annotations, bookmarks, and glossary can be downlaoded
 *
 *  @return PxePlayerDownloadContext
 */
- (id) initWithFileTitle:(NSString*)title
          downloadSource:(NSString *)source
               contextId:(NSString *)contextId
                 assetId:(NSString *)assetId
           onlineBaseUrl:(NSString *)onlineBaseUrl;


@end
