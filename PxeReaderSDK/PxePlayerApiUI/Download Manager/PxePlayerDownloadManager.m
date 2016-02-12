//
//  PxePlayerDownloadManager.m
//  PxeReader
//
//  Created by Tomack, Barry on 11/12/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//
#import "PxePlayerDownloadManager.h"
#import "PxePlayerDownloadContext.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import "PxePlayer.h"
#import "PXEPlayerEnvironment.h"
#import "PXEPlayerMacro.h"
#import "PxePlayerBookmarks.h"
#import "PxePlayerBookmark.h"
#import "PxePlayerDataManager.h"
#import "PxeContext.h"
#import "PxePlayerInterface.h"
#import "PxePlayerNCXCDParser.h"
#import "PxePlayerError.h"
#import "PxePlayerUIConstants.h"
#import "Reachability.h"
#import "PxePlayerRestConnector.h"
#import "PxePlayerDataFetcher.h"
#import "PxePageDetail.h"

#define PXE_JS_RELATIVE_PATH [NSString stringWithFormat:@"%@/dest/pxereader.zip", READER_SDK_PATH]

typedef void (^DMCompletionHandler)(BOOL didComplete, NSError* error);

@interface PxePlayerDownloadManager()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURL *libraryDirectory;
@property (nonatomic, strong) NSString *pxeJS_Path;

/**
 *  An array of PxePlayerDownloadContexts
 */
@property (nonatomic, strong) NSMutableArray *arrPxeDownloadContext;

/**
 *  An array of PxePlayerContextDownload's
 */
@property (nonatomic, strong) NSMutableArray *arrPxeDataInterface;

- (BOOL) isPageDownloaded:(NSString*)relativePath;
- (void) updateDownloadStatusForAsset:(NSString*)assetId isDownloaded:(BOOL)isDownloaded;
- (void) unarchiveDownloadContexts;

@end

@implementation PxePlayerDownloadManager

#pragma mark init methods

static PxePlayerDownloadManager *sharedPxePlayerDownloadManager = nil;

+ (id) sharedInstance
{
    if (sharedPxePlayerDownloadManager == nil)
    {
        sharedPxePlayerDownloadManager = [[super allocWithZone:NULL] init];
    }
    return sharedPxePlayerDownloadManager;
}

- (id)init
{
    if (self = [super init])
    {
        self.arrPxeDownloadContext = [NSMutableArray new];
        
        self.arrPxeDataInterface = [NSMutableArray new];
        
        //add anyting you want
        
        NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
        self.libraryDirectory = [URLs objectAtIndex:0];
        
        NSURLSessionConfiguration *sessionConfiguration;
        
        if ([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)])
        {
            sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.pearson.pxeApp"];
        } else  {
            sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.pearson.pxeApp"];
        }
        //set up the session object
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        
        // PXE JS Source
        self.pxeJS_Path = [NSString stringWithFormat:@"%@%@", [[PxePlayer sharedInstance] getPxeServicesEndpoint], PXE_JS_RELATIVE_PATH];
    
        // Notifications needed for archiving downloadContexts
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(archiveDownloadContexts)
                                                     name:@"UIApplicationDidEnterBackgroundNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(archiveDownloadContexts)
                                                     name:@"UIApplicationWillTerminate"
                                                   object:nil];
        
        // Unarchive DownloadContexts
        [self unarchiveDownloadContexts];
    }
    return self;
}

#pragma mark -add contexts

- (PxePlayerDownloadContext *) updateWithDataInterface:(PxePlayerDataInterface *)dataInterface
{
    DLog(@"contextURL: %@", dataInterface.ePubURL);
    DLog(@"contextID: %@", dataInterface.contextId);
    DLog(@"assetID: %@", dataInterface.assetId);
    DLog(@"indexID: %@", dataInterface.indexId);
    [self.arrPxeDataInterface addObject:dataInterface];
    
    [[PxePlayer sharedInstance] dispatchGAIEventWithCategory:[dataInterface getClientAppName]
                                                      action:@"updateDataInterfaceForDownloading"
                                                       label:[dataInterface getAssetId]
                                                       value:nil];
    
    PxePlayerDownloadContext *pxePlayerDownloadContext = [[PxePlayerDownloadContext alloc] initWithFileTitle:dataInterface.contextTitle
                                                                                              downloadSource:dataInterface.ePubURL
                                                                                                   contextId:dataInterface.contextId
                                                                                                     assetId:dataInterface.assetId
                                                                                               onlineBaseUrl:dataInterface.onlineBaseURL];
    /**
     If it exists then just use it because we are updating it in other spots with some fun information.
     **/
    PxePlayerDownloadContext *existingPxePlayerDownloadContext = [self getDownloadContextWithAssetId:pxePlayerDownloadContext.assetId];
    if(existingPxePlayerDownloadContext)
    {
        DLog(@"It Exists");
        return existingPxePlayerDownloadContext;
    }
    
    [self storeDownloadContext:pxePlayerDownloadContext];
    
    [[PxePlayer sharedInstance] createCurrentUserFromDataInterface:dataInterface];
    
    [[PxePlayerDataManager sharedInstance] createCurrentContextWithDataInterface:dataInterface
                                                                     currentUser:[[PxePlayer sharedInstance] currentUser]
                                                                     withHandler:^(PxeContext *pxeContext, NSError *err){
                                                                         if (err)
                                                                         {
                                                                             //TODO: What to do if error creating context?
                                                                             DLog(@"ERROR UPDATING DATAINTERFACE: %@", err);
                                                                         }
                                                                     }];
    return pxePlayerDownloadContext;
}

