//
//  PxeContext.h
//  PxeReader
//
//  Created by Tomack, Barry on 7/6/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeAnnotations, PxeBookMark, PxeCustomBasketDetail, PxeGlossary, PxePageDetail, PxeUser;

@interface PxeContext : NSManagedObject

@property (nonatomic, retain) NSString * context_base_url;
@property (nonatomic, retain) NSString * context_id;
@property (nonatomic, retain) NSString * search_index_id;
@property (nonatomic, retain) NSString * toc_url;
@property (nonatomic, retain) NSSet *annotations;
@property (nonatomic, retain) NSOrderedSet *baskets;
@property (nonatomic, retain) NSSet *bookmarks;
@property (nonatomic, retain) NSSet *glossarys;
@property (nonatomic, retain) NSOrderedSet *pages;
@property (nonatomic, retain) PxeUser *user;
@end

@interface PxeContext (CoreDataGeneratedAccessors)

- (void)addAnnotationsObject:(PxeAnnotations *)value;
- (void)removeAnnotationsObject:(PxeAnnotations *)value;
- (void)addAnnotations:(NSSet *)values;
- (void)removeAnnotations:(NSSet *)values;

- (void)insertObject:(PxeCustomBasketDetail *)value inBasketsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBasketsAtIndex:(NSUInteger)idx;
- (void)insertBaskets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBasketsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBasketsAtIndex:(NSUInteger)idx withObject:(PxeCustomBasketDetail *)value;
- (void)replaceBasketsAtIndexes:(NSIndexSet *)indexes withBaskets:(NSArray *)values;
- (void)addBasketsObject:(PxeCustomBasketDetail *)value;
- (void)removeBasketsObject:(PxeCustomBasketDetail *)value;
- (void)addBaskets:(NSOrderedSet *)values;
- (void)removeBaskets:(NSOrderedSet *)values;
- (void)addBookmarksObject:(PxeBookMark *)value;
- (void)removeBookmarksObject:(PxeBookMark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;

- (void)addGlossarysObject:(PxeGlossary *)value;
- (void)removeGlossarysObject:(PxeGlossary *)value;
- (void)addGlossarys:(NSSet *)values;
- (void)removeGlossarys:(NSSet *)values;

- (void)insertObject:(PxePageDetail *)value inPagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPagesAtIndex:(NSUInteger)idx;
- (void)insertPages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPagesAtIndex:(NSUInteger)idx withObject:(PxePageDetail *)value;
- (void)replacePagesAtIndexes:(NSIndexSet *)indexes withPages:(NSArray *)values;
- (void)addPagesObject:(PxePageDetail *)value;
- (void)removePagesObject:(PxePageDetail *)value;
- (void)addPages:(NSOrderedSet *)values;
- (void)removePages:(NSOrderedSet *)values;
@end
