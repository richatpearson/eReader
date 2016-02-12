//
//  PxeReaderGlossaryViewController.h
//  PxePlayerApp
//
//  Created by Tomack, Barry on 3/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxeReaderGlossaryViewController.h"
#import "PxePlayerAlertView.h"
#import "PxePlayer.h"

@interface PxeReaderGlossaryViewController ()


@end

@implementation PxeReaderGlossaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect glossaryFrame = CGRectMake(0, 0, 320, 440);
    self.view.frame = glossaryFrame;
    
    [self.view addSubview:self.table];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) buildGlossary:(NSArray *)gArray
{
    if (! self.glossaryDict)
    {
        self.glossaryDict = [NSMutableDictionary new];
    }
    if (! self.sectionArray)
    {
        self.sectionArray = [NSMutableArray new];
    }
    
    // Sort the glossary by term
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"term"
                                                               ascending:YES
                                                                selector:@selector(localizedCaseInsensitiveCompare:)];
    
    gArray = [gArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSArray *sortedArray = [gArray copy];
    
    NSMutableArray *sortingSectionArray = [NSMutableArray new];
    for (NSDictionary *gTerm in sortedArray)
    {
        NSString *term = [gTerm objectForKey:@"term"];
        NSString *letter = [term substringToIndex:1];
        
        if (![sortingSectionArray containsObject:letter])
        {
            [sortingSectionArray addObject:letter];
        }
        
        NSMutableArray *termsByLetter = [self.glossaryDict objectForKey:letter];
        if (!termsByLetter)
        {
            termsByLetter = [NSMutableArray new];
        }
        [termsByLetter addObject:gTerm];
        [self.glossaryDict setObject:termsByLetter forKey:letter];
    }
    self.sectionArray = [sortingSectionArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark -TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.sectionArray objectAtIndex:section] uppercaseString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionKey = [self.sectionArray objectAtIndex:section];
    
    NSArray *glossaryArray = [self.glossaryDict objectForKey:sectionKey];
    
    return [glossaryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSString *key = [self.sectionArray objectAtIndex:section];
    NSArray *glossaryArray = [self.glossaryDict objectForKey:key];
    NSDictionary *glossaryEntry = [glossaryArray objectAtIndex:row];
    
    cell.textLabel.text = [glossaryEntry objectForKey:@"term"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *key = [self.sectionArray objectAtIndex:section];
    NSArray *glossaryArray = [self.glossaryDict objectForKey:key];
    NSDictionary *glossaryEntry = [glossaryArray objectAtIndex:row];
    
    PxePlayerAlertView *alert = [[PxePlayerAlertView alloc] initWithTitle:[glossaryEntry objectForKey:@"term" ]
                                                                  message:[glossaryEntry objectForKey:@"definition" ]
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil, nil];
    [alert setDelegate:self];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showError:(NSString*)error withTitle:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, @"Attention") message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil];
    [alert show];
}

@end
