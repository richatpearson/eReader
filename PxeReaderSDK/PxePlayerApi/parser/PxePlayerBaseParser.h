//
//  PxePlayerBaseParser.h
//  Sample
//
//  Created by Satyanarayana SVV on 10/28/13.
//  Copyright (c) 2013 Satyam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerDataInterface.h"

/**
 A block which returns the result after parsing the xhtml, ncx , html or xml content 
 @param id, receivedNavigator is an either array or dictionary of results retreived after data has parsed
 @param NSError, error returns if any error occured while parsing the content
 */
typedef void (^ParsingHandler)(id receivedNavigator, NSError* error);

/**
 A Protocol which send's the instructions while parsing to the class which implemented it
 @Extension <NSObject>, extented from NSObject
 */
@protocol PxePlayerBaseParser <NSObject>

@optional

/**
 This method would be called to parse data from the file and returns the parsed result as a dictionary format
 @param NSData, data need to be parsed
 */
-(NSDictionary*)parseData:(NSData*)data;

/**
 This method would be called to parse data from the specific URL and returns the parsed result into the block handler
 @param NSString, url is a server location in which data to be downloaded and parsed
 @param ParsingHandler, parsingHandler is a block would receive the parsed result
 */
-(void)parseDataFromURL:(NSString*)url withHandler:(ParsingHandler)parsingHandler;

/**
 This method would be called to parse data from the array of URL's and returns the parsed result into the block handler
 @param NSArray, navigationArray is a array with list of URL's need to be parsed
 @param ParsingHandler, parsingHandler is a block would receive the parsed result
 */
-(void)parseDataFromURLArray:(NSArray*)navigationArray withHandler:(ParsingHandler)parsingHandler;

/**
 This method would be called to parse NCX data from the URL and returns the parsed result into the block handler
 @param NSString, url is a server location in which data to be downloaded and parsed
 @param ParsingHandler, parsingHandler is a block would receive the parsed result
 */
- (void) parseDataFromInterface:(PxePlayerDataInterface*)dataInterface withHandler:(ParsingHandler)parsingHandler;

/**
 
 */
-(void)parseMasterPlaylistFromDataInterface:(PxePlayerDataInterface*)dataInterface
                                withHandler:(ParsingHandler)parsingHandler;

/**
 
 */
- (void) parseCustomBasketDataFromDataInterface:(PxePlayerDataInterface*)dataInterface
                                    withHandler:(ParsingHandler)parsingHandler;

/**
 
 */
- (void) parseTOCDataFromDataInterface:(PxePlayerDataInterface*)dataInterface
                           withHandler:(ParsingHandler)parsingHandler;

@end
