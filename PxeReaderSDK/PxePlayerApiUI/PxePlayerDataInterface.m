//
//  PxePlayerDataInterface.m
//  PxeReader
//
//  Created by Saro Bear on 06/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerDataInterface.h"
#import "PxePlayerUIConstants.h"
#import "PXEPlayerMacro.h"
#import "PxePlayer.h"
#import "PxePlayerError.h"
#import "Reachability.h"
#import "PxePlayerDownloadManager.h"

@interface PxePlayerDataInterface ()

/**
 A NSString variable to hold the base URL
 */
@property (nonatomic, strong) NSString  *baseURL;

@end

@implementation PxePlayerDataInterface

@synthesize tocPath = _tocPath;
@synthesize assetId = _assetId;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.showAnnotate           = PXEPLAYER_DEFAULT_ANNOTATE;
        self.enableMathML           = PXEPLAYER_DEFAULT_MATHML;
        
        self.removeDuplicatePages   = NO;
    }
    return self;
}

- (id) getTocOrPlaylist
{
    if (self.tocPath)
    {
        return self.tocPath;
    }
    return self.masterPlaylist;
}

- (NSString *) getAssetId
{
    if (!_assetId)
    {
        return _contextId;
    }
    return _assetId;
}

- (NSString*) tocPath
{
    DLog(@"Getting tocPath: %@", _tocPath);
    return _tocPath;
}

- (void) setTocPath:(NSString *)toc
{
    DLog(@"toc: %@", toc);
    // Need relative path for TOC starting with OPS/...
    if(toc)
    {
        // First see if it's the full path
        if ([toc rangeOfString:@"http:/"].location == NSNotFound &&
            [toc rangeOfString:@"https:/"].location == NSNotFound)
        {
            DLog(@"NEED FULL PATH: %@", toc);
            // If this is toc.ncx (if it's toc.xhtml, then it's the full path)
            if ([toc rangeOfString:@"toc.ncx"].location != NSNotFound)
            {
                // 1. Split the string on the "OPS/" to isolate the toc
                NSArray *pathArray = [toc componentsSeparatedByString:@"OPS/"];
                if ([pathArray count] > 1)
                {
                    _tocPath = [[[self getBaseURL] stringByAppendingString:@"OPS/"] stringByAppendingString:[pathArray objectAtIndex:1]];
                }
                else
                {
                    // Make sure first character is not a "/"
                    if ([toc hasPrefix:@"/"] && [toc length] > 1)
                    {
                        toc = [[self getBaseURL] stringByAppendingString:[toc substringFromIndex:1]];
                    }
                    _tocPath = toc;
                }
            }
        }
        else
        {
            DLog(@"fullPath: %@", toc);
            _tocPath = toc;
        }
    }
    DLog(@"setTOCPath: %@", _tocPath);
}

- (BOOL) verified
{
    if (! (self.tocPath || self.masterPlaylist))
    {
        DLog(@"ERROR: DataInterface: Missing ncxURL or master playlist");
        return NO;
    }
    else if ( self.tocPath && self.masterPlaylist )
    {
        DLog(@"ERROR: Cannot have both a master playlist and a toc");
        return NO;
    }
    else if (self.masterPlaylist)
    {
        // You must provide a online base URL with a master playlist
        if (! self.onlineBaseURL)
        {
            DLog(@"ERROR: Must provide a online base path with a master playlist");
            return NO;
        }
    }
    else if (self.tocPath)
    {
        if ([self.tocPath rangeOfString:@"ncx"].location != NSNotFound)
        {
            if (! self.onlineBaseURL)
            {
                DLog(@"ERROR: Missing online base URL for NCX TOC");
                return NO;
            }
            if ([self.tocPath rangeOfString:@"toc.xhtml"].location != NSNotFound)
            {
                // if must be a full path
                if (! ([self.tocPath hasPrefix:@"http://"] || [self.tocPath hasPrefix:@"https://"]) )
                {
                    DLog(@"ERROR: toc.xhtml requires a full path");
                    return NO;
                }
            }
        }
    }
    if (! self.contextId)
    {
        DLog(@"ERROR: DataInterface: Missing context");
        return NO;
    }
    
    if (! self.afterCrossRefBehaviour)
    {
        DLog(@"ERROR: DataInterface: Missing afterCrossRefBehaviour");
        return NO;
    }
    
    return YES;
}

