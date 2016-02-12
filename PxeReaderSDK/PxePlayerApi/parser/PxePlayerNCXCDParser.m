//
//  PxePlayerNCXCDParser.m
//  PxeReader
//
//  Created by Saro Bear on 11/02/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerNCXCDParser.h"
#import "PxePlayer.h"
#import "PxePageDetail.h"
#import "PxePlayerDataManager.h"
#import "PXEPlayerMacro.h"
#import "PxeContext.h"

#define NCX_NAVMAP @"navMap"
#define NCX_NAVPOINT @"navPoint"
#define NCX_ID @"id"
#define NCX_NAV_LABEL @"navLabel"
#define NCX_NAV_TEXT @"text"
#define NCX_NAV_TITLE @"title"
#define NCX_PLAYORDER @"playOrder"
#define NCX_TEXT @"text"
#define NCX_CONTENT @"content"
#define NCX_SRC @"src"

@implementation PxePlayerNCXCDParser

#pragma mark - Private methods

/**
 This method would be called to convert the generic data into the model and save it into the core data.
 @param NSDictionary, data is an generic data which need to be converted into the model
 @param NSString, parentId is a root id of the branch.
 @param BOOL, isChildren checks whether the data has branches need to be looped in to the conversion.
 */
-(BOOL)parsePageDetails:(NSDictionary*)data withParentId:(NSString*)parentId childrenFound:(BOOL)isChildren
{
    NSDictionary *ncxContent = data[NCX_CONTENT];
    if(![ncxContent isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    
    NSString *pageUrl = ncxContent[NCX_SRC];
    
    pageUrl = [[PxePlayer sharedInstance] formatRelativePathForJavascript:pageUrl];
    
    DLog(@"pageUrl: %@", pageUrl);
    if(pageUrl)
    {
        PxePlayerDataManager *dataManager       = [PxePlayerDataManager sharedInstance];
        NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
        
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([PxePageDetail class])];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"(pageURL contains[cd] %@) AND (context.context_id = %@)", pageUrl, self.currentContext.context_id]];
        [request setFetchLimit:1];
        
        NSInteger count = [[objectContext executeFetchRequest:request error:nil] count];
        if(!count)
        {
            ++self.pageNumber;
        }
        
        NSString *pageTitle = data[NCX_NAV_LABEL][NCX_NAV_TEXT][NCX_NAV_TITLE];
        NSString *urlTag = @"";
        NSArray *urlCom = [pageUrl componentsSeparatedByString:@"#"];
        
        if([urlCom count] > 1)
        {
            urlTag = urlCom[1];
        }
                
        PxePageDetail *pageDetails = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxePageDetail class])
                                                                          inManagedObjectContext:objectContext];
        pageDetails.pageId = data[NCX_ID];
        pageDetails.pageTitle = pageTitle;
        pageDetails.pageURL = pageUrl;
        pageDetails.parentId = parentId;
        pageDetails.urlTag = urlTag;
        pageDetails.pageNumber = [NSNumber numberWithInteger:self.pageNumber];
        pageDetails.isChildren = [NSNumber numberWithBool:isChildren];
        pageDetails.context = self.currentContext;
        pageDetails.isDownloaded = [NSNumber numberWithBool:NO];
        
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

/**
 This method would be called recursively to convert the tree of generic data into the list of models
 @param NSArray, childrens is a array of data from the tree of generic data
 @param NSString, parentId is a root id of the branch.
 */
-(void)ripPagesIntoList:(NSArray*)childrens parentId:(NSString*)parentId
{    
    for (NSDictionary *dic in childrens)
    {
        if ([dic isKindOfClass:[NSDictionary class]])
        {
            id children = dic[NCX_NAVPOINT];
            BOOL isChildren = NO;
            if(children)
            {
                isChildren = YES;
            }
            DLog(@"children count: %lu", (unsigned long)[children count]);
            
            // Check Count before proceeding
//            if ([parentId isEqualToString:@"root"])
//            {
//                PxePlayerDataManager *dataManager = [PxePlayerDataManager sharedInstance];
//                NSArray *pagesAR = [self fetchPagesForContextId:dataManager.contextId parentId:parentId];
//                if (pagesAR)
//                {
//                    if ([pagesAR count] == [children count])
//                    {
//                        break;
//                    }
//                }
//            }
            
            if(![self parsePageDetails:dic withParentId:parentId childrenFound:isChildren])
            {
                DLog(@"Error inserting NCX pages in core data...");
            }
            
            //move to the root
            NSString *rootId = (dic[NCX_ID] == nil) ? @"root" : dic[NCX_ID];
            if(isChildren)
            {
                if(![children isKindOfClass:[NSArray class]])
                {
                    children = @[children];
                }
                
                [self ripPagesIntoList:children parentId:rootId];
            }
        }
    }
}

@end
