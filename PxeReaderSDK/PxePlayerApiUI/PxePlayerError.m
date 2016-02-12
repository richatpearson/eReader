//
//  PxePlayerError.m
//  PxeReader
//
//  Created by Tomack, Barry on 9/8/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerError.h"

@interface PxePlayerError ()

@property (strong, nonatomic) NSDictionary *localizedStrings;

@end

@implementation PxePlayerError

NSString* const PxePlayerErrorDomain = @"com.pxeplayer.sdk";

+ (NSError *) errorForCode:(PxePlayerErrorCode)errorCode
{
    return [PxePlayerError errorForCode:errorCode localizedString:nil];
}

+ (NSError *) errorForCode:(PxePlayerErrorCode)errorCode
           localizedString:(NSString*)localizedString
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    
    if(localizedString)
    {
        [errorDetail setValue:localizedString
                       forKey:NSLocalizedDescriptionKey];
    }
    else
    {
        [errorDetail setValue:[[PxePlayerError getLocalizedStrings] objectForKey:@(errorCode)]
                       forKey:NSLocalizedDescriptionKey];
    }
    
    return [PxePlayerError errorForCode:errorCode errorDetail:errorDetail];
}

+ (NSError *) errorForCode:(NSInteger)errorCode
               errorDetail:(NSDictionary*)errorDetail
{
    if (!errorDetail)
    {
        errorDetail = @{ NSLocalizedDescriptionKey:[[PxePlayerError getLocalizedStrings] objectForKey:@(errorCode)] };
    }
    
    return [NSError errorWithDomain:PxePlayerErrorDomain code:errorCode userInfo:errorDetail];
}

+ (NSDictionary *) getLocalizedStrings
{
    return @{@(PxePlayerUnknownError): NSLocalizedString(@"Unknown error", nil),
             @(PxePlayerGeneralError): NSLocalizedString(@"General Error", nil),
             @(PxePlayerInvalidURL): NSLocalizedString(@"Invalid URL", nil),
             @(PxePlayerContextLoadError): NSLocalizedString(@"Context failed to load ... ", @"Context failed to load..."),
             @(PxePlayerImproperInput): NSLocalizedString(@"Improper input", @"Improper input"),
             @(PxePlayerXMLParsingError): NSLocalizedString(@"XML Parsing Error",@"Wrong XML"),
             @(PxePlayerAuthenticationFailure): NSLocalizedString(@"Failed to authenticate user.", @"Failed to authenticate user."),
             @(PxePlayerMalformedURL): NSLocalizedString(@"Malformed URL", @"Malformed URL"),
             @(PxePlayerGlossaryNotFound): NSLocalizedString(@"Glossary not found", @"Glossary not found"),
             @(PxePlayerSearchNotInitialized): NSLocalizedString(@"Search not initialized",@"Search not initialized"),
             @(PxePlayerMissingDocumentPaths): NSLocalizedString(@"Must submit dataInterface with either NCX or Master PlayList", @"Missing Document Paths"),
             @(PxePlayerPageFailed): NSLocalizedString(@"PXEPlayer page load failed", @"PXEPlayer page load failed"),
             @(PxePlayerPostWrongJSON): NSLocalizedString(@"Trying to post wrong JSON format", @"Wrong JSON"),
             @(PxePlayerParseError): NSLocalizedString(@"Parser Error",@"Parser Error"),
             @(PxePlayerNetworkUnreachable): NSLocalizedString(@"Network is unreachable",@"Network is unreachable"),
             @(PxePlayerJSONParseError): NSLocalizedString(@"Error while parsing JSON", @"Error while parsing JSON"),
             @(PxePlayerPersistantDataError): NSLocalizedString(@"Error with persistant data", @"Error while persistant data"),
             @(PxePlayerFileError):NSLocalizedString(@"File requested was not found", @"File requested was not found"),
             @(PxePlayerNavigationError):NSLocalizedString(@"Cannot navigate to requested page", @"Cannot navigate to requested page"),
             @(PxePlayerOfflineDataError):NSLocalizedString(@"Offline Data Error", @"Offline Data Error"),
             @(PxePlayerEnvironmentError):NSLocalizedString(@"EnvironmentContext Data Error", @"EnvironmentContext Data Error"),
             @(PxePlayerPlaylistError):NSLocalizedString(@"Error retrieving Master Playlist", @"Error retrieving Master Playlist"),
             @(PxePlayerTOCError):NSLocalizedString(@"Error retrieving TOC", @"Error retrieving TOC"),
             @(PxePlayerNetworkCallFailed):NSLocalizedString(@"Network call failed", @"Network c"),
             @(PxePlayerManifestError):NSLocalizedString(@"Error retrieving manifest", @"Error retrieving manifest"),
             @(PxePlayerNoManifestFoundInStore):NSLocalizedString(@"No manifest found in local database", @"No manifest found in local database"),
             @(PxePlayerNoDownloadContextProvided):NSLocalizedString(@"No download context was provided for download", @"No download context was provided for download"),
             @(PxePlayerAnnotationsError):NSLocalizedString(@"Annotations Error", @"Annotations Error"),
             @(PxePlayerDataMigrationError):NSLocalizedString(@"Data Migration Error", @"Data Migration Error"),
             @(PxePlayerMissingAnnotationError):NSLocalizedString(@"Missing annotation", @"Missing annotation"),
             @(PxePlayerMissingAnnotationIdError):NSLocalizedString(@"Missing annotation id", @"Missing annotation id")};
}

+ (NSString *)getLocalizedStringForErrorCode:(PxePlayerErrorCode)errorCode
{
    return [[PxePlayerError getLocalizedStrings] objectForKey:@(errorCode)];
}

@end
