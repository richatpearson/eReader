//
//  PxePlayerNCXParser.h
//  Sample
//
//  Created by Satyanarayana SVV on 10/28/13.
//  Copyright (c) 2013 Satyam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerBaseParser.h"

/**
 An enum for specifies whether the receiver reports the namespace and the qualified name of an element, scopr of namespace declarations and declarations of external entities.
 */
enum {
    XMLReaderOptionsProcessNamespaces           = 1 << 0,
    XMLReaderOptionsReportNamespacePrefixes     = 1 << 1,
    XMLReaderOptionsResolveExternalEntities     = 1 << 2,
};
typedef NSUInteger XMLReaderOptions;


/**
 A simple class derived from the PxePlayerBaseParser to parse NCX content and returns the result as a array or dictionary format 
 */
@interface PxePlayerNCXParser : NSObject <PxePlayerBaseParser>

@end
