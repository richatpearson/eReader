//
//  PxePlayerDataManager.m
//  PxeReader
//
//  Created by Saro Bear on 25/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayer.h"
#import "PxePlayerDataManager.h"
#import "PxePageDetail.h"
#import "PxeGlossary.h"
#import "PxeCustomBasketDetail.h"
#import "HMCache.h"
#import "PxePlayerUIConstants.h"
#import "PXEPlayerMacro.h"
#import "PxeContext.h"
#import "PxeUser.h"
#import "PxePlayerError.h"
#import "PxePlayerUser.h"
#import "PxeManifest.h"
#import "PxeManifestChunk.h"
#import "PxePlayerManifest.h"
#import "PxePlayerManifestItem.h"
#import "PxeManifestChunk.h"
#import "NSString+Extension.h"
#import "Reachability.h"
#import "PxePlayerDataMigrator.h"
#import "PXEPlayerUIConstants.h"

#define kDataModelName  @"PxePlayerDataModel"
#define kDataSqliteName @"PxePlayerData.sqlite"

@interface PxePlayerDataManager ()

/**
 A NSManagetObjectModel variable for creating object model on the particular location for core data persistent store
 */
@property (nonatomic, strong) NSManagedObjectModel          *objectModel;

/**
 A NSManagedObjectContext variable for creating context for the current store coordinator
 */
@property (nonatomic, strong) NSManagedObjectContext        *objectContext;

/**
 A NSPersistentStoreCoordinator variable for creating store coordinator for the specific location
 */
@property (nonatomic, strong) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

@end


@implementation PxePlayerDataManager

#pragma mark - Private methods

/**
 This method would be called access the cache directory path
 @return NSString, returns the cache path directory location
 */
-(NSString*)cachePath
{
    NSString *dbPath = [HMCache createDirectory:CD_DIR];
    return dbPath;
}

#pragma mark - Self methods

+(PxePlayerDataManager*)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    static PxePlayerDataManager* instance = nil;
    DLog("dataManager SharedInstance");
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance dataManagerInit];
    });
    
    return instance;
}

- (void) dataManagerInit
{
    DLog(@"SINGLETON INIT");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    DLog(@"userDefaults: %@", [userDefaults dictionaryRepresentation]);
    NSString *currentPxeVersion = [[PxePlayer sharedInstance] getPXEVersion];
    DLog(@"currentPxeVersion: %@", currentPxeVersion);
    if (currentPxeVersion)
    {
        if ( ![userDefaults valueForKey:@"pxeVersion"] )
        {
            // CALL pxePlayerDataMigrator;
            DLog(@"CALL DATA_MIGRATION FOR NON_EXISTENT PXE VERSION");
            [self doDataMigration];
            // Adding version number to NSUserDefaults for first version:
            [userDefaults setObject:currentPxeVersion forKey:@"pxeVersion"];
        }
        
        if ([[userDefaults objectForKey:@"pxeVersion"] isEqualToString:currentPxeVersion])
        {
            // Same Version so dont run the function
            DLog(@"DO NOT CALL DATA_MIGRATION");
        }
        else
        {
            // Call pxePlayerDataMigrator;
            DLog(@"CALL DATA_MIGRATION FOR NEW PXE VERISON");
            [self doDataMigration];
            // Update version number to NSUserDefaults for other versions:
            [userDefaults setObject:currentPxeVersion forKey:@"pxeVersion"];
        }
    }
}

- (void) doDataMigration
{
    PxePlayerDataMigrator *dataMigrator = [[PxePlayerDataMigrator alloc] init];
    [dataMigrator migrateDataForContext:[self getObjectContext]
                             onComplete:^(NSString *results, NSError *error) {
                                 DLog(@"Data Migration Complete: results: %@ :::: error: %@", results, error);
                                 // Notify Client Application that an error occurred
                                 if (error) {
                                     NSDictionary *errorInfo = @{PXEPLAYER_ERROR:error};
                                     [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_VERSION_UPDATE_FAILED
                                                                                         object:self
                                                                                       userInfo:errorInfo];

                                 }
                            }];
}

#pragma mark - Public methods

/**
 Method can't be unit tested because bundle path is null in [self getObjectModel].
 */

-(NSManagedObjectContext*)getObjectContext
{
    if(self.objectContext)
    {
        return self.objectContext;
    }
    
    DLog(@"Currently on thread %@", [NSThread currentThread]);
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(getObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
        
        return self.objectContext;
    }
    self.objectContext = [[NSManagedObjectContext alloc] init];
    [self.objectContext setPersistentStoreCoordinator:[self getPersistentStoreCoordinator]];
    
    return self.objectContext;
}

/**
 This method would be called to get the object model to create the persistent store co-ordinator to the specific location 
 @return NSManagedObjectModel ,  returns the managed object model created on the given location
 
 Method can't be unit tested because bundle path is null.
 */
