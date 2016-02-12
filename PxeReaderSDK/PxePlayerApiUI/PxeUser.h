//
//  PxeUser.h
//  PxeReader
//
//  Created by Tomack, Barry on 4/1/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeContext;

@interface PxeUser : NSManagedObject

@property (nonatomic, retain) NSString * identity_id;
@property (nonatomic, retain) NSOrderedSet *contexts;
@end

@interface PxeUser (CoreDataGeneratedAccessors)

- (void)insertObject:(PxeContext *)value inContextsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContextsAtIndex:(NSUInteger)idx;
- (void)insertContexts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContextsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContextsAtIndex:(NSUInteger)idx withObject:(PxeContext *)value;
- (void)replaceContextsAtIndexes:(NSIndexSet *)indexes withContexts:(NSArray *)values;
- (void)addContextsObject:(PxeContext *)value;
- (void)removeContextsObject:(PxeContext *)value;
- (void)addContexts:(NSOrderedSet *)values;
- (void)removeContexts:(NSOrderedSet *)values;

@end
