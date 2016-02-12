//
//  PxePlayerTocParser.h
//  PxeReader
//
//  Created by Saro Bear on 26/02/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerBaseParser.h"


@class PxeContext;

/**
 A simple class derived from the PxePlayerBaseParser for converting the array or 
 dictionary of data content parsed from the NCX or XHTML into the core
 data model format
 */
@interface PxePlayerTocParser : NSObject <PxePlayerBaseParser>

/**
 A NSInteger variable to hold the page number of the page
 */
@property (nonatomic, assign) NSInteger pageNumber;

/**
 A PxeContext model to hold the book information from the generic data format.
 */
@property (nonatomic, strong) PxeContext *currentContext;

/**
 
 */
@property (nonatomic, strong) NSString *contextId;

- (NSArray *) fetchPagesForContextId:(NSString*)contextId parentId:(NSString*)parentId;

- (NSArray *) fetchPrintPagesForContextId:(NSString*)contextId;

@end
