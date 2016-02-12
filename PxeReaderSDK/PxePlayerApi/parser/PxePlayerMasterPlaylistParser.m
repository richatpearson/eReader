//
//  PxePlayerMasterPlaylistParser.m
//  SanVanEcourses
//
//  Created by Mason, Darren J on 10/16/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerMasterPlaylistParser.h"
#import "PxePlayerDataManager.h"
#import "PxePlayer.h"
#import "PxePageDetail.h"

@implementation PxePlayerMasterPlaylistParser

/**
 This method would be called to convert the generic data into the model and save it into the core data.
 @param NSDictionary, data is an generic data which need to be converted into the model
 @param NSString, parentId is a root id of the branch.
 @param BOOL, isChildren checks whether the data has branches need to be looped in to the conversion.
 */
- (BOOL) parsePageDetails:(NSDictionary*)data
             forContextId:(NSString*)contextId
{
    NSString *pageUrl = data[@"url"];
    
    if(pageUrl)
    {
        PxePlayerDataManager *dataManager       = [PxePlayerDataManager sharedInstance];
        NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
        
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([PxePageDetail class])];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(pageURL contains[cd] %@) AND (context.context_id = %@)", pageUrl, contextId]];
        [request setFetchLimit:1];
        
        NSInteger count = [[objectContext executeFetchRequest:request error:nil] count];
        if(!count)
        {
            // if no count, then this is a new record
            ++self.pageNumber;
            
            NSString *urlTag = @"";
            NSString *pageTitle =@"";
            
            PxePageDetail *pageDetails = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxePageDetail class])
                                                                       inManagedObjectContext:objectContext];
            pageDetails.pageId = nil;
            pageDetails.pageTitle = pageTitle;
            pageDetails.pageURL = pageUrl;
            pageDetails.parentId = @"rootId";
            pageDetails.urlTag = urlTag;
            pageDetails.pageNumber = [NSNumber numberWithInteger:self.pageNumber];
            pageDetails.isChildren = [NSNumber numberWithBool:NO];
            pageDetails.context = self.currentContext;
            pageDetails.isDownloaded = [NSNumber numberWithBool:NO];
            
            if(![dataManager save])
            {
                return NO;
            }
        }
    }
    else
    {
        return NO;
    }
    
    return YES;
}

/**
 This method would be called to load urls into DB
 @param NSArray, childrens is a array of data from the tree of generic data
 @param NSString, parentId is a root id of the branch.
 */
-(void)ripPagesIntoList:(NSArray*)childrens
               parentId:(NSString*)parentId
           forContextId:(NSString*)contextId
{
    for(NSString *url in childrens)
    {
        [self parsePageDetails:@{@"url":url}
                  forContextId:contextId];
    }
}




@end
