//
//  PxePlayerManifestParser.m
//  PxeReader
//
//  Created by Richard Rosiak on 6/26/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayerManifestParser.h"
#import "PxePlayerManifest.h"
#import "PxePlayerManifestItem.h"
#import "PxePlayerDataManager.h"
#import "PxeContext.h"
#import "PXEPlayerMacro.h"
#import "PxeManifestChunk.h"
#import "NSString+Extension.h"
#import "PxePlayerUIConstants.h"
#import "PxePlayer.h"
#import "PxePlayerError.h"

@interface PxePlayerManifestParser()

@property (nonatomic, strong) PxePlayerDataManager *dataManager;

@end

@implementation PxePlayerManifestParser

- (void) parseManifestDataDictionary:(NSDictionary*)dataDict
                       dataInterface:(PxePlayerDataInterface*)dataInterface
                         tocChapters:(NSDictionary*)chapters
                         withHandler:(ParsingHandler)parsingHandler
{
    if([[dataDict objectForKey:@"content"] isKindOfClass:[NSDictionary class]])
    {
        PxeContext *dbContext;
        self.dataManager = [PxePlayerDataManager sharedInstance];
        
        NSArray *contexts = [self.dataManager fetchEntitiesForModel:NSStringFromClass([PxeContext class])
                                                   withSortKey:@"context_id"
                                                     ascending:YES
                                                 withPredicate:[NSPredicate predicateWithFormat:@"context_id == %@", dataInterface.contextId]
                                                    fetchLimit:0
                                                    resultType:NSManagedObjectResultType];
        DLog(@"CONTEXTs: %@", contexts);
        dbContext = [contexts lastObject];
        
        if(!dbContext)
        {
            dbContext = [[PxePlayerDataManager sharedInstance] createCurrentContextWithDataInterface:dataInterface
                                                                                         currentUser:[[PxePlayer sharedInstance] currentUser]
                                                                                         withHandler:nil];
        }
        
        [self parseParentManifestData:[dataDict objectForKey:@"content"]
                            dbContext:dbContext
                          tocChapters:(NSDictionary*)chapters
                    completionHandler:^(NSError *error) {
                                                if (!error) {
                                                    DLog(@"Successfully parsed and inserted manifest");
                                                    parsingHandler([NSNumber numberWithBool:YES], nil);
                                                }
                                                else {
                                                    parsingHandler(nil, error);
                                                }
                                        }];
    }
    else
    {
        //dictionary formatting issue
        DLog(@"FORMATTING ISSUE");
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Manifest Parser was unsuccessful.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The data was poorly formatted.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Can't really do anything about it!", nil)
                                   };
        
        NSError *error = [PxePlayerError errorForCode:25
                                          errorDetail:userInfo];
        parsingHandler(nil, error);
    }
}

-(void) parseParentManifestData:(NSDictionary*)dataDict
                      dbContext:(PxeContext*)dbContext
                    tocChapters:(NSDictionary*)chapters
              completionHandler:(void (^)(NSError *))handler {
    
    PxePlayerManifest *manifest = [PxePlayerManifest new];
    
    manifest.totalSize = (NSNumber *)[self alwaysNSNumber:[dataDict valueForKey:@"totalSize"]];
    manifest.bookTitle = [dataDict valueForKey:@"title"];
    manifest.baseUrl = [dataDict valueForKey:@"baseUrl"];
    manifest.epubFileName = [dataDict valueForKey:@"src"];
    
    manifest.items = [self parseManifestItemsData:[dataDict objectForKey:@"items"]
                                         manifest:manifest
                                        contextId:dbContext.context_id
                                tocChapters:(NSDictionary*)chapters];
    
    [self insertManifestData:manifest dbContext:dbContext completionHandler:^(NSError *error) {
        if (!error) {
            handler(nil);
        }
        else {
            handler(error);
        }
    }];
}

-(NSArray*) parseManifestItemsData:(NSDictionary*)itemsData
                          manifest:(PxePlayerManifest*)manifest
                         contextId:(NSString*)contextId
                       tocChapters:(NSDictionary*)tocChapters {
    
    NSMutableArray *manifestItems = [[NSMutableArray alloc] init];
    
    [manifestItems addObject:[self addBookAsManifestItem:manifest contextId:contextId]];
    
    NSInteger itemCounter = 0;
    NSArray *tocChapterArray = (NSArray*)tocChapters;
    
    for (NSDictionary *dictItem in itemsData)
    {
        PxePlayerManifestItem *item = [PxePlayerManifestItem new];
        item.size = (NSNumber *)[self alwaysNSNumber:[dictItem valueForKey:@"size"]];
        item.assetId = [dictItem valueForKey:@"id"];
        item.title = [[tocChapterArray objectAtIndex:itemCounter] valueForKey:@"title"]; //title comes from TOC Level 1
        item.baseUrl = [dictItem valueForKey:@"baseUrl"];
        item.epubFileName = [dictItem valueForKey:@"src"];
        item.isDownloaded = NO;
        
        [manifestItems addObject:item];
        itemCounter++;
    }
    
    return manifestItems;
}

- (PxePlayerManifestItem*) addBookAsManifestItem:(PxePlayerManifest*)manifest contextId:(NSString*)contextId
{
    PxePlayerManifestItem *manifestItem = [PxePlayerManifestItem new];
    
    manifestItem.size = (NSNumber *)[self alwaysNSNumber:manifest.totalSize];
    manifestItem.assetId = contextId;
    manifestItem.title = PXEPLAYER_BOOK_TITLE_AS_ASSET;
    manifestItem.baseUrl = manifest.baseUrl;
    manifestItem.epubFileName = manifest.epubFileName;
    manifestItem.isDownloaded = NO;
    
    return manifestItem;
}

-(void) insertManifestData:(PxePlayerManifest*)manifest
                 dbContext:(PxeContext*)dbContext
         completionHandler:(void (^)(NSError *))handler {
    
    [self.dataManager createManifest:manifest
                           dbContext:dbContext
               withCompletionHandler:^(PxeManifest* dbManifest, NSError *error) {
                   
                   if (dbManifest) {
                       [self insertItemsForManifest:manifest dbManifest:dbManifest completionHandler:^(NSError *error) {
                           if (!error) {
                               handler(nil);
                           }
                           else {
                               handler(error);
                           }
                       }];
                   }
               }];
}

-(void) insertItemsForManifest:(PxePlayerManifest*)manifest
                  dbManifest:(PxeManifest*)dbManifest
           completionHandler:(void (^)(NSError *))handler {
    
    for (PxePlayerManifestItem *manifestItem in manifest.items) {
        
        [self.dataManager createManifestItem:manifestItem dbManifest:dbManifest withCompletionHandler:^(PxeManifestChunk *dbChunk, NSError *error) {
            if (dbChunk) {
                DLog(@"Inserted manifestItem with epub file name %@", dbChunk.src);
            }
            if (error) {
                handler(error);
                return;
            }
        }];
    }
    handler(nil);
}

/**
 Manifest Data isn't always so good!
 */
- (NSNumber *) alwaysNSNumber:(id)value
{
    NSNumber *alwaysNum;
    id numCheck = value;
    if ([numCheck isKindOfClass:[NSString class]])
    {
        NSString *totalSizeStr = (NSString *)numCheck;
        alwaysNum = [totalSizeStr asNSNumber];
    }
    else
    {
        alwaysNum = (NSNumber *)value;
    }
    return alwaysNum;
}

@end