#pragma mark - public Start Stop Delete functions

- (void)startOrPauseDownloadingSingleFile:(PxePlayerDownloadContext*)downloadContext
{
    [self startOrPauseDownloadRequest:downloadContext];
}

- (void) startOrPauseDownloadRequest:(PxePlayerDownloadContext *)downloadContext
{
    DLog(@"DOWNLOADING FILE: %@", downloadContext);
    // The isDownloading property of the PxePlayerDownloadContext object defines whether a downloading should be started
    // or be stopped.
    if (!downloadContext.isDownloading)
    { //START
        // This is the case where a download task should be started.
        downloadContext.downloadStatus = PxePlayerDownloadingEpubFile;
        // Create a new task, but check whether it should be created using a URL or resume data.
        if (downloadContext.taskIdentifier == -1)
        { // NEW
            
            // If the taskIdentifier property of the PxePlayerDownloadContext object has value -1, then create a new task
            // providing the appropriate URL as the download source.
            downloadContext.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:downloadContext.downloadSource]];
            
            // Keep the new task identifier.
            downloadContext.taskIdentifier = downloadContext.downloadTask.taskIdentifier;
            
            // Start the task.
            [downloadContext.downloadTask resume];
            
            [self downloadPXEJSForContext:downloadContext withCompletionHandler:^(BOOL didComplete, NSError *error) {
                DLog(@"Did Download Pxe sdk %d",didComplete);
            }];
        }
        else
        { //RESUME
            // Create a new download task, which will use the stored resume data.
            downloadContext.downloadTask = [self.session downloadTaskWithResumeData:downloadContext.taskResumeData];
            [downloadContext.downloadTask resume];
            downloadContext.isPaused = NO;
            
            // Keep the new download task identifier.
            downloadContext.taskIdentifier = downloadContext.downloadTask.taskIdentifier;
        }
    }
    else
    { //PAUSE
        downloadContext.isPaused = YES;
        downloadContext.downloadStatus = PxePlayerDownloadPaused;
        // Pause the task by canceling it and storing the resume data.
        [downloadContext.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            if (resumeData != nil)
            {
                downloadContext.taskResumeData = [[NSData alloc] initWithData:resumeData];
            }
        }];
    }
    // Change the isDownloading property value.
    downloadContext.isDownloading = !downloadContext.isDownloading;
    
    //you need to update this object in the array with the new values or all will be lost
    [self storeDownloadContext:downloadContext];
    if ([self.delegate respondsToSelector:@selector(updateDownloadStatus:)])
    {
        [self.delegate updateDownloadStatus:downloadContext];
    }
}

- (void)stopDownloading:(PxePlayerDownloadContext*)downloadFile
{
    [self stopDownloadRequest:downloadFile];
}

- (void) stopDownloadRequest:(PxePlayerDownloadContext *)downloadContext
{
    // Cancel the task.
    [downloadContext.downloadTask cancel];
    
    // Change all related properties.
    downloadContext.isDownloading = NO;
    downloadContext.isPaused = NO;
    downloadContext.taskIdentifier = -1;
    downloadContext.downloadProgress = 0.0;
    
    downloadContext.downloadStatus = PxePlayerDownloadPending;
    if ([self.delegate respondsToSelector:@selector(updateDownloadStatus:)])
    {
        [self.delegate updateDownloadStatus:downloadContext];
    }
}

- (BOOL) deleteDownload:(NSString*)ePubFileName
{
    return [self deleteDownloadedFile:ePubFileName];
}

- (BOOL) deleteDownloadedFile:(NSString *)ePubFileName
{
    DLog(@"ePubFile: %@", ePubFileName);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *fileError;
    BOOL didDelete = NO;
    
    NSURL *documentURL = [NSURL URLWithString:PATH_OF_DOCUMENT];
    
    documentURL = [documentURL URLByAppendingPathComponent:ePubFileName];
    
    if([fileManager removeItemAtPath:[documentURL path] error:&fileError])
    {
        DLog(@"File Deleted! %@",documentURL);
        
        // Commenting out the deletion of the data when the file is deleted because
        // if you are in the middle of the book when the data is deleted, you will be stuck.
        // TODO: add a way to mark isDownloaded to NO when file is deleted.
//        PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
//        
//        NSString *contextId = [ePubFileName stringByDeletingPathExtension];
//        
////        [self.arrFileDownloadData removeObject:[self getDownloadContextWithContextId:contextId]];
//        
//        PxePlayerUser *currentUser = [[PxePlayer sharedInstance] currentUser];
//        DLog(@"contextId: %@", contextId);
//        didDelete = [dataManager deleteCurrentContextWithID:contextId
//                                                currentUser:currentUser
//                                                withHandler:^(BOOL deleted, NSError *error){
//                                                    if (error && !deleted)
//                                                    {
//                                                        DLog(@"Data Purge Failed %@",[error description]);
//                                                        [self.delegate pxePlayerDownloadManagerDidFailWithError:error];
//                                                    }
//                                                }];
        
        //update asset download status in manifest, but not sure if this is the entire book
        [self updateDownloadStatusForAsset:[ePubFileName componentsSeparatedByString:@".epub"][0] isDownloaded:NO];
        
        didDelete = YES;
    }
    else
    {
        DLog(@"Delete Failed %@",[fileError description]);
        [self.delegate pxePlayerDownloadManagerDidFailWithError:[PxePlayerError errorForCode:PxePlayerFileError]];
    }
    
    return didDelete;
}

