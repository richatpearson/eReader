//
//  PxePlayerXHTMLCDParser.m
//  PxeReader
//
//  Created by Saro Bear on 25/02/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerXHTMLParser.h"
#import "PxePlayerDataManager.h"
#import "PxePlayer.h"
#import "PxeCustomBasketDetail.h"
#import "PxePageDetail.h"
#import "PXEPlayerMacro.h"
#import "PxeContext.h"

@interface PxePlayerXHTMLParser ()

@property (nonatomic, assign) BOOL testedForAppendingXHTML;
@property (nonatomic, assign) BOOL appendXHTMLToPageUrl;

@end

@implementation PxePlayerXHTMLParser


#pragma mark - Private methods

/**
 This method would be called to convert the generic data into the model and save it into the core data.
 @param NSDictionary, data is an generic data which need to be converted into the model
 @param NSString, parentId is a root id of the branch.
 @param BOOL, isChildren checks whether the data has branches need to be looped in to the conversion.
 */
- (BOOL) parsePageDetails:(NSDictionary*)data
             withParentId:(NSString*)parentId
            childrenFound:(BOOL)isChildren
             toPutInTable:(NSString*)tableName
{
    if(data[@"li"]) {
        return NO;
    }
    
    if(data[@"a"]) {
        data = data[@"a"];
    }
    
    if(data[@"ol"]){
        return NO;
    }
    
    NSString *pageUrl = data[@"href"];
    if(pageUrl)
    {
        DLog(@"pageURL: %@", pageUrl);
        if([pageUrl rangeOfString:@"http:/"].location == NSNotFound && [pageUrl rangeOfString:@"https:/"].location == NSNotFound)
        {
            if(! self.testedForAppendingXHTML)
            {
                [self testForAppendingXHTML: pageUrl];
            }
            pageUrl = [self appendURL:pageUrl withXHTML:self.appendXHTMLToPageUrl];
        }
        
        PxePlayerDataManager *dataManager       = [PxePlayerDataManager sharedInstance];
        NSManagedObjectContext *objectContext   = [dataManager getObjectContext];
        
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:tableName];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(pageURL contains[cd] %@) AND (context.context_id = %@)", pageUrl, self.currentContext.context_id]];
        [request setFetchLimit:1];
        
        NSInteger count = [[objectContext executeFetchRequest:request error:nil] count];
        if(!count)
        {
            ++self.pageNumber;
        }
        NSString *pageTitle = data[@"title"];
        NSString *urlTag = @"";
        NSArray *urlCom = [pageUrl componentsSeparatedByString:@"#"];
        
        if([urlCom count] > 1)
        {
            urlTag = urlCom[1];
        }
        
        NSManagedObject *objectDetails = [NSEntityDescription insertNewObjectForEntityForName:tableName
                                                                       inManagedObjectContext:objectContext];
        [objectDetails setValue: data[@"id"] forKey:@"pageId"];
        [objectDetails setValue: pageTitle forKey:@"pageTitle"];
        [objectDetails setValue: pageUrl forKey:@"pageURL"];
        [objectDetails setValue: parentId forKey:@"parentId"];
        [objectDetails setValue: urlTag forKey:@"urlTag"];
        [objectDetails setValue: [NSNumber numberWithInteger:self.pageNumber] forKey:@"pageNumber"];
        [objectDetails setValue: [NSNumber numberWithBool:isChildren] forKey:@"isChildren"];
        [objectDetails setValue: self.currentContext forKey:@"context"];
        
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

- (void) testForAppendingXHTML:(NSString*)fileURL
{
    NSString *testURL = [self appendURL:fileURL withXHTML:YES];
    
    self.appendXHTMLToPageUrl = [[PxePlayer sharedInstance] webFileExists:testURL];
    
    self.testedForAppendingXHTML = YES;
}
    
- (NSString*) appendURL:(NSString*)fileURL withXHTML:(BOOL)withXHTML
{
    DLog(@"fileURL: %@", fileURL);
    if(withXHTML)
    {
        DLog(@"[[PxePlayer sharedInstance] getBaseURL]: %@", [[PxePlayer sharedInstance] getBaseURL]);
        return [[[PxePlayer sharedInstance] getBaseURL] stringByAppendingString:[NSString stringWithFormat:@"xhtml/%@",fileURL]];
    }
    
    return [[[PxePlayer sharedInstance] getBaseURL] stringByAppendingString:[NSString stringWithFormat:@"%@",fileURL]];
}

- (void) ripCustomBasketPagesIntoList:(id)childrens
                             parentId:(NSString*)parentId
                         forContextId:contextId
{
    static BOOL hasChildren = NO;
    static BOOL foundRoot = NO;
//    DLog(@"parentID: %@", parentId);
    
    if([parentId isEqualToString:@"root"])
    {
        hasChildren = YES;
    }
    
    for (id key in childrens)
    {
        //dicts only
        if([childrens[key] isKindOfClass:[NSDictionary class]])
        {
            // 1. if list item grab the a
            // 2. if the list item is an array loop the array and grab the a
            // 3. if the list item has an OL call recursive and start over
            if(childrens[@"ol"] && [childrens[@"ol"][@"li"] isKindOfClass:[NSArray class]])
            {
                if(childrens[@"ol"][@"li"][0])
                {
                    hasChildren = YES;
                }
            }
            else if(childrens[@"ol"] && [childrens[@"ol"][@"li"] isKindOfClass:[NSDictionary class]])
            {
                if(childrens[@"ol"][@"li"])
                {
                    hasChildren = YES;
                }
            }
            
            if(childrens[key])
            {
                if ([childrens[key] isKindOfClass:[NSArray class]])
                {
                    //loop all the kids
                    for (id kid in [childrens objectForKey:key])
                    {
                        if(![self parsePageDetails:kid
                                      withParentId:parentId
                                     childrenFound:hasChildren
                                      toPutInTable:NSStringFromClass([PxeCustomBasketDetail class])])
                        {
//                            NSUInteger size = [[childrens[key] description] length] > 150? 150 : [[childrens[key] description]length];
//                            DLog(@"1. wrong data type (%@)..., moving on...",[[childrens[key] description] substringToIndex:size]);
                        } else {
//                            DLog(@"GOT ONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%@", [childrens[key] description]);
                            if(!foundRoot) foundRoot = YES;
                        }
                        hasChildren = NO;
                    }
                } else {
                    if(![self parsePageDetails:childrens[key]
                                  withParentId:parentId
                                 childrenFound:hasChildren
                                  toPutInTable:NSStringFromClass([PxeCustomBasketDetail class])])
                    {
//                        NSUInteger size = [[childrens[key] description] length] > 150? 150 : [[childrens[key] description]length];
//                        DLog(@"2. wrong data type (%@)..., moving on...",[[childrens[key] description] substringToIndex:size]);
                        if(childrens[@"id"])
                        {
                            if (foundRoot) {
                                parentId = childrens[@"id"];
                            }
                        }
//                        DLog(@"1. [%@] Drilling Down into: %@", key, parentId);
                        [self ripCustomBasketPagesIntoList:childrens[key]
                                                  parentId:parentId
                                              forContextId:contextId];
                    } else {
//                        DLog(@"GOT ONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%@", [childrens[key] description]);
                        if(!foundRoot) foundRoot = YES;
                    }
                    hasChildren = NO;
                    if (foundRoot) {
                        parentId = childrens[@"a"][@"id"];
                    }
                }
            }
        }
        else if([childrens[key] isKindOfClass:[NSArray class]])
        {
            //loop this and get out its goodies
            for (id kids in [childrens objectForKey:key])
            {
//                DLog(@"3. [%@] Dilling Down into %@",key,parentId);
                [self ripCustomBasketPagesIntoList:kids
                                          parentId:parentId
                                      forContextId:contextId];
            }
        }
    }
}

/**
 Public method exposed to call but before it can rip needs to get the last item in the array
 */
-(void)ripPagesIntoList:(id)childrens parentId:(NSString*)parentId
{
    [self ripper:[childrens lastObject] parentId:parentId];
}

/**
 This method would be called recursively to convert the tree of generic data into the list of models
 @param NSArray, childrens is a array of data from the tree of generic data
 @param NSString, parentId is a root id of the branch.
 */

-(void)ripper:(id)childrens parentId:(NSString*)parentId
{
    BOOL isChildren = NO;
    BOOL hasChildren = NO;
    
    if(childrens[@"li"] && [childrens[@"li"] isKindOfClass:[NSDictionary class]])
    {
        id children = childrens[@"li"][@"ol"];
        
        if(children)
        {
            isChildren = YES;
        }
    }
    
    if([parentId isEqualToString:@"root"])
    {
        hasChildren=YES;
    }
    
    for (id key in childrens)
    {
        //dicts only
        if([childrens[key] isKindOfClass:[NSDictionary class]])
        {
            // 1. if list item grab the a
            // 2. if the list item is an array loop the array and grab the a
            // 3. if the list item has an OL call recursive and start over
            if(childrens[key])
            {
                if ([childrens[key] isKindOfClass:[NSArray class]])
                {
                    //loop all the kids
                    for (id kid in [childrens objectForKey:key])
                    {
                        if([key isEqualToString:@"a"] && childrens[@"ol"] && childrens[@"ol"][@"li"])
                        {
                            hasChildren = YES;
                        }
                        
                        if(![self parsePageDetails:kid
                                      withParentId:parentId
                                     childrenFound:hasChildren
                                      toPutInTable:NSStringFromClass([PxePageDetail class])])
                        {
//                            NSUInteger size = [[childrens[key] description] length] > 150? 150 : [[childrens[key] description]length];
//                            DLog(@"1. wrong data type (%@)..., moving on...",[[childrens[key] description] substringToIndex:size]);
                        }
                    }
                }
                else
                {
                    if([key isEqualToString:@"a"] && childrens[@"ol"] && childrens[@"ol"][@"li"])
                    {
                        hasChildren = YES;
                    }
                    
                    if(![self parsePageDetails:childrens[key]
                                  withParentId:parentId
                                 childrenFound:hasChildren
                                  toPutInTable:NSStringFromClass([PxePageDetail class])])
                    {
//                        NSUInteger size = [[childrens[key] description] length] > 150? 150 : [[childrens[key] description]length];
//                        DLog(@"2. wrong data type (%@)..., moving on...",[[childrens[key] description] substringToIndex:size]);
                        parentId = childrens[@"a"][@"id"];
                        [self ripper:childrens[key] parentId:parentId];
                    }
                }
                if(isChildren)
                {
//                    DLog(@"1. Dilling Down into %@",childrens[key][@"id"]);
                    parentId = childrens[key][@"a"][@"id"];
                    [self ripper:childrens[key][@"ol"] parentId:parentId];
                }
            }
        }
        else if([childrens[key] isKindOfClass:[NSArray class]])
        {
            //loop this and get out its goodies
            for (id kids in [childrens objectForKey:key])
            {
//                DLog(@"2. Dilling Down into %@",parentId);
                [self ripper:kids parentId:parentId];
            }
        }
    }
}

@end
