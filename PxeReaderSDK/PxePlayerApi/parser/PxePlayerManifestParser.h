//
//  PxePlayerManifestParser.h
//  PxeReader
//
//  Created by Richard Rosiak on 6/26/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerBaseParser.h"
#import "PxePlayerDataInterface.h"

@interface PxePlayerManifestParser : NSObject

- (void) parseManifestDataDictionary:(NSDictionary*)dataDict
                       dataInterface:(PxePlayerDataInterface*)dataInterface
                         tocChapters:(NSDictionary*)chapters
                         withHandler:(ParsingHandler)parsingHandler;
@end