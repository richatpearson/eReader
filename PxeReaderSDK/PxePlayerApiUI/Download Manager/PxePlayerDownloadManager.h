//
//  PxePlayerDownloadManager.h
//  PxeReader
//
//  Created by Tomack, Barry on 11/12/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerDownloadContext.h"
#import "PxePlayerDataInterface.h"
#import "PxePlayerUser.h"
#import "PxePlayerDownloadManagerDelegate.h"

#define BOOK_DOWNLOAD_COMPLETE_NOTIFICATION @"book_download_complete"
#define READER_SDK_PATH @"readersdk/latest" //TESTING with JS release - @"readersdk/new-UX"
#define PATH_OF_DOCUMENT [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]

/**
 *  PxePlayerDownloadManager is a singleton class that allows an application to download a context to the device.
 */
@interface PxePlayerDownloadManager : NSObject <NSURLSessionDelegate>

/**
 * Delegate used to update the UI of the client implementing this delegate
 */
@property (weak, nonatomic) id<PxePlayerDownloadManagerDelegate> delegate;

#pragma mark - init
/**
 *  Singleton for init the PxePlayerOfflineManager dont forget to set the user!
 *
 *  @return PxePlayerOfflineManager
 */
+(id)sharedInstance;

/**
 *  The first thing to do is pass in the PXE context data in the 
 *  PxePlayerDataInterface before attempting to download a Context 
 *  and its associated data.
 *
 *  @param dataInterface  PxePlayerDataInterface
 */
- (PxePlayerDownloadContext *) updateWithDataInterface:(PxePlayerDataInterface *)dataInterface;

#pragma mark - Public methods
/**
 Gets the available memory on the device
 */
-(double)getFreeDiskspace;

/**
 *  determines if the book has a downloaded file
 *
 *  @param contextId NSString
 *
 *  @return BOOL
 */
- (BOOL) searchForOfflineBookByContextId:(NSString*)contextId __attribute((deprecated("use checkForDownloadedFileByAssetId: instead")));

/**
 *  Searches for downloaded file using the asset id
 *
 *  @param contextId NSString
 *
 *  @return BOOL
 */
- (BOOL) checkForDownloadedFileByAssetId:(NSString*)assetId;

/**
 
 */
- (NSData *) readPage:(NSString*)pageURI
                error:(NSError**)error __attribute((deprecated("use readPage:dataInterface:error: instead")));;

/**
 
 */
- (NSData *) readPage:(NSString*)pageURI
        dataInterface:(PxePlayerDataInterface*)dataInterface
                error:(NSError**)error;

#pragma mark - UI Interactions

/**
 *  Called from the client UI to start or pause the download
 *
 *  @param downloadFile PxePlayerDownloadManager
 */
-(void)startOrPauseDownloadingSingleFile:(PxePlayerDownloadContext *)downloadFile __attribute((deprecated("use startOrPauseDownloadRequest: instead")));

/**
 
 */
- (void) startOrPauseDownloadRequest:(PxePlayerDownloadContext*) downloadContext;

/**
 *  Called from the client UI to stop a download
 *
 *  @param downloadFile PxePlayerContextDownload
 */
-(void)stopDownloading:(PxePlayerDownloadContext *)downloadFile __attribute((deprecated("use stopDownloadRequest: instead")));

/**
 
 */
- (void) stopDownloadRequest:(PxePlayerDownloadContext*) downloadContext;

/**
 *  Deprecated Delete a epub file from the device. Does not remove the contents from the database
 *
 *  @param ePubFileName NSString Usually the context ID with an epub extension (e.g.: 4PM49REXEKT.epub)
 *
 *  @return BOOL
 */
-(BOOL)deleteDownload:(NSString*)ePubFileName __attribute((deprecated("use deleteDownloadedFile: instead")));

/**
 *  Delete a epub file from the device. Does not remove the contents from the database
 *
 *  @param ePubFileName NSString Usually the context ID with an epub extension (e.g.: 4PM49REXEKT.epub)
 *
 *  @return BOOL
 */
- (BOOL) deleteDownloadedFile:(NSString*)ePubFileName;

/**
 *  Delete a epub file from the device. Does not remove the contents from the database
 *
 *  @param downloadContext PxePlayerDownloadContext
 *
 *  @return BOOL
 */
- (PxePlayerDownloadContext *) deleteDownloadedFileForAssetId:(NSString *)assetId;

/**
 *  Delete a epub file from the device. Does not remove the contents from the database
 *
 *  @param downloadContext PxePlayerDownloadContext
 *
 *  @return BOOL
 */
- (PxePlayerDownloadContext *) deleteDownloadedFileForContext:(PxePlayerDownloadContext*)downloadContext;

/**
 *  Returns the PxePlayerDownloadContext object based on a contextId
 *
 *  @param contextId NSString
 *
 *  @return PxePlayerDownloadContext
 */
- (PxePlayerDownloadContext *) getDownloadContextWithContextId:(NSString*)contextId __attribute((deprecated("use getDownloadContextWithAssetId: instead")));;

/**
 *  Returns the PxePlayerDownloadContext object based on a downloadId (book id, chapter id, etc)
 *
 *  @param assetId NSString
 *
 *  @return PxePlayerDownloadContext
 */
- (PxePlayerDownloadContext *) getDownloadContextWithAssetId:(NSString*)assetId;

/**
 
 */
- (PxePlayerDataInterface *) getDataInterfaceWithContextId:(NSString*)contextId;

/**
 
 */
- (BOOL) haveDownloadedPXEJS;

/**
 
 */
- (void) setOnlineBaseURL:(NSString *)baseURL forContextId:(NSString*)contextId;

@end
