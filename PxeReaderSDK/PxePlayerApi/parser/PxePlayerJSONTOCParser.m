//
//  PxePlayerJSONTOCParser.m
//  PxeReader
//
//  Created by Tomack, Barry on 1/23/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayer.h"
#import "PxePlayerJSONTOCParser.h"
#import "PxePlayerInterface.h"
#import "PxePlayer.h"
#import "PxePlayerDataManager.h"
#import "PxePlayerError.h"
#import "PxeContext.h"
#import "PxePageDetail.h"
#import "PXEPlayerMacro.h"
#import "PxePrintPage.h"
#import "PxePlayerDownloadManager.h"

@implementation PxePlayerJSONTOCParser

- (void) parseTOCDataFromDataInterface:(PxePlayerDataInterface *)dataInterface
                           withHandler:(ParsingHandler)parsingHandler
{
    DLog(@"tocPath: %@", dataInterface.tocPath);
    DLog(@"contextId: %@", dataInterface.contextId);
    PxePlayerJSONTOCParser * __weak weakBlocksafeSelf = self;
    
    [PxePlayerInterface getTOCDataFromAPIUsingDataInterface:dataInterface
                                      withCompletionHandler:^(NSDictionary *tocDict, NSError *error)
    {
        if(!error)
        {
            if(tocDict)
            {
                DLog(@"tocDict: %@", tocDict);
                NSString *onlineBaseURL = [tocDict objectForKey:@"baseURL"];
                DLog(@"onlineBaseURL: %@", onlineBaseURL);
                if (onlineBaseURL)
                {
                    [[PxePlayer sharedInstance] setOnlineBaseURL: onlineBaseURL forContextId:dataInterface.contextId];
                    [[PxePlayerDownloadManager sharedInstance] setOnlineBaseURL: onlineBaseURL forContextId:dataInterface.contextId];
                }
                
                PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
                 
                NSArray *contexts = [dataManager fetchEntitiesForModel:NSStringFromClass([PxeContext class])
                                                            withSortKey:@"context_id"
                                                              ascending:YES
                                                          withPredicate:[NSPredicate predicateWithFormat:@"context_id == %@", dataInterface.contextId]
                                                             fetchLimit:0
                                                             resultType:NSManagedObjectResultType];
                
                self.currentContext = [contexts lastObject];
                
                if([tocDict count] > 0)
                {
                    if([[tocDict objectForKey:@"toc"] isKindOfClass:[NSDictionary class]])
                    {
                        NSDictionary *toc = [tocDict objectForKey:@"toc"];
                        if ([[toc objectForKey:@"items"] isKindOfClass:[NSArray class]])
                        {
                            NSArray *itemArray = (NSArray*) [toc objectForKey:@"items"];
                            NSArray *pagesForContext = [self fetchPagesForContextId:dataInterface.contextId parentId:@"root"];
                            if ([pagesForContext count] != [itemArray count])
                            { //only insert if needed.
                                for (NSDictionary *item in itemArray)
                                {
                                    DLog(@"item: %@", item);
                                    [weakBlocksafeSelf ripTOCPagesIntoList:item parentId:@"root"];
                                }
                            }
                            parsingHandler(tocDict, nil); //previously returning just a BOOL -> parsingHandler([NSNumber numberWithBool:YES], nil);
                        } else {
                            parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
                        }
                    } else {
                        parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
                    }
                } else {
                    parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
                }
            } else {
                parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
            }
        } else {
            parsingHandler(nil, [PxePlayerError errorForCode:PxePlayerContextLoadError]);
        }
    }];
}

