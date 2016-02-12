//
//  PxePlayerUIEvents.m
//  PxeReader
//
//  Created by Tomack, Barry on 11/6/14.
//  Copyright (c) 2014 Pearson Inc. All rights reserved.
//

#import "PxePlayerUIEvents.h"

@implementation PxePlayerUIEvents

NSString* const PXE_UIError             = @"PXE UI Error";

NSString* const PXE_AnnotationAdd       = @"onAnnotationAdd";
NSString* const PXE_AnnotationData      = @"onAnnotationData";
NSString* const PXE_AnnotationLoad      = @"onAnnotationLoad";
NSString* const PXE_AnnotationFailure   = @"onAnnotationFailure";

NSString* const PXE_GlossaryData        = @"onGlossaryData";

NSString* const PXE_WidgetEvent         = @"onWidgetEvent";

NSString* const PXE_NotebookEvent       = @"onNotebookPrompt";

NSString* const PXE_PageClickEvent      = @"onPageClickEvent";

NSString* const PXE_ContentStartedScrolling = @"contentStartedScrolling";

NSString* const PXE_ContentStoppedScrolling = @"contentStoppedScrolling";

NSString* const PXE_ContentScrolling    = @"contentScrolling";

NSString* const PXE_Navigation          = @"onNavigation";

@end