-(NSManagedObjectModel*)getObjectModel
{
    if(self.objectModel)
    {
        return self.objectModel;
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kDataBundleName ofType:@"bundle"];
//    DLog(@"BUNDLE PATH: %@", bundlePath);
//    DLog(@"ALL BUNDLES: %@", [NSBundle allBundles]);
    if (!bundlePath)
    {
        DLog(@"UNIT TESTS")
        // For unit testing...
        // Get the bundle from whatever instantiated the class (unit test?)
        // Main Bundle is always the application bundle, but things like Unit tests have their own bundle
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *mPath = [bundle pathForResource:kDataModelName ofType:@"momd"];
        self.objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:mPath]];
    } else {
        NSString *modelPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:kDataModelName ofType:@"momd"];
        self.objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    }
    
    return self.objectModel;
}

/**
 This method would be called to get the persistent store coordinator created on the specific location
 @return NSPersistentStoreCoordinator ,  returns the persistent store co-ordinator created on the given location
 */
- (NSPersistentStoreCoordinator*) getPersistentStoreCoordinator
{
    if(self.persistentStoreCoordinator)
    {
        return self.persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self cachePath] stringByAppendingPathComponent:kDataSqliteName];    
    NSURL   *storeUrl = [NSURL fileURLWithPath:storePath];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    NSError *error = nil;
    
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self getObjectModel]];
    
    if(![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:storeUrl
                                                            options:options
                                                              error:&error])
    {
        NSLog(@"Fatal error creating persistent store %@",[error localizedDescription]);
        
        //abort();
    }
    
    return self.persistentStoreCoordinator;
}

-(BOOL)save
{
//    DLog(@"SAVING DATA.. \n\n");
    if(![self.objectContext hasChanges])
    {
        return YES;
    }
    
    NSError *error = nil;
    if(![self.objectContext save:&error])
    {
        DLog(@"ERROR SAVING: %@", error);
        return NO;
    }
    
    return YES;
}

#pragma mark - Fetch methods

- (NSArray*) fetchEntitiesForModel:(NSString*)model
                       withSortKey:(NSString*)sortKey
                         ascending:(BOOL)isAscending
                     withPredicate:(NSPredicate*)predicate
                        fetchLimit:(NSUInteger)limit
                        resultType:(NSUInteger)resultType
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:model];
    [fetchRequest setFetchLimit:limit];
    [fetchRequest setResultType:resultType];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsDistinctResults:YES];
    DLog(@"Predicate: %@", predicate);
    if(sortKey)
    {
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:isAscending]]];
    }
    
    NSArray *results = [[self getObjectContext] executeFetchRequest:fetchRequest error:nil];
    return results;
}


- (NSArray*) fetchEntities:(NSArray*)property
                  forModel:(NSString*)model
               withSortKey:(NSString*)sortKey
                 ascending:(BOOL)isAscending
             withPredicate:(NSPredicate*)predicate
                fetchLimit:(NSUInteger)limit
                resultType:(NSUInteger)resultType
                   groupBy:(NSArray*)groups
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:model
                                              inManagedObjectContext:[self getObjectContext]];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:model];
    
    [fetchRequest setFetchLimit:limit];
    [fetchRequest setPropertiesToFetch:property];
    [fetchRequest setResultType:resultType];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsDistinctResults:YES];
    
    DLog(@"FETCH entity - predicate is: %@", predicate.description);

    if(groups)
    {
        NSMutableArray *groupBy = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSString *prop in groups)
        {
            DLog(@"entity.attributesByName: %@", entity.attributesByName)
            DLog(@"prop: %@", prop)
            NSAttributeDescription *groupDesc = [entity.attributesByName objectForKey:prop];
            [groupBy addObject:groupDesc];
        }
        
        [fetchRequest setPropertiesToFetch:groupBy];
        [fetchRequest setPropertiesToGroupBy:groupBy];
    }
    
    if(sortKey)
    {
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:isAscending]]];
    }
    
    NSArray *results = [[self getObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    return results;
}

- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
            andKey:(NSString*)key
        resultType:(NSUInteger)resultType
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending
{
    NSArray *results = [self fetchEntities:@[property]
                                  forModel:model
                               withSortKey:sortKey
                                 ascending:isAscending
                             withPredicate:[NSPredicate predicateWithFormat:@"%K = %@", key, value]
                                fetchLimit:1
                                resultType:resultType
                                   groupBy:nil];
    
    if([results count])
    {
        return results[0];
    }
    
    return nil;
}

- (id) fetchEntity:(NSString*)property
      forContextId:(NSString *)contextId
          forModel:(NSString*)model
         withValue:(NSString*)value
        resultType:(NSUInteger)resultType
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (context.context_id = %@)", property, value, contextId];
    DLog(@"Predicate: %@", predicate);
    NSArray *results = [self fetchEntitiesForModel:model
                                       withSortKey:sortKey
                                         ascending:isAscending
                                     withPredicate:predicate
                                        fetchLimit:1
                                        resultType:resultType];
    DLog(@"results: %@", results);
    if([results count])
    {
        return results[0];
    }
    
    return nil;
}

