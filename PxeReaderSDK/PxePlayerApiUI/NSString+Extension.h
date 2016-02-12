//
//  NSString+Extension.h
//  PxePlayerApi
//
//  Created by Satyanarayana on 14/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


@interface NSString (Extension)

- (NSString *) md5;

- (NSComparisonResult) compareNumberStrings:(NSString *)str;

- (NSString *) urlEncodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString *) urlDecodeUsingEncoding;

- (NSString *)stringEscapedForJavasacript;

- (NSString*) escapeCharactersInString;

- (NSString*) unEscapeCharactersInString;

- (NSArray *) separateStringByParagraph;

- (NSNumber *) asNSNumber;

@end
