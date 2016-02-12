//
//  PxeReaderDataManager.h
//  PxeReader
//
//  Created by Saro Bear on 25/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PxePlayerDataInterface.h"

// Database
@class PxeUser;
@class PxeContext;
@class PxeManifest;
@class PxeManifestChunk;

// Object Models
@class PxePlayerUser;
@class PxePlayerManifest;
@class PxePlayerManifestItem;

/**
 Simple data manager class which handles core data operations of add, edit, delete and update data on the core data persistent storage.
 */
@interface PxePlayerDataManager : NSObject

/**
 A singleton instance of the data manager
 @return PxePlayerDataManager, returns the static singleton instance of the PxePlayerDataManager
 */
+(PxePlayerDataManager*)sharedInstance;

/**
 This method would be called to get the current object context of the core data persistent store
 @return NSManagedObjectContext, returns the current object context
 */
- (NSManagedObjectContext*)getObjectContext;

/**
 This method would be called to save or update the recoreds in the core data
 @return BOOL, returns the boolean value for whether record saves successfully or not
 @see [NSManagedObjectContex save:]
 */
- (BOOL)save;
    
/**
 This method would be called for fetch records from the core data persistent store
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend. 
 @param NSPredicate, predicate is an instance of NSPredicate with conditions to filters the records while fetching .
 @param NSUInteger, limit is an unsigned integer used for limitting the number of records should be fetched
 @param NSUInteger, resultType is an enumerated value which decides the format of the records whether dictionary or model
 @return NSArray , returns the array of records fetched from data store
 */
- (NSArray*) fetchEntitiesForModel:(NSString*)model
                       withSortKey:(NSString*)sortKey
                         ascending:(BOOL)isAscending
                     withPredicate:(NSPredicate*)predicate
                        fetchLimit:(NSUInteger)limit
                        resultType:(NSUInteger)resultType;

/**
 This method would be called for fetch records from the core data persistent store
 @param NSArray, array of properties should be fetched from the records
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend.
 @param NSPredicate, predicate is an instance of NSPredicate with conditions to filters the records while fetching .
 @param NSUInteger, limit is an unsigned integer used for limitting the number of records should be fetched
 @param NSUInteger, resultType is an enumerated value which decides the format of the records whether dictionary or model
 @param NSArray, array of properties used for grouping the records
 @return NSArray , returns the array of records fetched from data store
 */
- (NSArray*) fetchEntities:(NSArray*)property
                  forModel:(NSString*)model
               withSortKey:(NSString*)sortKey
                 ascending:(BOOL)isAscending
             withPredicate:(NSPredicate*)predicate
                fetchLimit:(NSUInteger)limit
                resultType:(NSUInteger)resultType
                   groupBy:(NSArray*)groups;

/**
 This method would be called for fetch records from the core data persistent store
 @param NSArray, array of properties should be fetched from the records
 @param NSString, model is a class name of type of record should be fetched
 @param NSPredicate, predicate is an instance of NSPredicate with conditions to filters the records while fetching .
 @param NSUInteger, resultType is an enumerated value which decides the format of the records whether dictionary or model
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend.
 @param NSUInteger, limit is an unsigned integer used for limitting the number of records should be fetched
 @param NSArray, array of properties used for grouping the records
 @return NSArray , returns the array of records fetched from data store
 */
- (id) fetchEntities:(NSArray*)properties
            forModel:(NSString*)model
       withPredicate:(NSPredicate*)predicate
          resultType:(NSUInteger)resultType
         withSortKey:(NSString*)sortKey
        andAscending:(BOOL)isAscending
          fetchLimit:(NSUInteger)limit
          andGroupBy:(NSArray*)groups;

/**
 This method would be called for fetch records from the core data persistent store
 @param NSString, property is a field in the specific record
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, value is a value of property field in the specific record
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend.
 @param NSUInteger, resultType is an enumerated value which decides the format of the records whether dictionary or model
 @return id , returns the array or dictionary of records fetched from data store
 */
- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
        resultType:(NSUInteger)resultType
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending;

