//
//  PxePlayerSampleToolbarViewController.m
//  PxePlayerSampleApp
//
//  Created by Mason, Darren J on 3/19/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderSampleToolbarViewController.h"

enum OPTIONS
{
    TOOLBAR_EVENT_BOOKSHELF,
    TOOLBAR_EVENT_BOOKMARK,
    TOOLBAR_EVENT_MENU
};

@interface PxeReaderSampleToolbarViewController ()

@end

@implementation PxeReaderSampleToolbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.toolBar.backgroundColor = [UIColor blackColor];
    
    self.bookshelfBarButton.target = self;
    self.bookshelfBarButton.action = @selector(actionEventHandler:);
    self.bookshelfBarButton.tag = TOOLBAR_EVENT_BOOKSHELF;
    
    self.bookmarkBarButton.target = self;
    self.bookmarkBarButton.action = @selector(actionEventHandler:);
    self.bookmarkBarButton.tag  = TOOLBAR_EVENT_BOOKMARK;
    
    self.menuBarButton.target = self;
    self.menuBarButton.action = @selector(actionEventHandler:);
    self.menuBarButton.tag = TOOLBAR_EVENT_MENU;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setBookmarked:(BOOL)isBookmarked
{
    if(isBookmarked)
    {
        [self.bookmarkBarButton setImage:[UIImage imageNamed:@"bookmark.png"]];
    }
    else
    {
        [self.bookmarkBarButton setImage:[UIImage imageNamed:@"bookmark_off.png"]];
    }
}

-(void)actionEventHandler:(id)sender
{
    NSInteger selectedAction = [sender tag];
    
    if(!self.toolbarDelegate) {
        return;
    }
    NSLog(@"actionEvent: %ld", (long)selectedAction);
    switch (selectedAction)
    {
        case TOOLBAR_EVENT_BOOKSHELF:
            if([self.toolbarDelegate respondsToSelector:@selector(bookshelfEventHandler:)]){
                [self.toolbarDelegate bookshelfEventHandler:sender];
            }
            break;
        case TOOLBAR_EVENT_BOOKMARK:
            if([[self toolbarDelegate] respondsToSelector:@selector(bookmarkEventHandler:)]){
                [[self toolbarDelegate] bookmarkEventHandler:sender];
            }
            break;
        case TOOLBAR_EVENT_MENU:
            if([[self toolbarDelegate] respondsToSelector:@selector(menuEventHandler:)]){
                [[self toolbarDelegate] menuEventHandler:sender];
            }
            break;
        default:
            break;
    }
}

@end
