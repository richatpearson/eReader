//
//  PXEPlayerMenuControllerManager.m
//  PxeReader
//
//  Created by Richard Rosiak on 10/6/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

#import "PXEPlayerMenuControllerManager.h"
#import "PXEPlayerMacro.h"
#import "Reachability.h"
#import "PxePlayer.h"
#import "UIMenuItem+CXAImageSupport.h"

@interface PXEPlayerMenuControllerManager()

@property (nonatomic, strong) UIWebView *pxeWebView;
@property (nonatomic, strong) NSString *bundlePath;

@property (nonatomic, strong) UIImage *menuNoteIcon;
@property (nonatomic, strong) UIImage *menuTrashIcon;
@property (nonatomic, strong) UIImage *menuYellowIcon;
@property (nonatomic, strong) UIImage *menuPinkIcon;
@property (nonatomic, strong) UIImage *menuGreenIcon;
@property (nonatomic, strong) UIImage *menuClearIcon;

@end

@implementation PXEPlayerMenuControllerManager

- (instancetype) initWithWebView:(UIWebView*)webView
{
    if (self = [super init])
    {
        self.pxeWebView = webView;
        self.bundlePath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],@"PxeReaderResources.bundle"];
        
        [self createMenuIcons];
    }
    
    return self;
}

- (void) createMenuIcons
{
    self.menuNoteIcon = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"note_32px.png"]];
    self.menuTrashIcon = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"trash2_32px.png"]];
    self.menuYellowIcon = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"yellowCircle32px.png"]];
    self.menuPinkIcon = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"pinkCircle32px.png"]];
    self.menuGreenIcon = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"greenCircle32px.png"]];
    self.menuClearIcon = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"nohighlightCircle.png"]];
}

- (void) setUpBaseMenuItems
{
    DLog(@"Setting up base menu");
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    UIMenuItem *highlightItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(highlight:)];
    UIMenuItem *noteItem = [[UIMenuItem alloc] initWithTitle:@"Note" action:@selector(annotate:)];
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copySelection:)];
    
    NSArray *menuItems = [[NSArray alloc] initWithObjects:highlightItem, noteItem, copyItem, nil];
    
    menuController.menuItems = menuItems;
}

- (void) setUpHighlightMenuItemsWithColor:(PxePlayerHighlightColor)color baseMenuPosition:(CGRect)menuPosition;
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    UIMenuItem *colorItem = [[UIMenuItem alloc] initWithTitle:@"color"
                                                       action:@selector(showColorChoices:)
                                                        image:[self selectImageForColor:color]];
    
    UIMenuItem *noteItem = [[UIMenuItem alloc] initWithTitle:@"note"
                                                      action:@selector(annotateAfterHighlight:)
                                                       image:self.menuNoteIcon];
    
    UIMenuItem *trashItem = [[UIMenuItem alloc] initWithTitle:@"trash"
                                                       action:@selector(deleteNote:)
                                                        image:self.menuTrashIcon];
    
    menuController.menuItems = @[colorItem, noteItem, trashItem];
    
    DLog(@"Setting up highlight menu at x: %f and y: %f", menuPosition.origin.x, menuPosition.origin.y);
    [menuController setTargetRect:menuPosition inView:self.pxeWebView];
    [menuController setMenuVisible:YES animated:NO];
}

- (UIImage*) selectImageForColor:(PxePlayerHighlightColor)color
{
    switch (color) {
        case PxePlayerYellowHighlight:
            return self.menuYellowIcon;
            break;
        case PxePlayerGreenHighlight:
            return self.menuGreenIcon;
            break;
        case PxePlayerPinkHighlight:
            return self.menuPinkIcon;
            break;
        case PxePlayerTurquoiseHighlight:
            return nil;
            break;
        case PxePlayerClearHighlight:
            return self.menuClearIcon;
            break;
        default:
            return self.menuYellowIcon;
    }
}

- (void) setUpColorMenuItemsforBaseMenuPosition:(CGRect)menuPosition
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    UIMenuItem *yellowCircleItem = [[UIMenuItem alloc] initWithTitle:@"yellow"
                                                              action:@selector(highlightInYellow:)
                                                               image:self.menuYellowIcon];
    
    UIMenuItem *pinkCircleItem = [[UIMenuItem alloc] initWithTitle:@"pink"
                                                      action:@selector(highlightInPink:)
                                                       image:self.menuPinkIcon];
    
    UIMenuItem *greenCircleItem = [[UIMenuItem alloc] initWithTitle:@"green"
                                                       action:@selector(highlightInGreen:)
                                                        image:self.menuGreenIcon];
    
    UIMenuItem *nohighlightCircleItem = [[UIMenuItem alloc] initWithTitle:@"nohighlight"
                                                                   action:@selector(highlightInClear:)
                                                                    image:self.menuClearIcon];
    
    menuController.menuItems = @[yellowCircleItem, pinkCircleItem, greenCircleItem, nohighlightCircleItem];
    
    DLog(@"Setting up color menu at x: %f and y: %f", menuPosition.origin.x, menuPosition.origin.y);
    [menuController setTargetRect:menuPosition inView:self.pxeWebView];
    [menuController setMenuVisible:YES animated:NO];
}

@end