- (id) fetchEntity:(NSString*)property
      forContextId:(NSString*)contextId
          forModel:(NSString*)model
   containingValue:(NSString*)value
        resultType:(NSUInteger)resultType
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K contains %@) AND (context.context_id = %@)", property, value, contextId];
    DLog(@"Predicate: %@", predicate);
    NSArray *results = [self fetchEntitiesForModel:model
                                       withSortKey:sortKey
                                         ascending:isAscending
                                     withPredicate:predicate
                                        fetchLimit:1
                                        resultType:resultType];
    DLog(@"results: %@", results);
    if([results count])
    {
        return results[0];
    }
    
    return nil;
}

- (id) fetchEntities:(NSArray*)properties
            forModel:(NSString*)model
       withPredicate:(NSPredicate*)predicate
          resultType:(NSUInteger)resultType
         withSortKey:(NSString*)sortKey
        andAscending:(BOOL)isAscending
          fetchLimit:(NSUInteger)limit
          andGroupBy:(NSArray*)groups
{
    return [self fetchEntities:properties
                      forModel:model
                   withSortKey:sortKey
                     ascending:isAscending
                 withPredicate:predicate
                    fetchLimit:limit
                    resultType:resultType
                       groupBy:groups];
}

- (id) fetchEntity:(NSArray*)properties
          forModel:(NSString*)model
     withPredicate:(NSPredicate*)predicate
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending
{
    NSArray *results = [self fetchEntities:properties
                                  forModel:model
                               withSortKey:sortKey
                                 ascending:isAscending
                             withPredicate:predicate
                                fetchLimit:1
                                resultType:NSDictionaryResultType
                                   groupBy:nil];
    
    if([results count])
    {
        return results[0];
    }
    
    return nil;
}

- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
        resultType:(NSUInteger)resultType
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending
{
    NSArray *results = [self fetchEntities:@[property]
                                  forModel:model
                               withSortKey:sortKey
                                 ascending:isAscending
                             withPredicate:[NSPredicate predicateWithFormat:@"(%K = %@)", property, value]
                                fetchLimit:1
                                resultType:resultType
                                   groupBy:nil];
    
    if([results count])
    {
        return results[0];
    }
    
    return nil;
}

- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
            andKey:(NSString*)key
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending
{
    return [self fetchEntity:property
                    forModel:model
                   withValue:value
                      andKey:key
                  resultType:NSDictionaryResultType
                 withSortKey:sortKey
                andAscending:isAscending];
}

- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending
{
    return [self fetchEntity:property
                    forModel:model
                   withValue:value
                  resultType:NSDictionaryResultType
                 withSortKey:sortKey
                andAscending:isAscending];
}


- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
{
   return [self fetchEntity:property
                   forModel:model
                  withValue:value
                withSortKey:nil
               andAscending:YES];
}

//DEPRECATED
- (id) fetchEntityForCurrentBook:(NSString*)property
                        forModel:(NSString*)model
                       withValue:(NSString*)value
{
    return [self fetchEntity:property
                    forModel:model
                   withValue:value];
}

- (id) fetchEntity:(NSString*)property
      forContextId:(NSString*)contextId
          forModel:(NSString*)model
         withValue:(NSString*)value
{
    return [self fetchEntity:property
                forContextId:contextId
                    forModel:model
                   withValue:value
                  resultType:NSDictionaryResultType
                 withSortKey:nil
                andAscending:NO];
}

- (id) fetchEntity:(NSString*)property
      forContextId:(NSString*)contextId
          forModel:(NSString*)model
   containingValue:(NSString*)value
{
    return [self fetchEntity:property
                forContextId:contextId
                    forModel:model
             containingValue:value
                  resultType:NSDictionaryResultType
                 withSortKey:nil
                andAscending:NO];
}