- (PxePlayerDownloadContext *) deleteDownloadedFileForAssetId:(NSString*)assetId
{
    PxePlayerDownloadContext *downloadContext = [self getDownloadContextWithAssetId:assetId];
    
    if (!downloadContext)
    {
        // DownloadContext wasn't persisted (Could be a new session and the file is still there)
        NSString *epub = [NSString stringWithFormat:@"%@.epub", assetId];
        [self deleteDownloadedFile:epub];
        return nil;
    }
    downloadContext = [self deleteDownloadedFileForContext:downloadContext];
    
    return downloadContext;
}

- (PxePlayerDownloadContext *) deleteDownloadedFileForContext:(PxePlayerDownloadContext *)downloadContext
{
    NSString *epubFileName = [NSString stringWithFormat:@"%@.epub", downloadContext.assetId];
    [self deleteDownloadedFile:epubFileName];
    
    downloadContext.downloadStatus = PxePlayerDownloadPending;
    
    return downloadContext;
}

#pragma mark - private functions
/**
 * @private
 *  Gets the index of the download process by task Identifier
 *
 *  @param taskIdentifier long
 *
 *  @return int
 */
- (int) getPxeDownloadContextIndexWithTaskIdentifier:(unsigned long)taskIdentifier
{
    int index = 0;
    for (int i=0; i<[self.arrPxeDownloadContext count]; i++)
    {
        PxePlayerDownloadContext *ppdc = [self.arrPxeDownloadContext objectAtIndex:i];
        if (ppdc.taskIdentifier == taskIdentifier)
        {
            index = i;
            break;
        }
    }
    
    return index;
}

- (void) downloadPXEJSForContext:(PxePlayerDownloadContext*)downloadContext withCompletionHandler:(DMCompletionHandler)handler
{
    NSURL *url = [NSURL URLWithString:self.pxeJS_Path];
    
    // Check to see if files folder exists
    NSString *destinationPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:READER_SDK_PATH];
    
    BOOL isDIR = YES;
    if([[NSFileManager defaultManager] fileExistsAtPath:destinationPath isDirectory:&isDIR])
    {
        DLog(@"PXE SDK EXISTS ALREADY");
        [self setPXEJSDownloadCompleteForContextId:downloadContext.contextId];
        handler(NO,nil);
    }
    else
    {
        NSString  *filePath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:[url lastPathComponent]];
        DLog(@"filePath: %@", filePath);
        NSString *folderPath = [filePath stringByDeletingPathExtension];
        DLog(@"folderPath: %@", folderPath);
        
        DLog(@"Downloading PXE: %@",filePath);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL  *url = [NSURL URLWithString:self.pxeJS_Path];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                [urlData writeToFile:filePath atomically:YES];
                
                [self unzipPXEfiles:[url lastPathComponent] forContext:downloadContext withCompletionHandler:^(BOOL didComplete, NSError *error) {
                    handler(didComplete,error);
                }];
            }
        });
    }
}

/**
 *  @private
 *  This is used to unzip the downloaded PXE zip file.
 *
 *  @param zipFile NSString
 *  @param handler Handler to return errors and if the unzip was successful
 */
- (void) unzipPXEfiles:(NSString*)zipFile forContext:(PxePlayerDownloadContext*)downloadContext withCompletionHandler:(DMCompletionHandler)handler
{
    NSError *zipError;
    NSString *zipPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:zipFile];
    // Unzipping the file
    NSString *destinationPath =  [PATH_OF_DOCUMENT stringByAppendingPathComponent:READER_SDK_PATH];
    DLog(@"destinationPath: %@", destinationPath);
    if([ZipFile unzipFileAtPath:zipPath toDestination:destinationPath overwrite:YES password:nil error:nil])
    {
        //now delete the .zip
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:zipPath error:&zipError];
        if(zipError)
        {
            handler(NO,zipError);
        }else{
            [self setPXEJSDownloadCompleteForContextId:downloadContext.contextId];
            handler(YES,zipError);
        }
    }
}

/**
 *  @private
 *  This is used to insert the user and context components into core data for offline access.
 *
 *  @param ppdm PxePlayerDownloadManager
 */
