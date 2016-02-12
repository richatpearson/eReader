//
//  PxePlayerNCXParser.m
//  Sample
//
//  Created by Satyanarayana SVV on 10/28/13.
//  Copyright (c) 2013 Satyam. All rights reserved.
//

#import "PxePlayerNCXParser.h"
#import "PXEPlayerMacro.h"

NSString *const kXMLReaderTextNodeKey		= @"title";
NSString *const kXMLReaderAttributePrefix	= @"@";

@interface PxePlayerNCXParser () <NSXMLParserDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableArray *dictionaryStack;
@property (nonatomic, strong) NSMutableString *textInProgress;
@property (nonatomic, strong) NSError *errorPointer;

@end


@implementation PxePlayerNCXParser

/**
 This method would be called to parse data from the file and returns the parsed result as a dictionary format
 @param NSData, data need to be parsed
 */
-(NSDictionary*)parseData:(NSData*)data
{
    // Clear out any old data
    self.dictionaryStack = [[NSMutableArray alloc] init];
    self.textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [self.dictionaryStack addObject:[NSMutableDictionary dictionary]];
//    DLog(@"........parseData\n %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    [parser setShouldProcessNamespaces:XMLReaderOptionsProcessNamespaces];
    [parser setShouldReportNamespacePrefixes:XMLReaderOptionsReportNamespacePrefixes];
    [parser setShouldResolveExternalEntities:XMLReaderOptionsResolveExternalEntities];
    parser.delegate = self;
    
    BOOL success = [parser parse];
    if (success)
    {
        NSDictionary *resultDict = [self.dictionaryStack objectAtIndex:0];
        return resultDict;
    }
    
    return nil;
}


#pragma mark -  NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"html"] ||
       [elementName isEqualToString:@"body"] ||
       [elementName isEqualToString:@"head"] ||
       [elementName isEqualToString:@"nav"]  ||
       [elementName isEqualToString:@"meta"] ||
       [elementName isEqualToString:@"link"])
    {
        return;
    }
    
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [self.dictionaryStack lastObject];
    
    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]]) {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [self.dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"html"] ||
       [elementName isEqualToString:@"body"] ||
       [elementName isEqualToString:@"head"] ||
       [elementName isEqualToString:@"nav"]  ||
       [elementName isEqualToString:@"meta"] ||
       [elementName isEqualToString:@"link"])
    {
        return;
    }
    
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [self.dictionaryStack lastObject];
    
    // Set the text property
    if ([self.textInProgress length] > 0)
    {
        // trim after concatenating
        NSString *trimmedString = [self.textInProgress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [dictInProgress setObject:[trimmedString mutableCopy] forKey:kXMLReaderTextNodeKey];
        
        // Reset the text
        self.textInProgress = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [self.dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    self.errorPointer = parseError;
}

@end