/**
 This method would be called for fetch records from the core data persistent store
 @param NSString, property is a field in the specific record
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, value is a value of property field in the specific record
 @param NSString, key is a name of property field in the specific record
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend.
 @param NSUInteger, resultType is an enumerated value which decides the format of the records whether dictionary or model
 @return id , returns the array or dictionary of records fetched from data store
 */
- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
            andKey:(NSString*)key
        resultType:(NSUInteger)resultType
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending;

/**
 This method would be called for fetch records from the core data persistent store
 @param NSString, property is a field in the specific record
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, value is a value of property field in the specific record
 @param NSString, key is a name of property field in the specific record
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend.
 @return id , returns the array or dictionary of records fetched from data store
 */
- (id )fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
            andKey:(NSString*)key
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending;

/**
 This method would be called for fetch records from the core data persistent store
 @param NSString, property is a field in the specific record
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, value is a value of property field in the specific record
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend.
 @return id , returns the array or dictionary of records fetched from data store
 */
- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending;

/**
 This method would be called for fetch records from the core data persistent store
 @param NSArray, array of properties should be fetched from the records
 @param NSString, model is a class name of type of record should be fetched
 @param NSPredicate, predicate is an instance of NSPredicate with conditions to filters the records while fetching .
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend.
 @return NSArray , returns the array of records fetched from data store
 */
- (id) fetchEntity:(NSArray*)properties
          forModel:(NSString*)model
     withPredicate:(NSPredicate*)predicate
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending;


/**
 This method would be called for fetch records from the core data persistent store
 @param NSString, property is a field in the specific record
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, value is a value of property field in the specific record
 @return id , returns the array or dictionary of records fetched from data store
 */
- (id) fetchEntity:(NSString*)property
          forModel:(NSString*)model
         withValue:(NSString*)value;

- (id) fetchEntityForCurrentBook:(NSString*)property
                        forModel:(NSString*)model
                       withValue:(NSString*)value __attribute((deprecated("use fetchEntity:forModel:withValue: instead")));

/**
 This method would be called for fetch records from the core data persistent store
 @param NSString, property is a field in the specific record
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, value is a value of property field in the specific record
 @param NSString, sortKey for fetching records sorted by the given key
 @param BOOL, isAscending is a boolean value for sort records by ascend if true else sort by descend.
 @param NSUInteger, resultType is an enumerated value which decides the format of the records whether dictionary or model
 @return id , returns the array or dictionary of records fetched from data store
 */
- (id) fetchEntity:(NSString*)property
      forContextId:(NSString *)contextId
          forModel:(NSString*)model
         withValue:(NSString*)value
        resultType:(NSUInteger)resultType
       withSortKey:(NSString*)sortKey
      andAscending:(BOOL)isAscending;

/**
 This method would be called for fetch current book records from the core data persistent store
 @param NSString, property is a field in the specific record
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, value is a value of property field in the specific record
 @return id , returns the array or dictionary of records fetched from data store
 */
- (id) fetchEntity:(NSString*)property
      forContextId:(NSString *)contextId
          forModel:(NSString*)model
         withValue:(NSString*)value;

/**
 
 */
- (id) fetchEntity:(NSString*)property
      forContextId:(NSString*)contextId
          forModel:(NSString*)model
   containingValue:(NSString*)value;

/**
 This method would be called for fetch table of contents of current book records from the data store
 @param NSString, rootId is a string used for fetching branch of records belongs to the root id
 @return NSArray , returns the array of records fetched from data store
 */
- (NSArray*) fetchTocTree:(NSString*)rootId __attribute((deprecated("use fetchTocTree:forContextId: instead")));

- (NSArray*) fetchTocTree:(NSString*)rootId
             forContextId:(NSString*)contextId;

/**
 *  Returns back a saved collection of the glossary terms for a given book
 *
 *  @return NSArray
 */
- (NSArray*) fetchGlossaryforContextId:(NSString*)contextId;


- (NSArray*) fetchBasketTree:(NSString*)rootId __attribute((deprecated("use fetchBasketTree:forContextId: instead")));