-(void) insertContextIntoCoreData:(PxePlayerDownloadContext*)downloadContext
{
    DLog(@"InsertingContextInto CoreData");
    downloadContext.downloadStatus = PxePlayerDownloadingTOC;
    if ([self.delegate respondsToSelector:@selector(updateDownloadStatus:)])
    {
        [self.delegate updateDownloadStatus:downloadContext];
    }
    
    PxePlayerUser *currentUser = [[PxePlayer sharedInstance] currentUser];
    //insert context
    PxePlayerDataInterface *dataInterface = [self getDataInterfaceWithContextId:downloadContext.contextId];
    dataInterface.identityId = currentUser.identityId;
    dataInterface.authToken = currentUser.authToken;
    if(!dataInterface.offlineBaseURL)
    {
        dataInterface.offlineBaseURL = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:downloadContext.contextId] stringByAppendingPathExtension:@"epub"];
    }
    if(!dataInterface.afterCrossRefBehaviour)
    {
        dataInterface.afterCrossRefBehaviour = @"continue";
    }
    DLog(@"dataInterface: %@", dataInterface);
    
    PxePlayerDataFetcher *dataFetcher = [[PxePlayerDataFetcher alloc] initWithDataInterface:dataInterface];
    
    [dataFetcher fetchDataWithCompletionHandler:^(BOOL success, NSError *updateError) {
        if (success)
        {
            [self setTOCDownloadCompleteForContextId:dataInterface.contextId];
            
            downloadContext.downloadStatus = PxePlayerDownloadingMetaData;
             if ([self.delegate respondsToSelector:@selector(updateDownloadStatus:)])
             {
                 [self.delegate updateDownloadStatus:downloadContext];
             }
             
             [self resetMetadataDownloadIndicatorsForContextId:downloadContext.contextId];
             
             [self.arrPxeDataInterface removeObject:[self getDataInterfaceWithContextId:downloadContext.contextId]];
             //put this in a thread
             [dataFetcher fetchBookmarksWithCompletionHandler:^(PxePlayerBookmarks *bookmarks, NSError *error) {
                 if(error)
                 {
                     DLog(@"ERROR Getting Bookmarks!: %@", error);
                     [self.delegate pxePlayerDownloadManagerDidFailWithError:error];
                 }else{
                     DLog(@"Got Bookmarks! %@", bookmarks);
                 }
                 [self setBookmarkDownloadCompleteForContextId:downloadContext.contextId];
                 [self downloadMetaDataComplete:downloadContext];
             }];
             
             //get glossary
             [dataFetcher fetchGlossaryWithCompletionHandler:^(NSArray *glossarys, NSError *error) {
                 if(error)
                 {
                     DLog(@"ERROR Getting Glossary!");
                     [self.delegate pxePlayerDownloadManagerDidFailWithError:error];
                 } else {
                     DLog(@"Got Glossary! %@",[glossarys description]);
                 }
                 [self setGlossaryDownloadCompleteForContextId:downloadContext.contextId];
                 [self downloadMetaDataComplete:downloadContext];
             }];
             
             //get Annotations
             [dataFetcher fetchAnnotationsWithCompletionHandler:^(PxePlayerAnnotationsTypes *annotationsTypes, NSError *error) {
                 if(error)
                 {
                     DLog(@"ERROR Getting Annotations!");
                     [self.delegate pxePlayerDownloadManagerDidFailWithError:error];
                 }else{
                     DLog(@"Got Annotations!");
                 }
                 [self setAnnotationsDownloadCompleteForContextId:downloadContext.contextId];
                 [self downloadMetaDataComplete:downloadContext];
             }];
            [self downloadComplete:downloadContext];
        } else {
            DLog(@"ERROR UPDATING DATAINTERFACE: %@", updateError);
        }
    }];
}

- (void) resetMetadataDownloadIndicatorsForContextId:(NSString*)contextId
{
    for (PxePlayerDownloadContext *downloadContext in self.arrPxeDownloadContext)
    {
        if ([downloadContext.contextId isEqualToString:contextId])
        {
            downloadContext.annotationDownloadComplete = NO;
            downloadContext.bookmarkDownloadComplete = NO;
            downloadContext.glossaryDownloadComplete = NO;
        }
    }
}

- (void) setAnnotationsDownloadCompleteForContextId:(NSString*)contextId
{
    for (PxePlayerDownloadContext *downloadContext in self.arrPxeDownloadContext)
    {
        if ([downloadContext.contextId isEqualToString:contextId])
        {
            downloadContext.annotationDownloadComplete = YES;
        }
    }
}

- (void) setBookmarkDownloadCompleteForContextId:(NSString*)contextId
{
    for (PxePlayerDownloadContext *downloadContext in self.arrPxeDownloadContext)
    {
        if ([downloadContext.contextId isEqualToString:contextId])
        {
            downloadContext.bookmarkDownloadComplete = YES;
        }
    }
}

