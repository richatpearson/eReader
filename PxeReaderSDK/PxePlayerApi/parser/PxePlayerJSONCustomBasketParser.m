//
//  PxePlayerJSONCustomBasketParser.m
//  PxeReader
//
//  Created by Tomack, Barry on 12/4/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerJSONCustomBasketParser.h"
#import "PxePlayerInterface.h"
#import "PxePlayerError.h"
#import "PXEPlayerMacro.h"
#import "PxePlayerDataManager.h"
#import "PxeContext.h"
#import "PxePlayer.h"
#import "PxeCustomBasketDetail.h"
#import "PxePageDetail.h"

@implementation PxePlayerJSONCustomBasketParser

- (void) parseCustomBasketDataFromDataInterface:(PxePlayerDataInterface *)dataInterface
                                    withHandler:(ParsingHandler)parsingHandler
{
    self.contextId = dataInterface.contextId;
    [PxePlayerInterface getCustomBasketDataFromAPIUsingDataInterface:dataInterface
                                               withCompletionHandler:^(NSDictionary *basketDict, NSError *error)
     {
         if(!error)
         {
             DLog(@"!PARSED!: %@", basketDict);
             if(basketDict)
             {
                 if([basketDict count] > 0)
                 {
                     self.pageNumber = 0;
                     
                     self.currentContext = [self getCurrentContext];
                     DLog(@"currentContext: %@ ::: context_id: %@", self.currentContext, self.contextId)
                     if([[basketDict objectForKey:@"contents"] isKindOfClass:[NSArray class]])
                     {
                         NSArray *contentsArray = (NSArray*) [basketDict objectForKey:@"contents"];
                         for (NSDictionary *item in contentsArray)
                         {
                             [self ripCustomBasketPagesIntoList:item parentId:@"root"];
                         }
                         parsingHandler([NSNumber numberWithBool:YES], nil);
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

-(void)ripCustomBasketPagesIntoList:(NSDictionary*)item parentId:(NSString*)parentId
{
    NSString *title = [item objectForKey:@"title"];
    NSString *url = [item objectForKey:@"url"];
    
    if(!url)
    {
        url = @"#";
    }
    
    NSString *pageId = [[NSUUID UUID] UUIDString];
    
    NSArray *contents = [item objectForKey:@"contents"];
    NSNumber *hasChildren = contents?@YES:@NO;
    DLog(@"TITLE: %@", title);
    DLog(@"ParentID: %@::: hasChildren: %@::: contents: %@", parentId, hasChildren, contents);
    [self insertPageTitled:title
                   withURL:url
                    pageId:pageId
                  parentId:parentId
                isChildren:hasChildren
              toPutInTable:NSStringFromClass([PxeCustomBasketDetail class])];
    
    if (contents)
    {
        for (NSDictionary *item in contents)
        {
            [self ripCustomBasketPagesIntoList:item parentId:pageId];
        }
    }
}

- (BOOL) insertPageTitled:(NSString*)pageTitle
                  withURL:(NSString*)pageURL
                   pageId:(NSString*)pageId
                 parentId:(NSString*)parentId
               isChildren:(NSNumber*)isChildren
             toPutInTable:(NSString*)tableName
{
    if(pageURL)
    {        
        PxePlayerDataManager *dataManager       = [PxePlayerDataManager sharedInstance];
        NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
        
        NSInteger thisPage = [self getPageNumberForPageURL:pageURL
                                                 contextId:self.currentContext.context_id
                                             objectContext:objectContext];
        
        NSString *urlTag = @"";
        NSArray *urlCom = [pageURL componentsSeparatedByString:@"#"];
        
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
        
        PxeCustomBasketDetail *customBasket = [NSEntityDescription insertNewObjectForEntityForName:tableName
                                                                       inManagedObjectContext:objectContext];
        
        [customBasket setValue: pageId forKey:@"pageId"];
        [customBasket setValue: pageTitle forKey:@"pageTitle"];
        [customBasket setValue: pageURL forKey:@"pageURL"];
        [customBasket setValue: parentId forKey:@"parentId"];
        [customBasket setValue: urlTag forKey:@"urlTag"];
        if(thisPage > 0)
        {
            [customBasket setValue: [NSNumber numberWithInteger:thisPage] forKey:@"pageNumber"];
        }
        [customBasket setValue: isChildren forKey:@"isChildren"];
        [customBasket setValue: self.currentContext forKey:@"context"];
        DLog(@"self.currentContext: %@", self.currentContext)
        DLog(@"custom Basket: %@", customBasket);
        if(![dataManager save])
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
    
    return YES;
}

- (NSInteger) getPageNumberForPageURL:(NSString*)pageURL
                            contextId:(NSString*)contextId
                        objectContext:(NSManagedObjectContext*)objContext
{
//    DLog(@"pageURL: %@", pageURL)
    NSInteger pNum = 0;
    
    if (![pageURL isEqualToString:@"#"])
    {
        NSArray *splitURL = [pageURL componentsSeparatedByString:@"#"];
//        DLog(@"splitURL: %@", splitURL);
        if ([splitURL count] > 0)
        {
            NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([PxePageDetail class])];
            [request setPredicate:[NSPredicate predicateWithFormat:@"(pageURL contains[cd] %@) AND (context.context_id = %@)", [splitURL objectAtIndex:1], contextId]];
            [request setFetchLimit:1];
            
            NSArray *results = [objContext executeFetchRequest:request error:nil];
            
            NSInteger count = [results count];
            if(count)
            {
                PxePageDetail *pageDetails = [results objectAtIndex:0];
                pNum = [pageDetails.pageNumber integerValue];
            }
        }
    }
    
    return pNum;
}

- (PxeContext*) getCurrentContext
{
    PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
    
    PxeContext *currContext = nil;
    
    NSArray *contextResults = [dataManager fetchEntities:@[@"context_id"]
                                                forModel:NSStringFromClass([PxeContext class])
                                           withPredicate:[NSPredicate predicateWithFormat:@"context_id == %@", self.contextId]
                                              resultType:NSManagedObjectResultType withSortKey:nil
                                            andAscending:YES
                                              fetchLimit:1
                                              andGroupBy:nil];
    if([contextResults count])
    {
        currContext = contextResults[0]; //just grab that first book and set it
    }
    
    return currContext;
}

@end
