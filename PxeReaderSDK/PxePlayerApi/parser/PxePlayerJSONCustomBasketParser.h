//
//  PxePlayerJSONCustomBasketParser.h
//  PxeReader
//
//  Created by Tomack, Barry on 12/4/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import "PxePlayerTocParser.h"

@interface PxePlayerJSONCustomBasketParser : PxePlayerTocParser

/**
 
 */
- (void) parseCustomBasketDataFromDataInterface:(PxePlayerDataInterface *)dataInterface
                                    withHandler:(ParsingHandler)parsingHandler;

@end