- (void) setGlossaryDownloadCompleteForContextId:(NSString*)contextId
{
    for (PxePlayerDownloadContext *downloadContext in self.arrPxeDownloadContext)
    {
        if ([downloadContext.contextId isEqualToString:contextId])
        {
            downloadContext.glossaryDownloadComplete = YES;
        }
    }
}

- (void) setPXEJSDownloadCompleteForContextId:(NSString*)contextId
{
    for (PxePlayerDownloadContext *downloadContext in self.arrPxeDownloadContext)
    {
        if ([downloadContext.contextId isEqualToString:contextId])
        {
            downloadContext.pxeJSDownloadComplete = YES;
            [self downloadComplete:downloadContext];
        }
    }
}

- (void) setTOCDownloadCompleteForContextId:(NSString*)contextId
{
    for (PxePlayerDownloadContext *downloadContext in self.arrPxeDownloadContext)
    {
        if ([downloadContext.contextId isEqualToString:contextId])
        {
            downloadContext.tocDownloadComplete = YES;
        }
    }
}

- (void) downloadMetaDataComplete:(PxePlayerDownloadContext*)downloadContext
{
    if(downloadContext.annotationDownloadComplete && downloadContext.bookmarkDownloadComplete && downloadContext.glossaryDownloadComplete)
    {
        [self downloadComplete:downloadContext];
    }
}

/**
 *  @private
 *  This will insert a user object into core data if it is not already there. Then goes and calls insertContextIntoCoreData to insert the rest of the context components
 *
 *  @param ppdm PxePlayerDownloadManager
 */
- (void) getContextComponents:(PxePlayerDownloadContext*)downloadContext
{
    DLog(@"GettingContext");
    if ([self allDownloadsForContextComplete:downloadContext])
    {
        //some apps might use this if not who cares set it anyway
        PxePlayerUser *pxeUser = [[PxePlayer sharedInstance] currentUser];
        
        //make sure we have a user saved if not save it
        [[PxePlayerDataManager sharedInstance] readPxeUserWithData:pxeUser withCompletionHandler:^(NSArray *users, NSError *error) {
            if(users.count==0)
            {
                [[PxePlayerDataManager sharedInstance] createPxeUserWithData:pxeUser withCompletionHandler:^(PxeUser *user, NSError *error) {
                    [self insertContextIntoCoreData:downloadContext];
                }];
            }
            else
            {
                [self insertContextIntoCoreData:downloadContext];
            }
        }];
    }
}

