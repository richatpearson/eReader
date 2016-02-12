//
//  PxeAnnotations.h
//  PxeReader
//
//  Created by Tomack, Barry on 4/15/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeAnnotation, PxeContext;

@interface PxeAnnotations : NSManagedObject

@property (nonatomic, retain) NSString * annotations_identity_id;
@property (nonatomic, retain) NSString * contents_uri;
@property (nonatomic, retain) NSNumber * is_my_annotation;
@property (nonatomic, retain) NSSet *annotation;
@property (nonatomic, retain) PxeContext *context;
@end

@interface PxeAnnotations (CoreDataGeneratedAccessors)

- (void)addAnnotationObject:(PxeAnnotation *)value;
- (void)removeAnnotationObject:(PxeAnnotation *)value;
- (void)addAnnotation:(NSSet *)values;
- (void)removeAnnotation:(NSSet *)values;

@end