- (NSArray*) fetchBasketTree:(NSString*)rootId
                forContextId:(NSString*)contextId;

/**
 This method would be called to fetch the record which have the maximum value on specific property
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, property is a field in the specific record
 @return NSUInteger , returns the maximum value of the given property from records
 */
- (NSUInteger) fetchMaxValue:(NSString*)model
                    property:(NSString*)property
                forContextId:contextId;

/**
 This method would be called to fetch the total count of the records from data store
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, property is a field in the specific record
 @return NSUInteger , returns the total count of the given property from records
 */
-(NSUInteger)fetchCount:(NSString*)model
               property:(NSString*)property
           forContextId:(NSString*)contextId;

/**
 Obtains count from a given entity and for its property with a pre-determined predicate
 The predicate would include for example contextId
 @param NSString, model is a class name of type of record should be fetched
 @param NSString, property is a field in the specific record
 @param NSString, a predicate containing desired query criteria
 @return NSUInteger , returns the total count of the given property from records
 */
- (NSUInteger) fetchCount:(NSString*)model
                 property:(NSString*)property
                predicate:(NSPredicate*)predicate;

/**
 This method would be called to reset the singleton instance, gloabal variables and data stored in the persistent store
 */
//TODO: Method never seems to get called from anywhere
- (void) resetDataManager;

# pragma mark User CRUD

/**
 This methods creates a PxeUser object from a PxePlayerUser object and inserts it into the database
 @param PxePlayerUser, A PxePlayerUser object with a valid identity id
 @param handler, a completion handler that receives a PxeUser and an error and  returns void
 @return PxeUser object (recommended to receive PxeUser from completion handler block
 */
- (PxeUser*) createPxeUserWithData:(PxePlayerUser*)pxePlayerUser
             withCompletionHandler:(void (^)(PxeUser*, NSError *))handler;

/**
 
 */
- (NSArray*) readPxeUserWithData:(PxePlayerUser*)pxePlayerUser
           withCompletionHandler:(void (^)(NSArray*, NSError *))handler;

/**
 
 */
- (PxeUser*) updatePxeUserWithData:(PxePlayerUser*)pxePlayerUser
             withCompletionHandler:(void (^)(PxeUser*, NSError *))handler;

/**
 
 */
- (BOOL) deletePxeUserWithData:(PxePlayerUser*)pxePlayerUser
         withCompletionHandler:(void (^)(BOOL, NSError *))handler;

# pragma mark Context CRUD
/**
 
 */
- (PxeContext *) createCurrentContextWithDataInterface:(PxePlayerDataInterface *)dataInterface
                                           currentUser:(PxePlayerUser *)pxePlayerUser
                                           withHandler:(void (^)(PxeContext*, NSError*))handler;

/**
 
 */
- (BOOL) deleteCurrentContextWithDataInterface:(PxePlayerDataInterface *)dataInterface
                                   currentUser:(PxePlayerUser *)pxePlayerUser
                                   withHandler:(void (^)(BOOL, NSError *))handler;

- (void) updateContext:(NSString*)contextId
             attribute:(NSString *)attribute
             withValue:(NSString *)value;

#pragma mark Manifest
- (PxeManifest*) createManifest:(PxePlayerManifest*)manifest
                      dbContext:(PxeContext*)dbContext
          withCompletionHandler:(void (^)(PxeManifest*, NSError *))handler;

- (PxeManifestChunk*) createManifestItem:(PxePlayerManifestItem*)manifestItem
                               dbManifest:(PxeManifest*)dbManifest
                    withCompletionHandler:(void (^)(PxeManifestChunk*, NSError *))handler;

- (BOOL) updateManifestItemWithId:(NSString*)assetId
                  downloadedStatus:(BOOL)isDownloaded
             withCompletionHandler:(void (^)(BOOL success))handler;

- (BOOL) updatePageStatusWithAsset:(NSString*)assetId
                  downloadedStatus:(BOOL)isDownloaded
             withCompletionHandler:(void (^)(BOOL success))handler;

- (NSString*) getAssetForPage:(NSString*)pageUrl
                    contextId:(NSString*)contextId;

@end