-(NSUInteger)fetchMaxValue:(NSString*)model
                  property:(NSString*)property
              forContextId:contextId
{
    NSFetchRequest *fetchRequest          = [NSFetchRequest fetchRequestWithEntityName:model];

    NSExpression *propertyExpression      = [NSExpression expressionForKeyPath:property];
    NSExpression *countExpression         = [NSExpression expressionForFunction:@"max:" arguments:@[propertyExpression]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"context.context_id = %@", contextId];
    DLog(@"predicate: %@", predicate);
    NSExpressionDescription *expDesc      = [[NSExpressionDescription alloc] init];
    [expDesc setName:@"max"];
    [expDesc setExpression:countExpression];
    [expDesc setExpressionResultType:NSInteger32AttributeType];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:property ascending:NO]]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setPropertiesToFetch:@[expDesc]];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setResultType:NSDictionaryResultType];
    DLog(@"fetchRequest: %@", fetchRequest);
    NSError *error = nil;
    NSArray *results = [self.objectContext executeFetchRequest:fetchRequest error:&error];
    DLog(@"results: %@::: error: %@", results, error);
    if(!error)
    {
        if([results count])
        {
            return [results[0][@"max"] integerValue];
        }
    } else {
        DLog(@"ERROR retrieving Max Value: %@", error.localizedDescription)
    }
    DLog(@"No Results")
    return 0;
}

- (NSUInteger) fetchCount:(NSString*)model
                 property:(NSString*)property
             forContextId:(NSString*)contextId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"context.context_id = %@", contextId];
    
    return [self fetchCount:model property:property predicate:predicate];
}

- (NSUInteger) fetchCount:(NSString*)model
                 property:(NSString*)property
                predicate:(NSPredicate*)predicate
{
    NSFetchRequest *fetchRequest          = [NSFetchRequest fetchRequestWithEntityName:model];
    
    NSExpression *propertyExpression      = [NSExpression expressionForKeyPath:property];
    NSExpression *countExpression         = [NSExpression expressionForFunction:@"count:" arguments:@[propertyExpression]];
    
    NSExpressionDescription *expDesc      = [[NSExpressionDescription alloc] init];
    [expDesc setName:@"count"];
    [expDesc setExpression:countExpression];
    [expDesc setExpressionResultType:NSInteger32AttributeType];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setPropertiesToFetch:@[expDesc]];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSError *error = nil;
    NSArray *results = [self.objectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error)
    {
        if([results count])
        {
            return [results[0][@"count"] integerValue];
        }
    }
    
    return 0;
}

- (NSArray*) fetchTocTree:(NSString*)rootId
{
    return [self fetchTocTree:rootId
                 forContextId:[[PxePlayer sharedInstance] getContextID]];
}

- (NSArray*) fetchTocTree:(NSString*)rootId
             forContextId:(NSString*)contextId
{
    if(!rootId)
    {
        rootId = @"root";
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parentId = %@) AND (context.context_id = %@)", rootId, contextId];
    
    return [self fetchEntitiesForModel:NSStringFromClass([PxePageDetail class])
                           withSortKey:@"pageNumber"
                             ascending:YES
                         withPredicate:predicate
                            fetchLimit:0
                            resultType:NSDictionaryResultType];
}

- (NSArray*) fetchBasketTree:(NSString*)rootId
{
    return [self fetchBasketTree:rootId
                    forContextId:[[PxePlayer sharedInstance] getContextID]];
}

- (NSArray*) fetchBasketTree:(NSString*)rootId
                forContextId:(NSString*)contextId
{
    if(!rootId)
    {
        rootId = @"root";
    }
    DLog(@"*************rootId: %@", rootId);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parentId = %@) AND (context.context_id = %@)", rootId, contextId];
    
    return [self fetchEntitiesForModel:NSStringFromClass([PxeCustomBasketDetail class])
                           withSortKey:@"pageNumber"
                             ascending:YES
                         withPredicate:predicate
                            fetchLimit:0
                            resultType:NSDictionaryResultType];
}

- (NSArray*) fetchGlossaryforContextId:(NSString*)contextId
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"context.context_id = %@", contextId];
    return [self fetchEntitiesForModel:NSStringFromClass([PxeGlossary class])
                           withSortKey:@"term"
                             ascending:YES
                         withPredicate:predicate
                            fetchLimit:0
                            resultType:NSDictionaryResultType];
    
}

- (void) resetDataManager
{
    if(self.persistentStoreCoordinator)
    {
        NSPersistentStore *store = [[self.persistentStoreCoordinator persistentStores] lastObject];
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:store.URL.path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
        }
        
        DLog(@"DELETE TABLES.. \n\n");
        
        self.persistentStoreCoordinator = nil;
    }
    
    if(self.objectModel)
    {
        self.objectModel = nil;
    }
    
    if(self.objectContext)
    {
        [self.objectContext reset];
        self.objectContext = nil;
    }
    
    if(![HMCache removeDirectory:CD_DIR])
    {
        NSLog(@"Fatal : file system failure...");
        abort();
    }
}

# pragma mark - User

- (PxeUser*) createPxeUserWithData:(PxePlayerUser*)pxePlayerUser withCompletionHandler:(void (^)(PxeUser*, NSError *))handler
{
    PxeUser *pxeUser;
    DLog(@"USER ID: %@", pxePlayerUser.identityId);
    pxeUser = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeUser class])
                                                     inManagedObjectContext:[self getObjectContext]];
    pxeUser.identity_id = pxePlayerUser.identityId;
    
    if(![self save])
    {
        if (handler)
        {
            handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
        }
    }
    else
    {
        if (handler)
        {
            handler(pxeUser, nil);
        }
    }
    
    return pxeUser;
}

