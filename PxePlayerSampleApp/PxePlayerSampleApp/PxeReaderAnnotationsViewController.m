//
//  PxeReaderAnnotationsViewController.h
//  PxePlayerApp
//
//  Created by Tomack, Barry on 3/10/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxeReaderAnnotationsViewController.h"
#import "PxePlayer.h"
#import "PxePlayerAnnotations.h"

@interface PxeReaderAnnotationsViewController ()

@end

@implementation PxeReaderAnnotationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect searchFrame = CGRectMake(0, 0, 320, 440);
    self.view.frame = searchFrame;
    
    [self.view addSubview:self.table];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -TableView Methods

// somewhere else in your code ...

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.annotations count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [self.annotations allKeys];
    return [keys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *keys = [self.annotations allKeys];
    NSString *uri = [keys objectAtIndex:section];
    
    NSArray *annotationArray = [self.annotations objectForKey:uri];
    return [annotationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSString *uri = [[self.annotations allKeys] objectAtIndex:section];
    NSArray *annotationArray = [self.annotations objectForKey:uri];
    PxePlayerAnnotation *annotation = (PxePlayerAnnotation *)[annotationArray objectAtIndex:row];
    NSLog(@"annotation: %@", annotation);
    cell.textLabel.text = annotation.selectedText;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *uri = [[self.annotations allKeys] objectAtIndex:section];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(annotationSelectEventWithAnnotation:)])
    {
        NSArray *annotationArray = [self.annotations objectForKey:uri];
        PxePlayerAnnotation *annotation = (PxePlayerAnnotation *)[annotationArray objectAtIndex:row];
        
        [self.delegate performSelector:@selector(annotationSelectEventWithAnnotation:) withObject:annotation];
    }
}

-(void)showError:(NSString*)error withTitle:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, @"Attention")
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK title") otherButtonTitles:nil];
    [alert show];
}

@end
