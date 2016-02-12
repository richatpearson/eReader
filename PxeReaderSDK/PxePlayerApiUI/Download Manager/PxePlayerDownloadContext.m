//
//  PxePlayerDownloadContext.m
//  PxeReader
//
//  Created by Tomack, Barry on 11/12/14.
//  Copyright (c) 2014 Pearson All rights reserved.
//

#import "PxePlayer.h"
#import "PxePlayerDownloadContext.h"
#import "PXEPlayerMacro.h"


@implementation PxePlayerDownloadContext

//- (id)initWithCoder:(NSCoder *)decoder
//{    
//    if(self = [super init])
//    {
//        _contextId          = [decoder decodeObjectForKey:@"contextId"];
//        _assetId            = [decoder decodeObjectForKey:@"assetId"];
//        _fileTitle          = [decoder decodeObjectForKey:@"fileTitle"];
//        _fileName           = [decoder decodeObjectForKey:@"fileName"];
//        _downloadSource     = [decoder decodeObjectForKey:@"downloadSource"];
//        _onlineBaseUrl      = [decoder decodeObjectForKey:@"onlineFaseUrl"];
//        _downloadTask       = [decoder decodeObjectForKey:@"downloadTask"];
//        _taskResumeData     = [decoder decodeObjectForKey:@"taskResumeData"];
//        _downloadProgress   = [decoder decodeDoubleForKey:@"downloadProgress"];
//        _isDownloading      = [decoder decodeBoolForKey:@"isDownloading"];
//        _isPaused           = [decoder decodeBoolForKey:@"isPaused"];
//        _downloadComplete   = [decoder decodeBoolForKey:@"downloadComplete"];
//        _taskIdentifier     = [[decoder decodeObjectForKey:@"taskIdentifierAsNSNumber"] unsignedIntegerValue];
//        _downloadStatus     = [[decoder decodeObjectForKey:@"downloadStatusAsNSNumber"] unsignedIntegerValue];
//    }
//    
//    return self;
//}

- (id) initWithFileTitle:(NSString*)title
          downloadSource:(NSString *)source
           withPxeSource:(NSString *)pxeSource
               contextId:(NSString *)contextId
           onlineBaseUrl:(NSString *)onlineBaseUrl
{
    self = [self initWithFileTitle:title
                    downloadSource:source
                         contextId:contextId
                           assetId:contextId
                     onlineBaseUrl:onlineBaseUrl];
    return self;
}

- (id) initWithFileTitle:(NSString*)title
          downloadSource:(NSString *)source
               contextId:(NSString *)contextId
                 assetId:(NSString *)assetId
           onlineBaseUrl:(NSString *)onlineBaseUrl
{
    if (self = [super init])
    {
        NSURL *sourceURL = [NSURL URLWithString: source];
        
        DLog(@"sourceURL: %@", sourceURL);
        
        self.fileTitle = title;
        self.downloadSource = source;
        self.onlineBaseUrl = onlineBaseUrl;
        self.contextId = contextId;
        if (assetId)
        {
            self.assetId = assetId;
        } else {
            self.assetId = contextId;
        }
        
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.isPaused = NO;
        self.taskIdentifier = -1;
        self.fileName = [sourceURL lastPathComponent];
        
        self.downloadStatus = PxePlayerDownloadPending;
    }
    
    return self;
}

- (NSString*) description
{
    NSMutableString *contextDesc = [NSMutableString new];
    
    [contextDesc appendFormat:@"   fileTitle: %@ \n", self.fileTitle];
    [contextDesc appendFormat:@"   downloadSource: %@ \n", self.downloadSource];
    [contextDesc appendFormat:@"   contextId: %@ \n", self.contextId];
    [contextDesc appendFormat:@"   assetId: %@ \n", self.assetId];
    [contextDesc appendFormat:@"   onlineBaseUrl: %@ \n", self.onlineBaseUrl];
    [contextDesc appendFormat:@"   downloadProgress: %f \n", self.downloadProgress];
    [contextDesc appendFormat:@"   isDownloading: %@ \n", self.isDownloading?@"YES":@"NO"];
    [contextDesc appendFormat:@"   downloadComplete: %@ \n", self.downloadComplete?@"YES":@"NO"];
    [contextDesc appendFormat:@"   isPaused: %@ \n", self.isPaused?@"YES":@"NO"];
    [contextDesc appendFormat:@"   taskIdentifier: %lu \n", self.taskIdentifier];
    [contextDesc appendFormat:@"   fileName: %@", self.fileName];
    [contextDesc appendFormat:@"   downloadStatus: %lu", (unsigned long)self.downloadStatus];
    
    return contextDesc;
}


//#pragma mark ENCODING
//
//- (void) encodeWithCoder: (NSCoder *) encoder
//{
//    [encoder encodeObject:_contextId forKey:@"contextId"];
//    [encoder encodeObject:_assetId forKey:@"assetId"];
//    [encoder encodeObject:_fileTitle forKey:@"fileTitle"];
//    [encoder encodeObject:_fileName forKey:@"fileName"];
//    [encoder encodeObject:_downloadSource forKey:@"downloadSource"];
//    [encoder encodeObject:_onlineBaseUrl forKey:@"onlineBaseUrl"];
//    [encoder encodeObject:_downloadTask forKey:@"downloadTask"];
//    [encoder encodeObject:_taskResumeData forKey:@"taskResumeData"];
//    [encoder encodeDouble:_downloadProgress forKey:@"downloadProgress"];
//    [encoder encodeBool:_isDownloading forKey:@"isDownloading"];
//    [encoder encodeBool:_isPaused forKey:@"isPaused"];
//    [encoder encodeBool:_downloadComplete forKey:@"downloadComplete"];
//    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:_taskIdentifier] forKey:@"taskIdentifierAsNSNumber"];
//    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:_downloadStatus] forKey:@"downloadStatusAsNSNumber"];
//}

@end