- (BOOL) allDownloadsForContextComplete:(PxePlayerDownloadContext *)downloadContext
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contextId == %@", downloadContext.contextId];
    NSArray *contextArray = [self.arrPxeDownloadContext filteredArrayUsingPredicate:predicate];
    
    if([contextArray count] > 1)
    {// There's more than one downloadContext for that context Id
        for (PxePlayerDownloadContext *otherContext in contextArray)
        {
            if (![otherContext.assetId isEqualToString:downloadContext.assetId])
            {// If the other download context is not the same as the current download context
                if (otherContext.downloadStatus < 3)
                {// If the other download context has a status of:
                 //     PxePlayerDownloadPending        = 0,
                 //     PxePlayerDownloadPaused         = 1,
                 //     PxePlayerDownloadingEpubFile    = 2,
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - public methods
- (double)getFreeDiskspace
{
//    uint64_t totalSpace = 0;
    double totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary)
    {
//        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
//        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //        DLog(@"Memory Capacity of %llu MiB with %f MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    }
    else
    {
        DLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    //TODO: Pass the error
    return totalFreeSpace;
}

- (NSData *) readPage:(NSString*)pageURI
                error:(NSError**)error
{
    return [self readPage:pageURI
            dataInterface:[[PxePlayer sharedInstance] currentDataInterface]
                    error:error];
}

- (NSData *) readPage:(NSString*)pageURI
        dataInterface:(PxePlayerDataInterface*)dataInterface
                error:(NSError**)error
{
    int BUFFER_SIZE = 1024;
    __block NSMutableData *returnData = nil;
    
    NSDictionary *errorDict;
    DLog(@"DataInterface: %@", dataInterface);
    DLog(@"pageURI: %@", pageURI);
    DLog(@"contextId: %@", dataInterface.contextId);
    NSString *assetId;
    if (!dataInterface.assetId)
    {
        NSString *relPath = [[PxePlayer sharedInstance] removeBaseUrlFromUrl:pageURI];
        assetId = [[PxePlayerDataManager sharedInstance] getAssetForPage:relPath contextId:dataInterface.contextId];
    }
    else
    {
        assetId = dataInterface.assetId;
    }
    DLog(@"assetId: %@", assetId);
    NSString *relativepath;
    if (assetId)
    {
        NSString *epubPath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:assetId] stringByAppendingPathExtension:@"epub"];
        
        // Cant contain "/" at the end
        if ([epubPath characterAtIndex:[epubPath length] -1] == '/')
        {
            epubPath = [epubPath substringToIndex:[epubPath length]-1];
        }
        
        DLog(@"epubPath: %@", epubPath);
        DLog(@"contextId: %@", dataInterface.contextId);
        DLog(@"assetId: %@", assetId);
        
        DLog(@"pageURI: %@", pageURI);
        
        NSArray *afterOPSArray = [pageURI componentsSeparatedByString:[epubPath stringByAppendingString:@"/"]];
        
        if([afterOPSArray count]>1)
        {
            // Gets the realtivepath from the offline URL
            relativepath = [afterOPSArray objectAtIndex:1];
        }
        else
        {
            NSString *opsString = @"OPS/";
            afterOPSArray = [pageURI componentsSeparatedByString:opsString];
            if([afterOPSArray count]>1)
            {
                relativepath = [NSString stringWithFormat:@"%@%@", opsString, [afterOPSArray objectAtIndex:1]];
            }
        }
        DLog(@"relativePath: %@", relativepath);
        pageURI = [NSString stringWithFormat:@"%@/%@", epubPath, relativepath];
        ZipFile *unzipFile = nil;
    
        @try {
            unzipFile= [[ZipFile alloc] initWithFileName:epubPath mode:ZipFileModeUnzip];
        }
        @catch (NSException *exception) {
            DLog(@"Zip Fail: %@",exception);
        }
    
        //HACK: some epubs look up based on ./blah and some use /blah no clue why
        if([unzipFile locateFileInZip:@"./"] && [afterOPSArray count]>1)
        {
            relativepath = [@"./" stringByAppendingString:[afterOPSArray objectAtIndex:1]];
        }
        
        //if the relative path has a # on the end it will fail.
        if([relativepath rangeOfString:@"#"].location != NSNotFound)
        {
            DLog(@"\n\n#  FOUND ON THE PATH!");
            relativepath = [[NSURL URLWithString:relativepath] path];
        }
        
        //locate the file you want to read
        DLog(@"relativePath: %@", relativepath);
        if(relativepath != nil && [unzipFile locateFileInZip:relativepath])
        {
            // Expand the file in memory
            ZipReadStream *read= [unzipFile readCurrentFileInZip];
            
            NSMutableData *data= [[NSMutableData alloc] initWithLength:BUFFER_SIZE];
            returnData = [NSMutableData data];
            
            do {
                
                // Reset buffer length
                [data setLength:BUFFER_SIZE];
                
                // Expand next chunk of bytes
                long bytesRead= [read readDataWithBuffer:data];
                if (bytesRead > 0) {
                    
                    // Write what we have read
                    [data setLength:bytesRead];
                    [returnData appendData:data];
                    
                } else
                    break;
                
            } while (YES);
            
            //        DLog(@"%@",[[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding]);
            
            [read finishedReading];
            [unzipFile close];
        }
        else
        {
            if ([self isPageDownloaded:relativepath])
            {
                DLog(@"ERROR: Failed to find offline data for page. relativePath: %@", relativepath);
                errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed to find offline data for page.", @"Failed to find offline data for page.")};
                *error = [PxePlayerError errorForCode:PxePlayerOfflineDataError errorDetail:errorDict];
            }
        }
        
        if(!returnData)
        {
            DLog(@"NO DATA FOUND: %@/%@",epubPath,relativepath);
            DLog(@"IS IT HTML?: %@", [relativepath hasSuffix:@"html"]?@"YES":@"NO");
            // Make sure error isn't for some png
            if ([relativepath hasSuffix:@"html"])
            {
                // Make sure that if the device is online but the book has been downloaded,
                // that perhaps the content exist online
                if ([Reachability isReachable])
                {
                    NSString *onlineURL = [NSString stringWithFormat:@"%@%@", [[PxePlayer sharedInstance] getOnlineBaseURL], relativepath];
                    [PxePlayerRestConnector responseDataWithURLAsync:onlineURL withCompletionHandler:^(id receivedObj, NSError *error)
                     {
                         if(!error) {
                             returnData = (NSMutableData *)receivedObj;
                         }
                         else
                         {
                             [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                                                 object:nil
                                                                               userInfo:errorDict];
                         }
                     }];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_PAGE_FAILED
                                                                        object:nil
                                                                      userInfo:errorDict];
                }
            }
            // Can't put data in returnData, won't know there was a problem if not null.
            //returnData = [[[NSString stringWithFormat:@"NO DATA FOUND: %@/%@",epubPath,relativepath] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        }
    }
    else
    {
        errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed to find offline data for page.", @"Failed to find offline data for page.")};
        *error = [PxePlayerError errorForCode:PxePlayerOfflineDataError errorDetail:errorDict];
    }
    
    return returnData;
}

- (BOOL) searchForOfflineBookByContextId:(NSString*)contextId
{
    return [self checkForDownloadedFileByAssetId:contextId];
}

- (BOOL) checkForDownloadedFileByAssetId:(NSString *)assetId
{
    NSString *filePath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:assetId] stringByAppendingPathExtension:@"epub"];
//    DLog(@"PATH: %@",filePath);
//    DLog(@"isDownloaded: %@", [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO]?@"YES":@"NO");
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO];
}

- (PxePlayerDownloadContext *) getDownloadContextWithContextId:(NSString*)contextId
{
    return [self getDownloadContextWithAssetId:contextId];
}

