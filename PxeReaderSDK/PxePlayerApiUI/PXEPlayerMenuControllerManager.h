//
//  PXEPlayerMenuControllerManager.h
//  PxeReader
//
//  Created by Richard Rosiak on 10/6/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PxePlayerHighlightColor)
{
    PxePlayerClearHighlight     = -1,
    PxePlayerYellowHighlight    = 0,
    PxePlayerPinkHighlight      = 1,
    PxePlayerGreenHighlight     = 2,
    PxePlayerTurquoiseHighlight = 3 //sharable highlight
};

@interface PXEPlayerMenuControllerManager : NSObject

- (instancetype) initWithWebView:(UIWebView*)webView;

- (void) setUpBaseMenuItems;

- (void) setUpHighlightMenuItemsWithColor:(PxePlayerHighlightColor)color baseMenuPosition:(CGRect)menuPosition;

- (void) setUpColorMenuItemsforBaseMenuPosition:(CGRect)menuPosition;

@end