-(void)ripTOCPagesIntoList:(NSDictionary*)item parentId:(NSString*)parentId
{
    NSString *title = [item objectForKey:@"title"];
    NSString *url = [item objectForKey:@"href"];
    NSString *pageId = [item objectForKey:@"id"];

//    PLAYORDER IS UNRELIABLEY INCONSISTENT IN NUMBER ORDER
//    NSString *pageNumber = [item objectForKey:@"playOrder"];
    self.pageNumber++;
    NSString *pageNo = [NSString stringWithFormat:@"%ld", (long)self.pageNumber];
    
    if(!url)
    {
        url = @"#";
    }
    
    NSArray *items = [item objectForKey:@"items"];
    NSNumber *hasChildren = items?@YES:@NO;
    DLog(@"TITLE: %@", title);
    DLog(@"ParentID: %@::: hasChildren: %@ ::: pageNumber:%@", parentId, hasChildren, pageNo);
    PxePageDetail *pageDetail = [self insertPageTitled:title
                                               withURL:url
                                                pageId:pageId
                                              parentId:parentId
                                            isChildren:hasChildren
                                            pageNumber:pageNo];
    if (pageDetail)
    {
        NSArray *pages = [item objectForKey:@"pages"];
        if (pages)
        {
            [self insertPrintPages:pages forPage:pageDetail];
        }
    }
    
    if (items)
    {
        for (NSDictionary *item in items)
        {
            [self ripTOCPagesIntoList:item parentId:pageId];
        }
    }
}

- (PxePageDetail *) insertPageTitled:(NSString*)pageTitle
                             withURL:(NSString*)pageUrl
                              pageId:(NSString*)pageId
                            parentId:(NSString*)parentId
                          isChildren:(NSNumber*)isChildren
                          pageNumber:(NSString*)pageNumber
{
    PxePageDetail *pageDetails;
    DLog(@"PageID: %@", pageId);
    if(pageUrl)
    {        
        PxePlayerDataManager *dataManager       = [PxePlayerDataManager sharedInstance];
        NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
        
        NSString *urlTag = @"";
        NSArray *urlCom = [pageUrl componentsSeparatedByString:@"#"];
        
        if([urlCom count] > 1)
        {
            urlTag = urlCom[1];
            if([urlTag isEqualToString:@""])
            {
                urlTag = @"#";
            }
        }
        else
        {
            urlTag = @"#";
        }
        
        pageDetails = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxePageDetail class])
                                                    inManagedObjectContext:objectContext];
        pageDetails.pageId = pageId;
        pageDetails.pageTitle = pageTitle;
        pageDetails.pageURL = pageUrl;
        pageDetails.parentId = parentId;
        pageDetails.urlTag = urlTag;
        pageDetails.pageNumber = [NSNumber numberWithInteger:[pageNumber intValue]];
        pageDetails.isChildren = isChildren;
        pageDetails.context = self.currentContext;
        pageDetails.isDownloaded = [NSNumber numberWithBool:NO];
        
        if(![[PxePlayerDataManager sharedInstance] save])
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
    
    return pageDetails;
}

- (void) insertPrintPages:(NSArray *)pages forPage:(PxePageDetail *)pageDetail
{
    for (NSDictionary *page in pages)
    {
        [self insertPrintPageData:page forPage:pageDetail];
    }
}

- (PxePrintPage *) insertPrintPageData:(NSDictionary *)printDict forPage:(PxePageDetail *)pageDetail
{
    PxePlayerDataManager *dataManager       = [PxePlayerDataManager sharedInstance];
    NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
    
    NSString *printPageTitle = [printDict objectForKey:@"title"];
    NSString *printPageHref = [printDict objectForKey:@"href"];
    DLog(@"printPageTitle: %@", printPageTitle);
    DLog(@"printPageHref: %@", printPageHref);
    
    PxePrintPage *printPage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxePrintPage class])
                                                            inManagedObjectContext:objectContext];
    printPage.pageNumber = printPageTitle;
    printPage.pageURL = printPageHref;
    printPage.page = pageDetail;
    DLog(@"printPage: %@", printPage);
    
    if(![[PxePlayerDataManager sharedInstance] save])
    {
        return nil;
    }
    
    return printPage;
}

@end
