//
//  PxeReaderTOCPageContentViewController.m
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 9/8/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderTOCPageContentViewController.h"
#import "PxePageDetail.h"
#import "PxeReaderTOCTableViewCell.h"

@interface PxeReaderTOCPageContentViewController ()

@end

@implementation PxeReaderTOCPageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.pagesIndex == 0)
    {
        self.backButton.hidden = YES;
        self.pagesTable.alwaysBounceHorizontal = NO;
        self.pagesTable.contentSize = CGSizeMake(self.pagesTable.frame.size.width, self.pagesTable.contentSize.height);
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.titleLabel.text = self.displayTitle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backToParent:(id)sender
{
    [self.delegate moveBackward];
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
    if (self.pagesArray)
    {
        numRows = [self.pagesArray count];
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSInteger row = [indexPath row];
    static NSString *tableIdentifier = @"tocTableCell";
    PxeReaderTOCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil)
    {
        cell = [[PxeReaderTOCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    NSDictionary *pageDict = [self.pagesArray objectAtIndex:indexPath.row];
    cell.cellLabel.text = [pageDict objectForKey:@"pageTitle"];
    cell.cellDownloaded.hidden = ![[pageDict objectForKey:@"isDownloaded"] boolValue];
    cell.cellDisclosure.hidden = ![[pageDict objectForKey:@"isChildren"] boolValue];
    cell.cellDisclosure.tag = indexPath.row;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *pageDict = [self.pagesArray objectAtIndex:indexPath.row];
    NSLog(@"PAGE SELECTED: %@", pageDict);
    
    // Jump to page
    NSString *pageURI = [pageDict objectForKey:@"pageURL"];
    NSLog(@"pageURI: %@", pageURI);
    if (pageURI)
    {
        [self.delegate tocSelectionEventWithURI:pageURI];
    }
    [self.pagesTable deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)drillDown:(id)sender
{
    NSLog(@"drillDownSender: %@", sender);
    UIButton *cellButton = (UIButton*)sender;
    NSDictionary *pageDict = [self.pagesArray objectAtIndex:cellButton.tag];
    NSLog(@"PAGE SELECTED: %@", pageDict);
    
    BOOL hasChildren = [[pageDict objectForKey:@"isChildren"] boolValue];
    if (hasChildren)
    {
        [self.delegate moveForwardToBranchWithID:[pageDict objectForKey:@"pageId"]];
    }
}



@end