- (PxePlayerDownloadContext *) getDownloadContextWithAssetId:(NSString *)assetId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetId == %@", assetId];
    NSArray *filteredArray = [self.arrPxeDownloadContext filteredArrayUsingPredicate:predicate];
    id firstFoundObject = nil;
    firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
    
    return firstFoundObject;
}

- (void) storeDownloadContext:(PxePlayerDownloadContext *)downloadContext
{
    PxePlayerDownloadContext *currentContext = [self getDownloadContextWithAssetId:downloadContext.assetId];
    if (currentContext)
    {
        [self.arrPxeDownloadContext removeObject:currentContext];
    }
    
    [self.arrPxeDownloadContext addObject:downloadContext];
    
}

- (PxePlayerDataInterface *) getDataInterfaceWithContextId:(NSString*)contextId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contextId == %@", contextId];
    NSArray *filteredArray = [self.arrPxeDataInterface filteredArrayUsingPredicate:predicate];
    id firstFoundObject = nil;
    firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
    
    return firstFoundObject;
}

- (BOOL) haveDownloadedPXEJS
{
    return YES;
}

#pragma mark - NSURLSession Delegate method implementation

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    int index = [self getPxeDownloadContextIndexWithTaskIdentifier:downloadTask.taskIdentifier];
    
    NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
    
    NSURL *destinationURL = [self.libraryDirectory URLByAppendingPathComponent:destinationFilename];
    DLog(@"destinationURL path: %@",[destinationURL path]);
    if ([fileManager fileExistsAtPath:[destinationURL path]])
    {
        [fileManager removeItemAtURL:destinationURL error:nil];
    }
    
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&error];
    DLog(@"Success renaming file");
    if (success)
    {
        // Change the flag values of the respective FileDownloadInfo object.
        PxePlayerDownloadContext *downloadContext = [self.arrPxeDownloadContext objectAtIndex:index];
        downloadContext.epubDownloadComplete = YES;
        DLog(@"epubDownloadComplete: %@", downloadContext.epubDownloadComplete?@"YES":@"NO");
        [self.delegate didFinishSingleBackgroundSession:downloadContext];
        
        //call for the App to update its self (optional may or may not be used by the app)
        if([self.delegate respondsToSelector:@selector(updateUIElementsFinished:atIndex:)])
        {
            [self.delegate updateUIElementsFinished:downloadContext atIndex:index];
        }
        if([self.delegate respondsToSelector:@selector(didFinishFileDownloadRequest:)])
        {
            [self.delegate didFinishFileDownloadRequest:downloadContext];
        }
        downloadContext.downloadStatus = PxePlayerDownloadingTOC;
        if ([self.delegate respondsToSelector:@selector(updateDownloadStatus:)])
        {
            [self.delegate updateDownloadStatus:downloadContext];
        }
        
        // Set the initial value to the taskIdentifier property of the fdi object,
        // so when the start button gets tapped again to start over the file download.
        downloadContext.taskIdentifier = -1;
        
        // In case there is any resume data stored in the fdi object, just make it nil.
        downloadContext.taskResumeData = nil;
        //Create a new name for the context
        NSString *newFileName = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:downloadContext.assetId] stringByAppendingPathExtension:@"epub" ];
        //rename file this is important so that we have a consistant way to reference the context (by asset id on the device)
        [[NSFileManager defaultManager] moveItemAtPath:[PATH_OF_DOCUMENT stringByAppendingPathComponent:downloadContext.fileName]
                                                toPath: newFileName error:nil];
        //set the context components in core data
        [self getContextComponents:downloadContext];
        DLog(@"Calling updateDownloadStatusForAsset: downloadContext.assetId: %@", downloadContext.assetId);
        [self updateDownloadStatusForAsset:downloadContext.assetId isDownloaded:YES];
    }
    else
    {
        DLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
        [self.delegate pxePlayerDownloadManagerDidFailWithError:error];
    }
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    DLog(@"session: %@", session);
    // Check if all download tasks have been finished.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        //call to App UI that download finished
        [self.delegate didFinishAllBackgroundSession:downloadTasks];
    }];
}

- (void) downloadComplete:(PxePlayerDownloadContext *)downloadContext
{
    DLog(@" epubDownloadComplete: %@", downloadContext.epubDownloadComplete?@"YES":@"NO");
    DLog(@" tocDownloadComplete: %@", downloadContext.tocDownloadComplete?@"YES":@"NO");
    DLog(@" annotationDownloadComplete: %@", downloadContext.annotationDownloadComplete?@"YES":@"NO");
    DLog(@" bookmarkDownloadComplete: %@", downloadContext.bookmarkDownloadComplete?@"YES":@"NO");
    DLog(@" glossaryDownloadComplete: %@", downloadContext.glossaryDownloadComplete?@"YES":@"NO");
    DLog(@" pxeJSDownloadComplete: %@", downloadContext.pxeJSDownloadComplete?@"YES":@"NO");

    if (downloadContext.epubDownloadComplete &&
        downloadContext.tocDownloadComplete &&
        downloadContext.annotationDownloadComplete &&
        downloadContext.bookmarkDownloadComplete &&
        downloadContext.glossaryDownloadComplete &&
        downloadContext.pxeJSDownloadComplete)
    {
        DLog(@"Download Complete!");
        
        downloadContext.isDownloading = NO;
        downloadContext.downloadComplete = YES;
        downloadContext.downloadStatus = PxePlayerDownloadCompleted;
        
        DLog(@"Calling updateDownloadStatusForAsset: downloadContext.assetId: %@", downloadContext.assetId);
        [self updateDownloadStatusForAsset:downloadContext.assetId isDownloaded:YES];
        
        if ([self.delegate respondsToSelector:@selector(updateDownloadStatus:)])
        {
            [self.delegate updateDownloadStatus:downloadContext];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_DOWNLOAD_COMPLETE_NOTIFICATION object:self];
    }
}