- (NSArray *) readPxeUserWithData:(PxePlayerUser *)pxePlayerUser withCompletionHandler:(void (^)(NSArray*, NSError *))handler
{
    DLog(@"IDENTITY ID: %@", pxePlayerUser.identityId);
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PxeUser"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identity_id=[cd]%@", pxePlayerUser.identityId];
    
    NSError *error;
    NSArray * __weak users = [[self getObjectContext] executeFetchRequest:fetchRequest error:&error];
    DLog(@"USERS: %@", users);
    if (error)
    {
        if (handler)
        {
            handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
        }
    }
    else
    {
        if (handler)
        {
            handler(users, nil);
        }
    }
    
    return users;
}

- (PxeUser *) updatePxeUserWithData:(PxePlayerUser *)pxePlayerUser withCompletionHandler:(void (^)(PxeUser*, NSError *))handler
{
    PxeUser *pxeUser;
    DLog(@"USER ID: %@", pxePlayerUser.identityId);
    NSArray *pxeUsers = [self readPxeUserWithData:pxePlayerUser withCompletionHandler:nil];
    DLog(@"pxeUsers: %@", pxeUsers);
    if (pxeUsers)
    {
        pxeUser = [pxeUsers objectAtIndex:0];
        DLog(@"pxeUser: %@", pxeUser);
        if (pxeUser)
        {
            pxeUser.identity_id = pxePlayerUser.identityId;
            if(![self save])
            {
                if (handler)
                {
                    handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
                }
            } else {
                if (handler)
                {
                    handler(pxeUser, nil);
                }
            }
        }
        else
        {
            if (handler)
            {
                handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
            }
        }
    }
    else
    {
        if (handler)
        {
            handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
        }
    }
    
    return pxeUser;
}

- (BOOL) deletePxeUserWithData:(PxePlayerUser *)pxePlayerUser withCompletionHandler:(void (^)(BOOL, NSError *))handler
{
    BOOL deleteSuccess = NO;
    DLog(@"Identity ID: %@", pxePlayerUser.identityId);
    NSArray *pxeUsers = [self readPxeUserWithData:pxePlayerUser withCompletionHandler:nil];
    
    if (pxeUsers)
    {
        PxeUser *pxeUser = [pxeUsers objectAtIndex:0];
        
        if (pxeUser)
        {
            [self.objectContext deleteObject:pxeUser];
            
            if(![self save])
            {
                handler(deleteSuccess, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
            }
            else
            {
                deleteSuccess = YES;
                handler(deleteSuccess, nil);
            }
        }
        else
        {
            handler(deleteSuccess, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
        }
    }
    else
    {
        handler(deleteSuccess, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
    }

    return deleteSuccess;
}


# pragma mark - Context
- (PxeContext *) createCurrentContextWithDataInterface:(PxePlayerDataInterface *)dataInterface
                                           currentUser:(PxePlayerUser *)pxePlayerUser
                                           withHandler:(void (^)(PxeContext*, NSError*))handler
{
    PxeContext *pxeContext;
    
    if (dataInterface.contextId)
    {
        if(!pxePlayerUser)
        {
            pxePlayerUser = [[PxePlayer sharedInstance] currentUser];
            if (!pxePlayerUser)
            {
                if (handler)
                {
                    NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot create context without user data.", @"Cannot create context without user data.")};
                    NSError *error = [PxePlayerError errorForCode:PxePlayerNetworkUnreachable errorDetail:errorDict];
                    handler(nil, error);
                }
            }
        }
        
        NSArray *userArray = [self readPxeUserWithData:pxePlayerUser withCompletionHandler:nil];
        DLog(@"userArray: %@", userArray);
        if (userArray)
        {
            PxeUser *pxeUser = [userArray firstObject];
            
            DLog(@"pxeUser: %@", pxeUser);
            if (pxeUser)
            {
                DLog(@"contextId: %@", dataInterface.contextId);
                DLog(@"identityId: %@", pxeUser.identity_id);
                //if the context is here dont insert it again.
                NSArray *contexts = [self fetchEntitiesForModel:NSStringFromClass([PxeContext class])
                                                    withSortKey:@"context_id"
                                                      ascending:YES
                                                  withPredicate:[NSPredicate predicateWithFormat:@"(context_id = %@) AND (user.identity_id = %@)", dataInterface.contextId, pxeUser.identity_id]
                                                     fetchLimit:0
                                                     resultType:NSManagedObjectResultType];
                
                pxeContext = [contexts firstObject];
                
                if(pxeContext)
                {
                    if (handler)
                    {
                        handler(pxeContext,nil);
                    }
                    return pxeContext;
                }
                
                pxeContext = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeContext class])
                                                           inManagedObjectContext:[self getObjectContext]];
                
                pxeContext.context_id = dataInterface.contextId;
                pxeContext.user = pxeUser;
                
                if (dataInterface.onlineBaseURL)
                {
                    pxeContext.context_base_url = dataInterface.onlineBaseURL;
                }
                
                if (dataInterface.tocPath)
                {
                    pxeContext.toc_url = dataInterface.tocPath;
                }
                
                if (dataInterface.indexId)
                {
                    pxeContext.search_index_id = dataInterface.indexId;
                }
                
                DLog(@"pxeContext..search_index_id: %@", pxeContext.search_index_id);
                
                if(![self save])
                {
                    if (handler)
                    {
                        handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
                    }
                }
                else
                {
                    if (handler)
                    {
                        handler(pxeContext, nil);
                    }
                }
            }
            else
            {
                if (handler)
                {
                    handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
                }
            }
        }
        else
        {
            if (handler)
            {
                handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
            }
        }
    }
    
    return pxeContext;
}

