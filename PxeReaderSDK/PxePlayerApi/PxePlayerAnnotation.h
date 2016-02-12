//
//  PxePlayerAnnotation.h
//  PxeReader
//
//  Created by Saro Bear on 07/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple class to parse the annotation data into the model
 */
@interface PxePlayerAnnotation : NSObject

/**
 A NSString variable to hold the annotation definition
 */
@property (nonatomic, strong) NSString *annotationDttm;

/**
 A NSString variable to hold the color value of the annotation highlight color
 */
@property (nonatomic, strong) NSString  *colorCode;

/**
 A NSString variable to hold the content id
 //TODO: Find out what this is for...not in data object
 */
@property (nonatomic, strong) NSString  *contentId;

/**
 Denotes if the note is attached to MathML
 */
@property (nonatomic, assign) BOOL isMathML;

/**
 NSString to hold labels as a comma separated String
 */
@property (nonatomic, strong) NSArray  *labels;

/**
 A NSString variable to hold the annotation description text
 */
@property (nonatomic, strong) NSString  *noteText;

/**
 A NSString variable to hold the range of the annotation text
 */
@property (nonatomic, strong) NSString  *range;

/**
 A NSString variable to hold the annotation selected text
 */
@property (nonatomic, strong) NSString  *selectedText;

/**
 Denotes if the annotation is shared
 */
@property (nonatomic, assign) BOOL shareable;

/**
 Property for URI (nil unless Annotatons are sorted by color)
 */
@property (nonatomic, strong) NSString *uri;

/**
 Used for determing if the device is offline and will be toggle when persisted
 */
@property (nonatomic, assign) BOOL queued;

/**
 Used for determing if offline this bookmark will be delted when its back online
 */
@property (nonatomic, assign) BOOL markedDelete;

/**
 Dictionary of data that an application might want to attach to a PxePlayerAnnotation object
 */
@property (nonatomic, strong) NSDictionary *appData;

/**
 {
     annotationDttm = 1430850862389;
     data =             {
         baseUrl = "https://content.openclass.com/eps/pearson-reader/api/item/f82f9235-2667-4572-b701-4c84f66a9226/1/file/ast_pxe_stoltzfus_chemistry_13e_v1_sjg";
         colorCode = "#FFD231";
         isMathMl = 0;
         labels =                 (
         "Cover Page"
         );
         noteText = "";
         range = "51:4,51:9";
         selectedText = "French nobleman and scientist Antoine Lavoisier";
     };
     shareable = 0;
 }
 */
- (id) initWithDictionary:(NSDictionary*)annoDict;

/**
 
 */
- (NSString *) asJSONString;

/**
 
 */
- (NSDictionary *) asDictionaryForJSON;

- (void) setDecodedNoteText:(NSString*)note;



@end