#pragma mark - NSURLSessionDownloadDelegate methods

- (void) URLSession:(NSURLSession *)session
       downloadTask:(NSURLSessionDownloadTask *)downloadTask
       didWriteData:(int64_t)bytesWritten
  totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown)
    {
        DLog(@"Unknown transfer size");
    }
    else
    {
        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
        int index = [self getPxeDownloadContextIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        //DLog(@"totalBytesWritten: %lld ::: totalBytesExpected: %lld ::: atIndex: %d", totalBytesWritten, totalBytesExpectedToWrite, index);
        PxePlayerDownloadContext *downloadContext = [self.arrPxeDownloadContext objectAtIndex:index];
        //call to App UI to update the progress of the download
        if([self.delegate respondsToSelector:@selector(updateUIElements:totalBytesWritten:totalBytesExpectedToWrite:atIndex:)])
        {
            [self.delegate updateUIElements:downloadContext
                          totalBytesWritten:totalBytesWritten
                  totalBytesExpectedToWrite:totalBytesExpectedToWrite
                                    atIndex:index];
        }
        if([self.delegate respondsToSelector:@selector(updateDownloadRequest:totalBytesWritten:totalBytesExpectedToWrite:)])
        {
            [self.delegate updateDownloadRequest:downloadContext
                               totalBytesWritten:totalBytesWritten
                       totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }
    }
}

#pragma mark - Archive code for DownloadContexts

- (void) archiveDownloadContexts
{
    //[NSKeyedArchiver archiveRootObject:self.arrPxeDownloadContext
    //                            toFile:[self getDownloadContextArchivePath]];
}

- (void) unarchiveDownloadContexts
{
    NSMutableArray *archivedDownloadContexts = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getDownloadContextArchivePath]];
    
    if (archivedDownloadContexts)
    {
        [self.arrPxeDownloadContext addObjectsFromArray:archivedDownloadContexts];
    }
}

- (NSString *) getDownloadContextArchivePath
{
    NSArray *archiveDirectories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    NSString *archiveDirectory = [archiveDirectories objectAtIndex:0];
    NSString *archivePath = [archiveDirectory stringByAppendingPathComponent:@"DownloadContext.data"];
    
    return archivePath;
}

- (void) updateDownloadStatusForAsset:(NSString*)assetId isDownloaded:(BOOL)isDownloaded
{
    DLog(@"Changing download status for asset id %@ to %@", assetId, (isDownloaded)?@"YES":@"NO");
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[PxePlayerDataManager sharedInstance] updateManifestItemWithId:assetId
                                                        downloadedStatus:isDownloaded
                                                   withCompletionHandler:^(BOOL success) {
                                                            if (!success) {
                                                                NSLog(@"ERROR: unable to update asset's manifest download status in DB");
                                                                //This could be the entire book w/out a manifest
                                                            }
                                                   }];
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[PxePlayerDataManager sharedInstance] updatePageStatusWithAsset:assetId
                                                        downloadedStatus:isDownloaded
                                                   withCompletionHandler:^(BOOL success) {
                                                       if (!success) {
                                                           NSLog(@"ERROR: unable to update asset's page download status in DB");
                                                          
                                                       }
                                                   }];
    }];
}

- (void) setOnlineBaseURL:(NSString *)baseURL forContextId:(NSString*)contextId
{
    for (PxePlayerDataInterface *dataInterface in self.arrPxeDataInterface)
    {
        if([dataInterface.contextId isEqualToString:contextId])
        {
            dataInterface.onlineBaseURL = baseURL;
        }
    }
}

- (BOOL) isPageDownloaded:(NSString*)relativePath
{
    NSPredicate *pageURLPredicate = [NSPredicate predicateWithFormat:@"pageURL == %@ AND isDownloaded == 1", relativePath];
    NSArray *pagesDownloaded = [[PxePlayerDataManager sharedInstance] fetchEntity:@[@"isDownloaded", @"assetId"]
                                                                         forModel:NSStringFromClass([PxePageDetail class])
                                                                    withPredicate:pageURLPredicate
                                                                      withSortKey:nil
                                                                     andAscending:YES];
    return ([pagesDownloaded count] > 0);
}

@end
