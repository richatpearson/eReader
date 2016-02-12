//
//  PxePlayerXMLParser.m
//  PxeReader
//
//  Created by Saro Bear on 30/12/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerXMLParser.h"

@interface PxePlayerXMLParser () <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray        *collections;
@property (nonatomic, strong) NSMutableDictionary   *entity;
@property (nonatomic, strong) NSMutableString       *textInProgress;

@end

@implementation PxePlayerXMLParser

-(NSArray*)parseData:(NSData*)data
{
    self.collections    = [[NSMutableArray alloc] initWithCapacity:0];
    self.textInProgress = [[NSMutableString alloc] init];
    
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    if (success)
    {
        return self.collections;
    }
    
    return nil;
}


#pragma mark -  NSXMLParserDelegate methods

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    if(![elementName caseInsensitiveCompare:@"dt"])
    {
        self.entity = [[NSMutableDictionary alloc] initWithCapacity:0];
    }

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *trimmedString = [self.textInProgress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString) {
        [self.entity setObject:trimmedString forKey:elementName];
    }
    
    if(![elementName caseInsensitiveCompare:@"dd"]) {
        [self.collections addObject:self.entity];
    }
    
    self.textInProgress = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
}

@end
