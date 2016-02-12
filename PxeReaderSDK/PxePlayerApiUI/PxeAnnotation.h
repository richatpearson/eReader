//
//  PxeAnnotation.h
//  PxeReader
//
//  Created by Tomack, Barry on 3/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PxeAnnotations;

@interface PxeAnnotation : NSManagedObject

@property (nonatomic, retain) NSDate * annotation_datetime;
@property (nonatomic, retain) NSString * color_code;
@property (nonatomic, retain) NSNumber * is_mathml;
@property (nonatomic, retain) NSString * labels;
@property (nonatomic, retain) NSNumber * marked_for_delete;
@property (nonatomic, retain) NSString * note_text;
@property (nonatomic, retain) NSNumber * queued;
@property (nonatomic, retain) NSString * range;
@property (nonatomic, retain) NSString * selected_text;
@property (nonatomic, retain) NSNumber * shareable;
@property (nonatomic, retain) NSString * content_id;
@property (nonatomic, retain) PxeAnnotations *annotations;

@end
