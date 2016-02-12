//
//  PxePlayerNCXCDParser.h
//  PxeReader
//
//  Created by Saro Bear on 11/02/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerTocParser.h"

/**
 A simple class derived from the PxePlayerTocParser for converting the array or dictionary of data content parsed from the NCX parser into the core data model format and returns the result as a models
 */
@interface PxePlayerNCXCDParser : PxePlayerTocParser

@end