- (BOOL) deleteCurrentContextWithDataInterface:(PxePlayerDataInterface *)dataInterface
                                   currentUser:(PxePlayerUser *)pxePlayerUser
                                   withHandler:(void (^)(BOOL, NSError *))handler
{
    BOOL deleteSuccess = NO;
    
    if(!pxePlayerUser)
    {
        pxePlayerUser = [[PxePlayer sharedInstance] currentUser];
        if (!pxePlayerUser)
        {
            if (handler)
            {
                NSDictionary *errorDict = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Cannot create context without user data.", @"Cannot create context without user data.")};
                NSError *error = [PxePlayerError errorForCode:PxePlayerNetworkUnreachable errorDetail:errorDict];
                handler(deleteSuccess, error);
            }
        }
    }
    
    PxeContext *pxeContext;
    
    NSArray *userArray = [self readPxeUserWithData:pxePlayerUser withCompletionHandler:nil];
    DLog(@"userArray: %@", userArray);
    if (userArray)
    {
        PxeUser *pxeUser = [userArray firstObject];
        
        DLog(@"pxeUser: %@", pxeUser);
        if (pxeUser)
        {
            NSArray *contexts = [self fetchEntitiesForModel:NSStringFromClass([PxeContext class])
                                                withSortKey:@"context_id"
                                                  ascending:YES
                                              withPredicate:[NSPredicate predicateWithFormat:@"(context_id = %@) AND (user.identity_id = %@)", dataInterface.contextId, pxeUser.identity_id]
                                                 fetchLimit:0
                                                 resultType:NSManagedObjectResultType];
            
            pxeContext = [contexts firstObject];
            
            [self.objectContext deleteObject:pxeContext];
            
            if([self save])
            {
                deleteSuccess = YES;
                if(handler)
                {
                    handler(deleteSuccess, nil);
                }
            }
            else
            {
                if(handler)
                {
                    handler(deleteSuccess, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
                }
            }
        }
        else
        {
            if(handler)
            {
                handler(deleteSuccess, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
            }
        }
    }
    else
    {
        if(handler)
        {
            handler(deleteSuccess, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
        }
    }
    
    return deleteSuccess;
}

- (void) updateContext:(NSString *)contextId
             attribute:(NSString *)attribute
             withValue:(NSString *)value
{
    if ([attribute isEqualToString:@"context_id"])
    {
        DLog(@"Can't change the value for Context Id");
        return;
    }
    NSPredicate *contextPredicate = [NSPredicate predicateWithFormat:@"context_id == %@", contextId];
    
    NSArray *contextResults = [self fetchEntitiesForModel:NSStringFromClass([PxeContext class])
                                              withSortKey:@"context_id"
                                                ascending:YES
                                            withPredicate:contextPredicate
                                               fetchLimit:NO
                                               resultType:NSManagedObjectResultType];
    
    if ([contextResults count] > 0)
    {
        for (PxeContext *context in contextResults)
        {
            [context setValue:value forKey:attribute];
        }
    }
    [self save];
}

#pragma mark Manifest
- (PxeManifest*) createManifest:(PxePlayerManifest*)manifest
                      dbContext:(PxeContext*)dbContext
          withCompletionHandler:(void (^)(PxeManifest*, NSError *))handler {
    
    PxeManifest *dbManifest;
    dbManifest = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeManifest class])
                                               inManagedObjectContext:[self getObjectContext]];
    
    dbManifest.base_url             = manifest.baseUrl;
    dbManifest.src                  = manifest.epubFileName;
    
    // Manifest data is far from perfact
    dbManifest.total_size           = manifest.totalSize;
    
    dbManifest.title                = manifest.bookTitle;
    dbManifest.context              = dbContext;
    
    
    if(![self save])
    {
        if (handler)
        {
            handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
        }
    }
    else
    {
        if (handler)
        {
            handler(dbManifest, nil);
        }
    }
    
    return dbManifest;
}