- (BOOL) verifyWithError:(NSError **)error
{
    BOOL verified = YES;
    NSDictionary *userInfo;
    
    if (! (self.tocPath || self.masterPlaylist))
    {
        // Must have at least one or the other
        DLog(@"ERROR: Missing either a toc path or a master playlist");
        userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Missing either a toc path or a master playlist", @"Missing either a toc path or a master playlist")};
        verified = NO;
    }
    else if ( self.tocPath && self.masterPlaylist )
    {
        // Can't have both a master playlist and a toc path
        DLog(@"ERROR: Cannot have both a master playlist and a toc");
        userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot have both a master playlist and a toc", @"Cannot have both a master playlist and a toc")};
        verified = NO;
    }
    else if (self.masterPlaylist)
    {
        // You must provide a online base URL with a master playlist
        if (! self.onlineBaseURL)
        {
            DLog(@"ERROR: Must provide a online base path with a master playlist");
            userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Must provide a online base path with a master playlist", @"Must provide a online base path with a master playlist")};
            verified = NO;
        }
    }
    else if (self.tocPath)
    {
        // if the toc path is for toc.ncx, then there must be a online base url
        if ([self.tocPath rangeOfString:@"toc.ncx"].location != NSNotFound)
        {
            if (! self.onlineBaseURL)
            {
                DLog(@"ERROR: Missing online base URL for NCX TOC");
                userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Missing online base URL for NCX TOC", @"Missing online base URL for NCX TOC")};
                verified = NO;
            }
        }
        // if toc path is for toc.xhtml, then...
        if ([self.tocPath rangeOfString:@"toc.xhtml"].location != NSNotFound)
        {
            // if must be a full path
            if (! ([self.tocPath hasPrefix:@"http://"] || [self.tocPath hasPrefix:@"https://"]) )
            {
                DLog(@"ERROR: toc.xhtml requires a full path");
                userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"toc.xhtml requires a full path", @"toc.xhtml requires a full path")};
                verified = NO;
            }
        }
    }
    if (! self.contextId)
    {
        DLog(@"ERROR: Missing context Id");
        userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Missing context Id", @"Missing context Id")};
        verified = NO;
    }
    
    if (! self.afterCrossRefBehaviour)
    {
        DLog(@"ERROR: Missing afterCrossRefBehaviour");
        userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Missing afterCrossRefBehaviour", @"Missing afterCrossRefBehaviour")};
        verified = NO;
    }
    
    if (!verified)
    {
        if (error != NULL)
        {
            *error = [PxePlayerError errorForCode:PxePlayerDataInterfaceError errorDetail:userInfo];
        }
    }
    
    return verified;
}

- (NSString*) description
{
    NSMutableString *dataDesc = [NSMutableString stringWithString:@"PxePlayerDataInterface: \n"];
    [dataDesc appendFormat:@"   contextTitle: %@ \n", self.contextTitle];
    [dataDesc appendFormat:@"   contextId: %@ \n", self.contextId];
    [dataDesc appendFormat:@"   assetId: %@ \n", self.assetId];
    [dataDesc appendFormat:@"   tocPath: %@ \n", self.tocPath];
    [dataDesc appendFormat:@"   onlineBaseURL: %@ \n", self.onlineBaseURL];
    [dataDesc appendFormat:@"   offlineBaseURL: %@ \n", self.offlineBaseURL];
    [dataDesc appendFormat:@"   ePubURL: %@ \n", self.ePubURL];
    [dataDesc appendFormat:@"   afterCrossRefBehaviour: %@ \n", self.afterCrossRefBehaviour];
    [dataDesc appendFormat:@"   learningContext: %@ \n", self.learningContext];
    [dataDesc appendFormat:@"   showAnnotate: %@ \n", self.showAnnotate?@"YES":@"NO"];
    [dataDesc appendFormat:@"   removeDuplicatePages: %@ \n", self.removeDuplicatePages?@"YES":@"NO"];
    if (self.masterPlaylist)
    {
        [dataDesc appendFormat:@"   masterPlaylist: %@ \n", self.masterPlaylist];
    }
    return dataDesc;
}

- (void) setOnlineBaseURL:(NSString*)baseURL
{
    // Make sure last character is not a "/"
    if (baseURL != nil && ![baseURL isKindOfClass:[NSNull class]])
    {
        DLog(@"make sure onlinebaseurl ends with /");
        if(![baseURL hasSuffix:@"/"])
        {
            baseURL = [NSString stringWithFormat:@"%@/", baseURL];
        }
    }
    
    // Don't use self.onlineBaseURL or you'll infinite loop
    _onlineBaseURL = baseURL;
}

- (void) setOfflineBaseURL:(NSString*)baseURL
{
    // Make sure last character is a "/"
    if(![baseURL hasSuffix:@"/"])
    {
        baseURL = [NSString stringWithFormat:@"%@/", baseURL];
    }
    // Don't use self.offlineBaseURL or you'll infinite loop
    _offlineBaseURL = baseURL;
}


- (NSString *) getBaseURL
{
    NSString *baseURL;
    
    if ([Reachability isReachable])
    {
        baseURL = self.onlineBaseURL;
    }
    else
    {
        baseURL = [NSString stringWithFormat: @"%@/%@.epub/", PATH_OF_DOCUMENT, self.assetId];
    }
    return baseURL;
}

- (NSString *) getClientAppName
{
    NSString *clientAppName;
    
    switch (self.clientApp) {
        case PxePlayerSampleApp:
            clientAppName = @"PxePlayerSampleApp";
            break;
        case eText2_HE:
            clientAppName = @"eText2_HigherEd";
            break;
        case eText2_K12:
            clientAppName = @"eText2_K-12";
            break;
        default:
            clientAppName = @"Unknown";
            break;
    }
    
    return clientAppName;
}

@end
