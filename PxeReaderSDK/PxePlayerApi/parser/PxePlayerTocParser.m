//
//  PxePlayerTocParser.m
//  PxeReader
//
//  Created by Saro Bear on 26/02/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerTocParser.h"
#import "PxeContext.h"
#import "PxePlayerInterface.h"
#import "PxePlayerToc.h"
#import "PxePlayerDataManager.h"
#import "PxePlayerError.h"
#import "PXEPlayerMacro.h"
#import "PxeCustomBasketDetail.h"
#import "PxePlayer.h"
#import "PxePageDetail.h"
#import "PxePrintPage.h"

@implementation PxePlayerTocParser

#pragma mark - Public methods

/**
 This method would be called recursively to convert the tree of generic data into the list of models
 @param NSArray, childrens is a array of data from the tree of generic data
 @param NSString, parentId is a root id of the branch.
 */
-(void)ripPagesIntoList:(NSArray*)childrens parentId:(NSString*)parentId
{
    
}

-(void)ripCustomBasketPagesIntoList:(NSArray*)childrens parentId:(NSString*)parentId
{
    
}

- (void) parseMasterPlaylistFromDataInterface:(PxePlayerDataInterface*)dataInterface
                                  withHandler:(ParsingHandler)parsingHandler
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];

    // Make sure that the context exists in the database
    NSArray *contextResults = [dataManager fetchEntities:@[@"context_id"]
                                                forModel:NSStringFromClass([PxeContext class])
                                           withPredicate:[NSPredicate predicateWithFormat:@"context_id == %@", dataInterface.contextId]
                                              resultType:NSManagedObjectResultType withSortKey:nil
                                            andAscending:YES
                                              fetchLimit:1
                                              andGroupBy:nil];

    if(![contextResults count])
    {
        self.currentContext = nil;
    }
    else
    {
        self.currentContext = contextResults[0]; //just grab that first book and set it
    }
    
    [PxePlayerInterface getMasterPlaylistToc:dataInterface.masterPlaylist
                       withCompletionHandler:^(PxePlayerToc *toc, NSError *error)
    {
        // Make sure you have a current book
        if(!self.currentContext)
        {
            self.currentContext = [dataManager createCurrentContextWithDataInterface:dataInterface
                                                                         currentUser:[[PxePlayer sharedInstance] currentUser]
                                                                         withHandler:nil];
            if(!self.currentContext)
            {
                parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
            }
        }
        // Check if content is the same size before ripping pages
        //TODO: Find out if it's better to just delete the pages before adding new ones
        NSArray *pagesForContext = [self fetchPagesForContextId:self.currentContext.context_id parentId:@"root"];
        DLog(@"pagesForContext: %lu", (unsigned long)[pagesForContext count]);
        DLog(@"toc entries    : %lu", (unsigned long)[[toc tocEntries] count]);
        if ([pagesForContext count] != [[toc tocEntries] count])
        {
            [self ripPagesIntoList:[toc tocEntries] parentId:@"root"];
        }
        
        parsingHandler([NSNumber numberWithBool:YES], nil);
    }];
}

/**
 This method would be called to parse NCX data from the URL and returns the parsed result into the block handler
 @param NSString, url is a server location in which data to be downloaded and parsed
 @param ParsingHandler, parsingHandler is a block would receive the parsed result
 */
- (void) parseDataFromInterface:(PxePlayerDataInterface*)dataInterface withHandler:(ParsingHandler)parsingHandler
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    DLog(@"tocPath: %@ ::: contextId: %@", dataInterface.tocPath, dataInterface.contextId);
    //intiate the Get TOC web-service call
    [PxePlayerInterface getTOCFromDataInterface:dataInterface
                          withCompletionHandler:^(PxePlayerToc *toc, NSError *error)
     {
         if(error)
         {
             parsingHandler(nil, error);
         }
         else
         {
             NSArray *contexts = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeContext class])
                                                        withSortKey:@"context_id"
                                                          ascending:YES
                                                      withPredicate:[NSPredicate predicateWithFormat:@"context_id == %@", dataInterface.contextId]
                                                         fetchLimit:0
                                                         resultType:NSManagedObjectResultType];
             
             self.currentContext = [contexts lastObject];
             
             //now lets make sure we add the pages if they aren't already.
             PxePageDetail *details = [dataManager fetchEntity:@[@"pageURL"]
                                                      forModel:NSStringFromClass([PxePageDetail class])
                                                 withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", dataInterface.contextId]
                                                   withSortKey:@"pageURL"
                                                  andAscending:NO];
             
             if(!details)
             { //only insert if needed.
                 [self ripPagesIntoList:[toc tocEntries] parentId:@"root"];
                 if([toc customBaskets])
                 {
                     [self ripCustomBasketPagesIntoList:[[toc customBaskets]lastObject] parentId:@"root"];
                 }
                 parsingHandler([NSNumber numberWithBool:YES], nil);
             }
             else
             {
                 parsingHandler([NSNumber numberWithBool:YES], nil);
             }
         }
     }];
}

- (void) parseCustomBasketDataFromDataInterface:(PxePlayerDataInterface*)dataInterface
                                    withHandler:(ParsingHandler)parsingHandler
{
    self.contextId = dataInterface.contextId;
    [PxePlayerInterface getCustomBasketDataFromDataInterface:dataInterface
                                       withCompletionHandler:^(PxePlayerToc *toc, NSError *error)
    {
         if(!error)
         {
//             DLog(@"!PARSED!: %@", toc.customBaskets);
             if([toc customBaskets])
             {
                 self.pageNumber = 0;
                 
                 if(!self.currentContext)
                 {
                     parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
                 }
                 
                 DLog(@"%@", [[toc customBaskets] lastObject]);
                 [self ripCustomBasketPagesIntoList:[[toc customBaskets] lastObject] parentId:@"root"];
                 parsingHandler([NSNumber numberWithBool:YES], nil);
             } else {
                 parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
             }
         } else {
             parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
         }
     }];
}

- (void) parseTOCDataFromDataInterface:(PxePlayerDataInterface *)dataInterface
                    withHandler:(ParsingHandler)parsingHandler
{
    self.contextId = dataInterface.contextId;
    NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Abstract Class. Do not use", @"Abstract Class. Do not use")};
    NSError *error = [PxePlayerError errorForCode:PxePlayerNetworkUnreachable errorDetail:errorDict];
    parsingHandler(nil, error);
}

- (NSArray *) fetchPagesForContextId:(NSString*)contextId parentId:(NSString*)parentId
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    DLog(@"contextId: %@", contextId);
    DLog(@"parentId: %@", parentId);
    return [dataManager fetchEntities:@[@"pageURL"]
                             forModel:NSStringFromClass([PxePageDetail class])
                          withSortKey:@"pageURL"
                            ascending:YES
                        withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@ && parentId == %@", contextId, parentId]
                           fetchLimit:0
                           resultType:NSManagedObjectResultType
                              groupBy:nil];

}

- (NSArray *) fetchPrintPagesForContextId:(NSString*)contextId
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    return [dataManager fetchEntities:@[@"pageURL"]
                             forModel:NSStringFromClass([PxePrintPage class])
                          withSortKey:@"pageURL"
                            ascending:YES
                        withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", contextId]
                           fetchLimit:0
                           resultType:NSManagedObjectResultType
                              groupBy:nil];
    
}

@end