- (PxeManifestChunk*) createManifestItem:(PxePlayerManifestItem*)manifestItem
                               dbManifest:(PxeManifest*)dbManifest
                    withCompletionHandler:(void (^)(PxeManifestChunk*, NSError *))handler {
    
    PxeManifestChunk *dbManifestChunk;
    dbManifestChunk = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([PxeManifestChunk class])
                                               inManagedObjectContext:[self getObjectContext]];
    
    dbManifestChunk.base_url       = manifestItem.baseUrl;
    dbManifestChunk.chunk_id       = manifestItem.assetId;
    dbManifestChunk.is_downloaded  = [NSNumber numberWithBool:manifestItem.isDownloaded];
    dbManifestChunk.size           = manifestItem.size;
    dbManifestChunk.src            = manifestItem.epubFileName;
    dbManifestChunk.title          = manifestItem.title;
    dbManifestChunk.manifest       = dbManifest;
    
    if(![self save])
    {
        if (handler)
        {
            handler(nil, [PxePlayerError errorForCode:PxePlayerPersistantDataError]);
        }
    }
    else
    {
        if (handler)
        {
            handler(dbManifestChunk, nil);
        }
    }
    
    return dbManifestChunk;
}

- (BOOL) updateManifestItemWithId:(NSString*)assetId
                 downloadedStatus:(BOOL)isDownloaded
            withCompletionHandler:(void (^)(BOOL success))handler
{
    PxeManifestChunk *dbManifestChunk;
    NSArray *dbManifestChunks = [self fetchEntitiesForModel:NSStringFromClass([PxeManifestChunk class])
                                                withSortKey:nil
                                                  ascending:NO
                                              withPredicate:[NSPredicate predicateWithFormat:@"chunk_id == %@", assetId]
                                                 fetchLimit:0
                                                 resultType:NSManagedObjectResultType];
    
    dbManifestChunk = [dbManifestChunks firstObject];
    
    if (!dbManifestChunk)
    {
        if (handler)
        {
            handler(NO);
        }
        
        return NO;
    }
    else
    {
        dbManifestChunk.is_downloaded = [NSNumber numberWithBool:isDownloaded];
        
        if(![self save])
        {
            if (handler)
            {
                handler(NO);
            }
            return NO;
        } else {
            if (handler)
            {
                handler(YES);
            }
            return YES;
        }
    }
    return YES;
}

- (BOOL) updatePageStatusWithAsset:(NSString*)assetId
                  downloadedStatus:(BOOL)isDownloaded
             withCompletionHandler:(void (^)(BOOL success))handler
{
    // Get Manifest TITLE (yes, that's right, the Title is the only thing we have to go on.
    NSArray *manifestTitles = [self fetchEntities:@[@"title", @"chunk_id"]
                                         forModel:NSStringFromClass([PxeManifestChunk class])
                                      withSortKey:nil
                                        ascending:NO
                                    withPredicate:[NSPredicate predicateWithFormat:@"chunk_id == %@", assetId]
                                       fetchLimit:1
                                       resultType:NSManagedObjectResultType
                                          groupBy:nil];
    
    BOOL updateDownloadStatus = NO;
    
    if ([manifestTitles count] > 0)
    {
        PxeManifestChunk *manifestItem = [manifestTitles objectAtIndex:0];
        NSString *manifestTitle = manifestItem.title;
        NSString *manifestAsset = manifestItem.chunk_id;
        NSString *manifestContextId = manifestItem.manifest.context.context_id;
        DLog(@"manifestItem.contextId: %@", manifestItem.manifest.context.context_id);
        
        if ([manifestTitle isEqualToString:PXEPLAYER_BOOK_TITLE_AS_ASSET])
        {
            updateDownloadStatus = [self updateAllPagesinContext:assetId
                                              withDownloadStatus:isDownloaded];
        } else {
            updateDownloadStatus = [self updatePagesinChapter:manifestTitle
                                           withDownloadStatus:isDownloaded
                                                      assetId:manifestAsset
                                                    contextId:manifestContextId];
        }
    }
    else
    {
        DLog(@"NO MANIFEST DATA");
        updateDownloadStatus = [self updateAllPagesinContext:assetId
                                          withDownloadStatus:isDownloaded];
    }
    
    if (updateDownloadStatus)
    {
        if (handler)
        {
            handler(YES);
        }
        return YES;
    } else {
        if (handler)
        {
            handler(NO);
        }
        return NO;
    }
    
    return YES;
}

