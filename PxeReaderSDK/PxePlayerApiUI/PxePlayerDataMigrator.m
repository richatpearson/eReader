//
//  PxePlayerDataMigrator.m
//  PxeReader
//
//  Created by Tomack, Barry on 11/11/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

#import "PxePlayerDataMigrator.h"
#import "PXEPlayerMacro.h"
#import "PxePlayerError.h"
#import "PxeContext.h"
#import "PxePageDetail.h"
#import "PxePlayerDownloadManager.h"

@implementation PxePlayerDataMigrator

- (void) migrateDataForContext:(NSManagedObjectContext*)objectContext
                    onComplete:(MigrationComplete)migrationComplete
{
    NSString *pxeVersion = [[PxePlayer sharedInstance] getPXEVersion];
    NSArray *versionArray = [pxeVersion componentsSeparatedByString:@"."];
    
    NSInteger major = [[versionArray objectAtIndex:0] integerValue];
    NSInteger minor = [[versionArray objectAtIndex:1] integerValue];
    NSInteger patch = [[versionArray objectAtIndex:2] integerValue];
    
    DLog(@"Major: %ld, Minor: %ld, Patch:%ld", (long)major, (long)minor, (long)patch);
    
    if ((major == 3) && (minor == 0) && (patch < 2))
    {
        [self migrateDataToVersion300ForContext:objectContext
                                   onComplete:migrationComplete];
    }
    else
    {
        NSString *results = @"No Data Migration necessary";
        migrationComplete(results, nil);
    }
}

// Data Migration from 2.X to 3.X involves filling in the new assetId and
// isDownloaded attributes in the PageDetails entity based on the ePubs that
// have been downloaded.

// Step 1 - Get a list of the current contextIds from the PxeContext entity
// Step 2 - Check if the contextId has a corresponding ePub file
// Step 3 - Update the PxePageDetail entity with assetId = contextId and
//          isDownloaded = YES
// Step 4 - Respond with success or failure in MigrationComplete

- (void) migrateDataToVersion300ForContext:(NSManagedObjectContext*)objectContext
                                onComplete:(MigrationComplete)migrationComplete
{
    NSString *results = @"";
    NSError *migrationError;
    
    NSFetchRequest *contextRequest = [NSFetchRequest fetchRequestWithEntityName:@"PxeContext"];
    
    NSArray *contexts = [objectContext executeFetchRequest:contextRequest error:&migrationError];
    DLog(@"contexts: %@", contexts);
    if (migrationError)
    {
        migrationComplete(nil, migrationError);
    }
    else
    {
        if (contexts)
        {
            if ([contexts count] > 0)
            {
                PxePlayerDownloadManager *downloadManager = [PxePlayerDownloadManager sharedInstance];
                for (PxeContext *context in contexts)
                {
                    DLog(@"contextId: %@", context.context_id);
                    // Get PageDetails for ContextId
                    NSFetchRequest *pageRequest = [NSFetchRequest fetchRequestWithEntityName:@"PxePageDetail"];
                    pageRequest.predicate = [NSPredicate predicateWithFormat:@"context.context_id = %@", context.context_id];
                    
                    NSArray *pagesArray = [objectContext executeFetchRequest:pageRequest error:&migrationError];
                    if (pagesArray)
                    {
                        for (PxePageDetail *page in pagesArray)
                        {
                            DLog(@"       page: %@", page.pageURL);
                            if ([downloadManager checkForDownloadedFileByAssetId:context.context_id])
                            {
                                page.assetId = context.context_id;
                                page.isDownloaded = [NSNumber numberWithInt:1];
                            }
                            else
                            {
                                page.isDownloaded = [NSNumber numberWithInt:0];
                            }
                        }
                    }
                    else
                    {
                        NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot retrieve pages for context.", @"Cannot Cannot retrieve pages for context.")};
                        migrationError = [PxePlayerError errorForCode:PxePlayerDataMigrationError errorDetail:errorDict];
                        migrationComplete(nil, migrationError);
                    }
                }
                // SAVE
                if ([objectContext hasChanges] && ![objectContext save:&migrationError])
                {
                    migrationError = [PxePlayerError errorForCode:PxePlayerDataMigrationError errorDetail:[migrationError userInfo]];
                    migrationComplete(nil, migrationError);
                }
                else
                {
                    results = @"Data Migration completed successfully";
                    migrationComplete(results, nil);
                }
            }
            else
            {
                results = @"no contexts on record";
                migrationComplete(results, nil);
            }
        }
        else
        {
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot retrieve contexts from store.", @"Cannot retrieve contexts from store.")};
            NSError *pxeError = [PxePlayerError errorForCode:PxePlayerDataMigrationError errorDetail:errorDict];
            migrationComplete(nil, pxeError);
        }
    }
}

@end
