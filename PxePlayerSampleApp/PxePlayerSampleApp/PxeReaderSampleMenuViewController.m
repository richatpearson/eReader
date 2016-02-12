//
//  PxeReaderSampleMenuViewController.m
//  
//
//  Created by Tomack, Barry on 1/7/16.
//
//

#import "PxeReaderSampleMenuViewController.h"
#import "PxePlayer.h"

@interface PxeReaderSampleMenuViewController ()

@end

@implementation PxeReaderSampleMenuViewController

enum MENU_OPTIONS
{
    MENU_EVENT_SEARCH,
    MENU_EVENT_TOC,
    MENU_EVENT_ANNOTATIONS,
    MENU_EVENT_BOOKMARKS,
    MENU_EVENT_GLOSSARY,
    MENU_EVENT_CUSTOMBASKET,
    MENU_EVENT_SETTINGS

};

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.customBasketButton.hidden = ![[PxePlayer sharedInstance] currentContextHasCustomBasket];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) searchEventHandler:(id)sender
{
    if(!self.menuDelegate)
    {
        return;
    }
    if([[self menuDelegate] respondsToSelector:@selector(searchEventHandler:)])
    {
        NSLog(@"sender: %@", sender);
        [[self menuDelegate] searchEventHandler:sender];
    }
}

- (IBAction) tocEventHandler:(id)sender
{
    if(!self.menuDelegate)
    {
        return;
    }
    if([[self menuDelegate] respondsToSelector:@selector(tocEventHandler:)])
    {
        [[self menuDelegate] tocEventHandler:sender];
    }
}

- (IBAction)annotationEventHandler:(id)sender
{
    if(!self.menuDelegate)
    {
        return;
    }
    if([[self menuDelegate] respondsToSelector:@selector(annotationsEventHandler:)])
    {
        [[self menuDelegate] annotationsEventHandler:sender];
    }
}

- (IBAction)bookmarksEventHandler:(id)sender
{
    if(!self.menuDelegate)
    {
        return;
    }
    if([[self menuDelegate] respondsToSelector:@selector(bookmarksEventHandler:)])
    {
        [[self menuDelegate] bookmarksEventHandler:sender];
    }
}

- (IBAction)glossaryEventHandler:(id)sender
{
    if(!self.menuDelegate)
    {
        return;
    }
    if([[self menuDelegate] respondsToSelector:@selector(glossaryEventHandler:)])
    {
        [[self menuDelegate] glossaryEventHandler:sender];
    }
}

- (IBAction)customBasketEventHandler:(id)sender
{
    if(!self.menuDelegate)
    {
        return;
    }
    if([[self menuDelegate] respondsToSelector:@selector(customBasketEventHandler:)])
    {
        [[self menuDelegate] customBasketEventHandler:sender];
    }
}

- (IBAction)settingsEventHandler:(id)sender
{
    if(!self.menuDelegate)
    {
        return;
    }
    if([[self menuDelegate] respondsToSelector:@selector(settingsEventHandler:)])
    {
        [[self menuDelegate] settingsEventHandler:sender];
    }
}

@end
