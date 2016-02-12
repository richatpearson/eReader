//
//  PxePlayerJSONTOCParser.h
//  PxeReader
//
//  Created by Tomack, Barry on 1/23/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayerTocParser.h"

@interface PxePlayerJSONTOCParser : PxePlayerTocParser

/**
 
 */
- (void) parseTOCDataFromDataInterface:(PxePlayerDataInterface *)dataInterface
                           withHandler:(ParsingHandler)parsingHandler;


@end
