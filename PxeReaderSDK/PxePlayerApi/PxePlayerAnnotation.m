//
//  PxePlayerAnnotation.m
//  PxeReader
//
//  Created by Saro Bear on 07/11/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerAnnotation.h"
#import "PXEPlayerMacro.h"
#import "NSString+Extension.h"

@implementation PxePlayerAnnotation

-(id)init
{
    if((self = [super init]))
    {
        self.range = @"";
        self.colorCode = @"";
        self.noteText = @"";
        self.selectedText = @"";
        self.contentId = @"";
        self.annotationDttm = @"";
        self.labels = [NSArray new];
        self.appData = [NSDictionary new];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary*)annoDict
{
    if((self = [super init]))
    {
        self.annotationDttm = [annoDict objectForKey:@"annotationDttm"];
        DLog(@"self.annotationDttm: %@", self.annotationDttm);
        self.shareable = [[annoDict objectForKey:@"shareable"] boolValue];
        
        NSDictionary *data = [annoDict objectForKey:@"data"];
        
        if(data)
        {
            self.range = [data objectForKey:@"range"];
            self.colorCode = [data objectForKey:@"colorCode"];
            self.noteText = [data objectForKey:@"noteText"];
            self.selectedText = [data objectForKey:@"selectedText"];
            self.labels = [data objectForKey:@"labels"];
        }
        self.contentId = @"";
        self.appData = [NSDictionary new];
    }
    return self;
}

-(void)dealloc
{
    self.range = nil;
    self.colorCode = nil;
    self.noteText = nil;
    self.selectedText = nil;
    self.contentId = nil;
    self.annotationDttm = nil;
    self.labels = nil;
    self.appData = nil;
}

- (NSString *) description
{
    NSMutableString *annotationDesc = [NSMutableString stringWithString:@"PxePlayerAnnotation: \n"];
    [annotationDesc appendFormat:@"   annotationDttm: %@ \n", self.annotationDttm];
    [annotationDesc appendFormat:@"   uri: %@ \n", self.uri];
    [annotationDesc appendFormat:@"   colorCode: %@ \n", self.colorCode];
    [annotationDesc appendFormat:@"   isMathML: %@ \n", self.isMathML?@"YES":@"NO"];
    [annotationDesc appendFormat:@"   labels: %@ \n", self.labels];
    [annotationDesc appendFormat:@"   noteText: %@ \n", self.noteText];
    [annotationDesc appendFormat:@"   selectedText: %@ \n", self.selectedText];
    [annotationDesc appendFormat:@"   range: %@ \n", self.range];
    [annotationDesc appendFormat:@"   contentId: %@ \n", self.contentId];
    
    [annotationDesc appendFormat:@"   shareable: %@ \n", self.shareable?@"YES":@"NO"];
    
    [annotationDesc appendFormat:@"   appData: %@ \n", self.appData];
    
    return annotationDesc;
}

- (NSString *) asJSONString
{
    NSDictionary *jsonDict = [self asDictionaryForJSON];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
    
    return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}

- (NSDictionary *) asDictionaryForJSON
{
    //    NSDictionary *dataDict = @{
    //                               @"colorCode":self.colorCode,
    //                               @"noteText":self.noteText,
    //                               @"isMathMl":self.isMathML ? @YES : @NO,
    //                               @"range":self.range,
    //                               @"selectedText":self.selectedText,
    //                               @"labels":[self.labels]
    //                               };
    NSMutableDictionary *dataDict = [NSMutableDictionary new];
    if (self.colorCode) {
        [dataDict setObject:self.colorCode forKey:@"colorCode"];
    }
    if (self.noteText) {
        [dataDict setObject:self.noteText forKey:@"noteText"];
    }
    if (self.isMathML) {
        [dataDict setObject:(self.isMathML ? @YES : @NO) forKey:@"expLabel"];
    }
    if (self.range) {
        [dataDict setObject:self.range forKey:@"range"];
    }
    if (self.selectedText) {
        [dataDict setObject:self.selectedText forKey:@"selectedText"];
    }
    if (self.labels) {
        [dataDict setObject:self.labels forKey:@"labels"];
    }
    DLog(@"self.annotationDttm: %@", self.annotationDttm);
    NSDictionary *jsonDict = @{
                               @"annotationDttm":self.annotationDttm,
                               @"shareable":self.shareable? @YES : @NO,
                               @"data":dataDict
                               };
    return jsonDict;
}

- (void) setNoteText:(NSString *)note
{
    if (note)
    {
//        note = [note urlDecodeUsingEncoding];
        note = [note unEscapeCharactersInString];
    }
    _noteText = note;
}

- (void) setDecodedNoteText:(NSString*)note
{
    if (note)
    {
        _noteText = note;
    }
}

//- (void) setColorCode:(NSString *)code
//{
//    if([code rangeOfString:@"#"].location != NSNotFound)
//    {
//        if ([code isEqualToString:@"#FFD231"]) // Yellow
//        {
//            _colorCode = @"0";
//        }
//        else if ([code isEqualToString:@"#FB91CF"]) // Pink
//        {
//            _colorCode = @"1";
//        }
//        else if ([code isEqualToString:@"#54DF48"]) // Green
//        {
//            _colorCode = @"2";
//        }
//        else if ([code isEqualToString:@"#66ffff"]) // Blue
//        {
//            _colorCode = @"2";
//        }
//    }
//    else
//    {
//        _colorCode = code;
//    }
//}

/*
 KEEP UNTIL UPLOADING ANNOTATIONS IS WORKING
 
 @"colorCode":self.colorCode,
 @"noteText":self.noteText,
 @"expLabel":self.isMathML ? @"true" : @"",
 @"shareable":self.shareable?@"true":@"false",
 annotation.colorCode = (long)_shareable.tag>0? @"3" : [NSString stringWithFormat:@"%ld",(long)_currentColor];
 annotation.noteText = noteText;
 annotation.isMathML = _mathML ? _mathML.text : @"";
 annotation.shareable = (long)_shareable.tag>0?@"true":@"false";
 */


@end