//
//  PxeReaderBookmarkListViewController.m
//  PxePlayerApp
//
//  Created by Mason, Darren J on 3/10/15.
//  Copyright (c) 2015 HappiestMinds. All rights reserved.
//

#import "PxeReaderBookmarkListViewController.h"
#import "PxePlayerBookmark.h"
#import "PxePlayerAlertView.h"
#import "PxePlayer.h"
#import "PxePlayerBookmarks.h"

enum ALERT_TAGS
{
    ADD_BOOKMARK_TAG,
    EDIT_BOOKMARK_TAG,
    DELETE_BOOKMARK_TAG,
    BOOKMARK_NO_TITLE_TAG,
    ERROR_TAG,
};

@interface PxeReaderBookmarkListViewController ()


@end

@implementation PxeReaderBookmarkListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect searchFrame = CGRectMake(0, 0, 320, 440);
    self.view.frame = searchFrame;
    
    [self.view addSubview:self.table];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.table addGestureRecognizer:lpgr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = ((PxePlayerBookmark *)self.bookmarks[row]).bookmarkTitle;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PxePlayerBookmark *bookmark = self.bookmarks[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(bookmarkSelectEventWithURI:)] )
    {
        [self.delegate performSelector: @selector(bookmarkSelectEventWithURI:) withObject:bookmark.uri];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.table];
    
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:p];
    if (indexPath == nil)
    {
        NSLog(@"long press on table view but not on a row");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"long press on table view at row %ld", (long)indexPath.row);
        PxePlayerBookmark *bookmark = self.bookmarks[indexPath.row];
        [self editBookmarkTitle:bookmark.bookmarkTitle andURL:bookmark.uri];
    }
}


-(void)doEditBookmarkTitle:(NSString*)title andURL:(NSString*)url
{
    //initiate AddBookmark web-service call
    __unsafe_unretained PxeReaderBookmarkListViewController *SELF = self;
    [[PxePlayer sharedInstance] editBookmarkWithTitle:title andURL:url withCompletionHandler:^(PxePlayerBookmark *bookmark, NSError *error)
     {
         if(error)
         {
             [SELF showError:[error localizedDescription] withTitle:NSLocalizedString(@"Bookmark Error", @"Bookmark Error")];
         }
         else {
             //update the bookmark image
             [[PxePlayer sharedInstance] getBookmarksWithCompletionHandler:^(PxePlayerBookmarks *bookmarks, NSError *error) {
                 if(!error)
                 {
                     self.bookmarks = bookmarks.bookmarks;
                     [self.table reloadData];
                 }
             }];
             
         }
     }];
}


-(void)editBookmarkTitle:(NSString*)title andURL:(NSString*)url
{
    PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:NSLocalizedString(@"Update Bookmark Title", @"Bookmark  name")
                                                                  message:nil
                                                                 delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel title")
                                                        otherButtonTitles:NSLocalizedString(@"Update", @"Update title"), nil];
    alert.tag = ADD_BOOKMARK_TAG;
    [alert setDelegate:self];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [alert textFieldAtIndex:0].secureTextEntry = NO;
    [alert textFieldAtIndex:1].secureTextEntry = NO;
    
    [[alert textFieldAtIndex:0] setText:title];
    [[alert textFieldAtIndex:1] setText:url];
    [alert show];
}

-(void)showError:(NSString*)error withTitle:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, @"Attention")
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case BOOKMARK_NO_TITLE_TAG:
            break;
        case ADD_BOOKMARK_TAG:
        {
            if(buttonIndex != 0)
            {
                if(![[alertView textFieldAtIndex:0].text isEqualToString:@""])
                {
                    //web-service call to add bookmark
                    NSString *trimmedTitle = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSString *URL = [alertView textFieldAtIndex:1].text ;
                    
                    [self doEditBookmarkTitle:trimmedTitle andURL:URL];
                }
                else
                {
                    [self showError:nil withTitle:@"Bookmark Title Cannot Be Empty"];
                }
            }
        }
            break;
        default:
            break;
    }
}


@end
