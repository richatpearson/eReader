//
//  PxeReaderSearchViewController.m
//  PxePlayerApp
//
//  Created by Tomack, Barry on 3/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxeReaderSearchViewController.h"
#import "PxePlayer.h"
#import "PxePlayerAnnotations.h"
#import "PxePlayerAnnotation.h"
#import "PxePlayerSearchPages.h"
#import "PxePlayerSearchPage.h"

@interface PxeReaderSearchViewController ()


@end

@implementation PxeReaderSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect searchFrame = CGRectMake(0, 0, 320, 440);
    self.view.frame = searchFrame;
    
    // Search Bar
    NSLog(@"View Frame Width: %f", self.view.frame.size.width);
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 40, 320, 44)];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    // Table
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,84,320,396) style:UITableViewStylePlain];
    //Remember to set the table view delegate and data provider
    tableView.delegate = self;
    tableView.dataSource = self;
    self.searchTable = tableView;
    [self.view addSubview:self.searchTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //[self.searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchPXE];
    [self.searchBar resignFirstResponder];
}

- (void)searchPXE
{
    NSString* searchStr = self.searchBar.text;
    NSLog(@"searchStr: %@", searchStr);
    
    if ([searchStr length] > 0)
    {
        [self.delegate searchInProgress];
        [[PxePlayer sharedInstance] searchContent:searchStr
                                             from:0
                                         withSize:100
                            withCompletionHandler:^(PxePlayerSearchPages *searchPages, NSError *error)
                             {
                                 if (error)
                                 {
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Search Error", @"Search Error")
                                                                                     message:error.localizedDescription
                                                                                    delegate:nil
                                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"OK title")
                                                                           otherButtonTitles:nil];
                                     [alert show];
                                 } else {
                                     
                                     self.searchPages = searchPages;
                                     [self.searchTable reloadData];
                                 }
                                 [self.delegate searchCompleted];
                             }];
    }
}

#pragma mark -TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (self.searchPages)
    {
        numRows = self.searchPages.totalResults;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger row = [indexPath row];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    PxePlayerSearchPage *searchPage = [self.searchPages.searchedItems objectAtIndex:indexPath.row];
    cell.textLabel.text = searchPage.title;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PxePlayerSearchPage *searchPage = [self.searchPages.searchedItems objectAtIndex:indexPath.row];
    
    NSString *uri = searchPage.pageUrl;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(searchSelectEventWithURI:andHighlights:)] )
    {
        NSArray *highlights = self.searchPages.labels;
        
//        SEL selector = @selector(searchSelectEventWithURI:andHighlights:);
//        NSMethodSignature * mySignature = [NSMutableArray instanceMethodSignatureForSelector:@selector(addObject:)];
        NSMethodSignature *mySignature = [[self.delegate class] instanceMethodSignatureForSelector:@selector(searchSelectEventWithURI:andHighlights:)];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:mySignature];
        [inv setSelector:@selector(searchSelectEventWithURI:andHighlights:)];
        [inv setTarget:self.delegate];
        
        [inv setArgument:&(uri) atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        [inv setArgument:&(highlights) atIndex:3];
        
        [inv invoke];
        
//        [self.delegate performSelector: @selector(searchSelectEventWithURI:) withObject:uri];
    }
}

-(void)showError:(NSString*)error withTitle:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, @"Attention") message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil];
    [alert show];
}

@end
