//
//  PxePlayerDownloadManagerDelegate.h
//  PxeReader
//
//  Created by Tomack, Barry on 8/4/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//
@class PxePlayerDownloadContext;

@protocol PxePlayerDownloadManagerDelegate <NSObject>

@optional

#pragma mark delegate methods
/**
 *  Updates App Delegate when all background session is complete. Sends a notification to the device.
 *  When using this the idea is to show a notifications
 *
 *  @param downloadTasks NSArray
 */
- (void) didFinishAllFileDownloadRequests:(NSArray *) downloadTasks;

/**
 
 */
- (void) downloadManagerDidFailWithError:(NSError*)error;

/**
 
 */
- (void) updateDownloadRequest:(PxePlayerDownloadContext*)downloadContext
             totalBytesWritten:(int64_t)totalBytesWritten
     totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

/**
 
 */
- (void) downloadRequest:(PxePlayerDownloadContext *)context
        didFailWithError:(NSError*)error;

/**
 
 */
- (void) didFinishFileDownloadRequest:(PxePlayerDownloadContext*)downloadContext;

#pragma mark DEPRECATED delgate methods
/**
 *  A constant update loop for UI to display download status. Returns back to the UI the written byte size and to the to be written byte size
 *
 *  @param ppcd                      PxePlayerContextDownload
 *  @param totalBytesWritten         int56_t
 *  @param totalBytesExpectedToWrite int56_t
 *  @param index                     int
 */
- (void) updateUIElements:(PxePlayerDownloadContext*)ppdc
        totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
                  atIndex:(int)index __attribute((deprecated("Use method updateDownloadRequest:totalBytesWritten:totalBytesExpectedToWrite: instead")));
/**
 *  A final update for UI elements to display finished marker.
 *
 *  @param ppdm  PxePlayerDownloadManager
 *  @param index int
 */
-(void)updateUIElementsFinished:(PxePlayerDownloadContext *)ppdc atIndex:(int)index;

/**
 *  Updates App Delegate when all background session is complete. Sends a notification to the device.
 *When using this the idea is to show a notifications
 *
 *  @param downloadTasks NSArray
 */
-(void)didFinishAllBackgroundSession:(NSArray *) downloadTasks;

/**
 *  Updates App Delegate when a single background session is complete. Sends a notification to the device
 When using this the idea is to show a notifications and set a badge on the app.
 *
 *  @param ppdm PxePlayerDownloadManager
 */
-(void)didFinishSingleBackgroundSession:(PxePlayerDownloadContext *)ppdc;
/**
 *  This is used to display any errors that the download manger might encounter when downloading a context
 *
 *  @param error   NSError
 */
- (void)pxePlayerDownloadManagerDidFailWithError:(NSError *)error;

/**
 
 */
- (void) updateDownloadStatus:(PxePlayerDownloadContext *)downloadContext;


@end