- (BOOL) updateAllPagesinContext:(NSString*)contextId
              withDownloadStatus:(BOOL)isDownloaded
{
    DLog(@"Updating Pages for context: %@ ::: isDownloaded: %@", contextId, isDownloaded?@"YES":@"NO");
    NSArray *pages = [self fetchEntitiesForModel:NSStringFromClass([PxePageDetail class])
                                     withSortKey:nil
                                       ascending:NO
                                   withPredicate:[NSPredicate predicateWithFormat:@"context.context_id == %@", contextId]
                                      fetchLimit:0
                                      resultType:NSManagedObjectResultType];
    if (pages)
    {
        for (PxePageDetail *page in pages)
        {
            DLog(@"PxePageDetail ID: %@", page.pageId);
            page.isDownloaded = [NSNumber numberWithBool:isDownloaded];
            if (isDownloaded)
            {
                page.assetId = contextId;
            }
            else
            {
                page.assetId = nil;
            }
        }
        if(![self save])
        {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
    
    return YES;
}

- (BOOL) updatePagesinChapter:(NSString*)chapterTitle
           withDownloadStatus:(BOOL)isDownloaded
                      assetId:(NSString*)assetId
                    contextId:(NSString*)contextId
{
    NSPredicate *pagesPredicate = [NSPredicate predicateWithFormat:@"pageTitle == %@ AND context.context_id == %@", chapterTitle, contextId];
    
    NSArray *pages = [self fetchEntitiesForModel:NSStringFromClass([PxePageDetail class])
                                     withSortKey:nil
                                       ascending:NO
                                   withPredicate:pagesPredicate
                                      fetchLimit:1
                                      resultType:NSManagedObjectResultType];
    if (pages)
    {
        PxePageDetail *page = [pages firstObject];
        page.isDownloaded = [NSNumber numberWithBool:isDownloaded];
        if (isDownloaded)
        {
            page.assetId = assetId;
        }
        else
        {
            page.assetId = nil;
        }
        
        NSString *pageId = page.pageId;
        
        BOOL pagesUpdated = [self updatePagesWithParentID:pageId
                                       withDownloadStatus:isDownloaded
                                                  assetId:assetId
                                                contextId:contextId];
        if (!pagesUpdated)
        {
            return NO;
        } else {
            if(![self save])
            {
                return NO;
            } else {
                return YES;
            }
        }
    } else {
        return NO;
    }
    
    return YES;
}

- (BOOL) updatePagesWithParentID:(NSString*)parentId
              withDownloadStatus:(BOOL)isDownloaded
                         assetId:(NSString*)assetId
                       contextId:(NSString*)contextId
{
    DLog(@"Updating Pages for asset: %@ ::: isDownloaded: %@", assetId, isDownloaded?@"YES":@"NO");
    
    NSPredicate *pagesPredicate = [NSPredicate predicateWithFormat:@"parentId == %@ AND context.context_id == %@", parentId, contextId];
    
    NSArray *pages = [self fetchEntitiesForModel:NSStringFromClass([PxePageDetail class])
                                     withSortKey:nil
                                       ascending:NO
                                   withPredicate:pagesPredicate
                                      fetchLimit:0
                                      resultType:NSManagedObjectResultType];
    
    if (pages)
    {
        for (PxePageDetail *page in pages)
        {
            page.isDownloaded = [NSNumber numberWithBool:isDownloaded];
            if (isDownloaded)
            {
                page.assetId = assetId;
            }
            else
            {
                page.assetId = nil;
            }
            
            [self updatePagesWithParentID:page.pageId
                       withDownloadStatus:isDownloaded
                                  assetId:assetId
                                contextId:contextId];
        }
    }
    
    return YES;
}

- (NSString*) getAssetForPage:(NSString*)pageUrl
                    contextId:(NSString*)contextId
{
    DLog(@"pageURL: %@", pageUrl);
    NSArray *pages = [self fetchEntitiesForModel:NSStringFromClass([PxePageDetail class])
                                     withSortKey:nil
                                       ascending:NO
                                   withPredicate:[NSPredicate predicateWithFormat:@"pageURL == %@ && context.context_id == %@", pageUrl, contextId]
                                      fetchLimit:0
                                      resultType:NSManagedObjectResultType];
    DLog(@"pages: %@", pages);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetId != NULL"];
    NSArray *filteredArray = [pages filteredArrayUsingPredicate:predicate];
    
    NSString *foundAssetId = nil;
    
    if ([filteredArray count] > 0)
    {
        PxePageDetail *foundPage = [filteredArray firstObject];
        foundAssetId = foundPage.assetId;
    }
    return foundAssetId;
}

- (void) dealloc
{
    self.objectModel = nil;
    self.objectContext = nil;
    self.persistentStoreCoordinator = nil;
}

@end
