//
//  PxePlayerXHTMLCDParser.h
//  PxeReader
//
//  Created by Saro Bear on 25/02/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerTocParser.h"

/**
 A simple class derived from the PxePlayerTocParser for converting the array or dictionary of data content parsed from the XHTML parser into the core data model format and returns the result as a models
 */
@interface PxePlayerXHTMLCDParser : PxePlayerTocParser

@end
