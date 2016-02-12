//
//  NSString+Extension.m
//  PxePlayerApi
//
//  Created by Satyanarayana on 14/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extension)

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

-(NSComparisonResult)compareNumberStrings:(NSString *)str
{
    NSNumber * me = [NSNumber numberWithInt:[self intValue]];
    NSNumber * you = [NSNumber numberWithInt:[str intValue]];
    
    return [me compare:you];
}

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                               NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"\n\r!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}

-(NSString *)urlDecodeUsingEncoding
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)self,
                                                                CFSTR(""),
                                                                kCFStringEncodingUTF8));
}

- (NSString *)stringEscapedForJavasacript
{
    // valid JSON object need to be an array or dictionary
    NSArray* arrayForEncoding = @[self];
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:arrayForEncoding options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString* escapedString = [jsonString substringWithRange:NSMakeRange(2, jsonString.length - 4)];
    return escapedString;
}

- (NSString*) escapeCharactersInString
{    
    NSMutableString* esc = [NSMutableString string];
    int i;
    for (i = 0; i < self.length; i++)
    {
        unichar c = [self characterAtIndex:i];
        if (c == '\\')
        {
            // escape backslash
            [esc appendFormat:@"\\\\"];
        }
        else if (c == '"')
        {
            // escape double quotes
            [esc appendFormat:@"\\\""];
        }
        else if (c >= 0x20 && c <= 0x7E)
        {
            // if it is a printable ASCII character (other than \ and "), append directly
            [esc appendFormat:@"%c", c];
        }
        else
        {
            // if it is not printable standard ASCII, append as a unicode escape sequence
            [esc appendFormat:@"\\u%04X", c];
        }
    }
    return esc;
}

- (NSString*) unEscapeCharactersInString
{
    NSString* unEsc = self;
    
    unEsc = [unEsc stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    unEsc = [unEsc stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    unEsc = [unEsc stringByReplacingOccurrencesOfString:@"\\\'" withString:@"\'"];
    
    // UNICODE Characters
    NSString *convertedString = [unEsc mutableCopy];
    
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    
    return convertedString;
}

- (NSArray *) separateStringByParagraph
{
    NSUInteger length = [self length];
    NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
    NSMutableArray *array = [NSMutableArray array];
    NSRange currentRange;
    while (paraEnd < length) {
        [self getParagraphStart:&paraStart end:&paraEnd
                    contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        [array addObject:[self substringWithRange:currentRange]];
    }
    return array;
}

- (NSNumber *) asNSNumber
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSNumber *strAsNumber = [f numberFromString:self];
    
    return strAsNumber;
}

@end
