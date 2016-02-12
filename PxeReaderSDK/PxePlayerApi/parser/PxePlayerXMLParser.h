//
//  PxePlayerXMLParser.h
//  PxeReader
//
//  Created by Saro Bear on 30/12/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple class for parsing XML content in to the generic data format such as NSArray or NSDictionary
 */
@interface PxePlayerXMLParser : NSObject


/**
 This method would be called to parse data and returns the parsed result as a dictionary format
 @param NSData, data need to be parsed
 */
-(NSArray*)parseData:(NSData*)data;

@end
