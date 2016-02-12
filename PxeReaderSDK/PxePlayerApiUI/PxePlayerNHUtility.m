//
//  PxePlayerNHUtility.m
//  PxeReader
//
//  Created by Richard Rosiak on 10/21/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

#import "PxePlayerNHUtility.h"
#import "NSString+Extension.h"
#import "PxePlayer.h"
#import "PXEPlayerMacro.h"

@implementation PxePlayerNHUtility

+ (NSString*) buildJSCallForNote:(NSString*)note
                       colorCode:(NSInteger)colorCode
               webViewRequestUri:(NSString*)webViewUri
                 isAnnotationNew:(BOOL)isNew
                  annotationDttm:(NSString*)annotationDttm
{
    NSMutableString *jsonString = [NSMutableString new];
    
    NSString *uri = [[self getRelativeURIForWebRequest:webViewUri] stringEscapedForJavasacript];
    
    [jsonString appendFormat:@"{"];
    [jsonString appendFormat:@"\"colorCode\":%@,",[NSString stringWithFormat:@"%ld",(long)colorCode]];
    [jsonString appendFormat:@"\"noteText\":\"%@\",", [note stringEscapedForJavasacript]];
    [jsonString appendFormat:@"\"expLabel\":\"%@\",", @""];
    [jsonString appendFormat:@"\"shareable\":\"%@\"," ,@"false"];
    [jsonString appendFormat:@"\"baseURL\":\"%@/\",",[[[PxePlayer sharedInstance] getOnlineBaseURL] stringEscapedForJavasacript]];
    [jsonString appendFormat:@"\"uri\":\"%@\",", uri];
    [jsonString appendFormat:@"\"identityId\":\"%@\"",[[PxePlayer sharedInstance] getIdentityID]];
    if (!isNew) {
        [jsonString appendFormat:@",\"annotationDttm\":%@", annotationDttm];
    }
    [jsonString appendFormat:@"}"];
    
    DLog(@"jsonString for highlight: %@", jsonString);
    
    NSString *functionName = (isNew) ? @"saveMobileAnnotation" : @"updateMobileAnnotation";
    NSString *jsCall = [NSString stringWithFormat:@"Annotate.instance.%@(%@)",functionName, jsonString];
    DLog(@"jsCall: %@", jsCall);
    
    [[PxePlayer sharedInstance] dispatchGAIEventWithCategory:@"annotation"
                                                      action:functionName
                                                       label:uri
                                                       value:[NSNumber numberWithInteger:colorCode]];
    
    return jsCall;
}

+ (NSString *) getRelativeURIForWebRequest:(NSString*)webRequest
{
    NSString *uri = webRequest;
    
    uri = [[PxePlayer sharedInstance] removeBaseUrlFromUrl:uri];
    uri = [[PxePlayer sharedInstance] formatRelativePathForJavascript:uri];
    DLog(@"relativeURI: %@", uri);
    return uri;
}

+ (NSString*) parseNoteTextFromAnnotationMessage:(NSString*)message
{
    NSDictionary *annotationDict = [self parseAnnotationDictFromMessage:message];
    NSDictionary *data = [annotationDict objectForKey:@"data"];
    
    return [data objectForKey:@"noteText"];
}

+ (NSDictionary*) parseAnnotationDictFromMessage:(NSString*)message
{
    if (!message) {
        return [[NSDictionary alloc] init];
    }
    
    //DLog(@"annot. message: %@", message);
    NSError *jsonError;
    
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *annotationDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
    if (!jsonError) {
        if([annotationDict objectForKey:@"annotations"])
        {
            annotationDict = [annotationDict objectForKey:@"annotations"][0];
        }
    }
    else
    {
        //TODO: handle error
        //return ...
    }
    
    return annotationDict;
}

+ (BOOL) isAnnotationNewForMessage:(NSString*)message
{
    if (!message) {
        return NO;
    }
    
    DLog(@"Is annotation new? %@", ([[[self parseAnnotationDictFromMessage:message] objectForKey:@"isNew"] boolValue])?@"YES":@"NO");
    
    return ([[[self parseAnnotationDictFromMessage:message] objectForKey:@"isNew"] boolValue]);
}

+ (BOOL) wasSidebarIconClicked:(NSString*)message
{
    if (!message) {
        return NO;
    }
    
    DLog(@"Was side bar icon clicked? %@", ([[[self parseAnnotationDictFromMessage:message] objectForKey:@"isSidebarIcon"] boolValue])?@"YES":@"NO");
    
    return ([[[self parseAnnotationDictFromMessage:message] objectForKey:@"isSidebarIcon"] boolValue]);
}

+ (PxePlayerHighlightColor) parseColorCodeFromAnnotationMessage:(NSString*)message
{
    if ([self isAnnotationNewForMessage:message]) { //need to apply last highlight used
        return (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"lastHighlightUsed"];
    }
    
    NSDictionary *annotationDict = [self parseAnnotationDictFromMessage:message];
    NSDictionary *data = [annotationDict objectForKey:@"data"];
    
    NSString *colorCode = [data objectForKey:@"colorCode"];
    
    return (PxePlayerHighlightColor)colorCode.integerValue;
}

+ (NSInteger) translateHexColor:(NSString*)hexColor
{
    if ([hexColor isKindOfClass:[NSString class]])
    {
        if ([hexColor isEqualToString:@"#FFD231"])
        {
            return PxePlayerYellowHighlight;
        }
        else if ([hexColor isEqualToString:@"#FB91CF"])
        {
            return PxePlayerPinkHighlight;
        }
        else if ([hexColor isEqualToString:@"#54DF48"])
        {
            return PxePlayerGreenHighlight;
        }
        else if ([hexColor isEqualToString:@"transparent"])
        {
            return PxePlayerClearHighlight;
        }
    }
    
    if ([hexColor isKindOfClass:[NSNumber class]]) {
        DLog(@"hexColor is NSNumber");
        return hexColor.integerValue;
    }
    
    return PxePlayerYellowHighlight;
}

+ (BOOL) isEventConfirmingDelete:(NSString*)message
{
    if (!message) {
        return NO;
    }
    
    NSString *operation = [[self parseAnnotationDictFromMessage:message] objectForKey:@"operation"];
    
    return [operation isEqualToString:@"remove"];
}

+ (NSString*) parseAnnotationDttmFromMessage:(NSString*)message
{
    NSDictionary *annotationDict = [self parseAnnotationDictFromMessage:message];
    NSString *annotDttm = [annotationDict objectForKey:@"annotationDttm"];
    
    return annotDttm;
}

@end
