//
//  PxePlayerXHTMLCDParser.m
//  PxeReader
//
//  Created by Saro Bear on 25/02/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerXHTMLCDParser.h"
#import "PxePlayerDataManager.h"
#import "PxePlayer.h"
#import "PxePageDetail.h"
#import "PXEPlayerMacro.h"

#define NCX_PARENT @"ol"
#define NCX_CHILDREN @"li"
#define NCX_ANCHOR @"a"
#define NCX_SRC @"href"
#define NCX_NAV_TITLE @"title"

#define NCX_ID @"ncx_id"
#define NCX_NAV_LABEL @"navLabel"
#define NCX_NAV_TEXT @"text"
#define NCX_PLAYORDER @"playOrder"
#define NCX_TEXT @"text"
#define NCX_CONTENT @"content"


@interface PxePlayerXHTMLCDParser ()

@end


@implementation PxePlayerXHTMLCDParser

#pragma mark - Private methods

/**
 This method would be called to convert the generic data into the model and save it into the core data.
 @param NSDictionary, data is an generic data which need to be converted into the model
 @param NSString, parentId is a root id of the branch.
 @param BOOL, isChildren checks whether the data has branches need to be looped in to the conversion.
 */
-(BOOL)parsePageDetails:(NSDictionary*)data withParentId:(NSString*)parentId childrenFound:(BOOL)isChildren
{    
    NSDictionary *ncxContent = data[NCX_ANCHOR];
    NSString *pageUrl = ncxContent[NCX_SRC];
    if(pageUrl)
    {
        PxePlayerDataManager *dataManager       = [PxePlayerDataManager sharedInstance];
        NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
        
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([PxePageDetail class])];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(pageURL contains[cd] %@) AND (context.context_id = %@)", pageUrl, self.contextId]];
        [request setFetchLimit:1];
        
        NSInteger count = [[objectContext executeFetchRequest:request error:nil] count];
        if(!count)
        {
            ++self.pageNumber;
        }
        
        NSString *pageTitle = ncxContent[NCX_NAV_TITLE];
        NSString *urlTag = @"";
        NSArray *urlCom = [pageUrl componentsSeparatedByString:@"#"];
        
        if([urlCom count] > 1)
        {
            urlTag = urlCom[1];
        }
        
        PxePageDetail *pageDetails = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxePageDetail class])
                                                                          inManagedObjectContext:objectContext];
        pageDetails.pageId = ncxContent[NCX_ID];
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
    } else {
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
    static NSInteger uniqueId = 0;
    
    for (NSDictionary *dic in childrens)
    {
        if ([dic isKindOfClass:[NSDictionary class]])
        {
            id children = dic[NCX_PARENT];
            BOOL isChildren = NO;
            if(children) {
                isChildren = YES;
            }
            
            NSMutableDictionary *ncxContent = dic[NCX_ANCHOR];
            NSString *rootId = @"root";
            
            if((ncxContent) && ([ncxContent isKindOfClass:[NSDictionary class]]))
            {
                if(!ncxContent[NCX_ID])
                {
                    [ncxContent setValue:[NSString stringWithFormat:@"root_%ld",(long)uniqueId] forKey:NCX_ID];
                    ++uniqueId;
                }
                
                if(![self parsePageDetails:dic withParentId:parentId childrenFound:isChildren]) {
                    DLog(@"Error inserting XHTML pages in core data...");
                }
                
                rootId = (ncxContent[NCX_ID] != nil) ? ncxContent[NCX_ID] : @"root";
            }
            
            if(isChildren)
            {
                if([children isKindOfClass:[NSArray class]])
                {
                    
                }
                
                NSArray *items = children[NCX_CHILDREN];
                if(![items isKindOfClass:[NSArray class]]) {
                    items = @[items];
                }
                
                [self ripPagesIntoList:items parentId:rootId];
            }
        }
        else
        {
            if([dic isKindOfClass:[NSArray class]])
            {
                for (id object in dic) {
                    [self ripPagesIntoList:object parentId:@"root"];
                }
            }
        }
    }
}


@end
