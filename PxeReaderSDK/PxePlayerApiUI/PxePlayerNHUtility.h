//
//  PxePlayerNHUtility.h
//  PxeReader
//
//  Created by Richard Rosiak on 10/21/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXEPlayerMenuControllerManager.h"

@interface PxePlayerNHUtility : NSObject

+ (NSString*) buildJSCallForNote:(NSString*)note
                       colorCode:(NSInteger)colorCode
               webViewRequestUri:(NSString*)webViewUri
                 isAnnotationNew:(BOOL)isNew
                  annotationDttm:(NSString*)annotationDttm;

+ (NSDictionary*) parseAnnotationDictFromMessage:(NSString*)message;

+ (NSString*) parseNoteTextFromAnnotationMessage:(NSString*)message;

+ (BOOL) isAnnotationNewForMessage:(NSString*)message;

+ (BOOL) wasSidebarIconClicked:(NSString*)message;

+ (PxePlayerHighlightColor) parseColorCodeFromAnnotationMessage:(NSString*)message;

+ (NSInteger) translateHexColor:(NSString*)hexColor;

+ (BOOL) isEventConfirmingDelete:(NSString*)message;

+ (NSString*) parseAnnotationDttmFromMessage:(NSString*)message;

@end
