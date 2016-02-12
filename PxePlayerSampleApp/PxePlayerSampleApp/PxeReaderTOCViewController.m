//
//  PxeReaderTOCViewController.m
//  PxePlayerSampleApp
//
//  Created by Tomack, Barry on 9/8/15.
//  Copyright (c) 2015 Pearson, Inc. All rights reserved.
//

#import "PxeReaderTOCViewController.h"
#import "PxePlayer.h"

@interface PxeReaderTOCViewController ()

@end

@implementation PxeReaderTOCViewController

- (id) initWithInitialParentId:(NSString*)parentId
                  displayTitle:(NSString*)displayTitle
{
    self = [super init];
    
    if (self)
    {
        _currentParentId = parentId;
        _displayTitle = displayTitle;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    // Add Frame
    CGRect tocFrame = CGRectMake(0, 0, 320, 440);
    self.view.frame = tocFrame;
    
    // DataModel
    self.tocParents = [[NSMutableArray alloc] initWithArray:@[self.currentParentId]];
    
    self.pageViewController = [storyboard instantiateViewControllerWithIdentifier:@"tocPageViewController"];
    self.pageViewController.dataSource = self;
    
    PxeReaderTOCPageContentViewController *startingViewController = [self contentViewControllerAtIndex:0];
    
    NSArray *viewControllers = @[startingViewController];
    NSLog(@"viewControllers: %@", viewControllers);
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
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

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PxeReaderTOCPageContentViewController*) viewController).pagesIndex;

    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }

    index--;
    return [self contentViewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PxeReaderTOCPageContentViewController*) viewController).pagesIndex;

    if (index == NSNotFound)
    {
        return nil;
    }

    index++;
    if (index == [self.tocParents count])
    {
        return nil;
    }
    return [self contentViewControllerAtIndex:index];
}

- (PxeReaderTOCPageContentViewController *)contentViewControllerAtIndex:(NSUInteger)index
{
//    NSLog(@"contentViewControllerAtIndex: %lu", (unsigned long)index);
//    NSLog(@"self.tocParents count: %lu", (unsigned long)[self.tocParents count]);
    if (index >= [self.tocParents count])
    {
        return nil;
    }

    // Storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    // Create a new view controller and pass suitable data.
    PxeReaderTOCPageContentViewController *pageContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"tocPageContentViewController"];
    if ([self.displayTitle isEqualToString:@"Table of Contents"])
    {
        pageContentViewController.pagesArray = [[PxePlayer sharedInstance] getTocTree:[self.tocParents objectAtIndex:index]];
    }
    else if ([self.displayTitle isEqualToString:@"Custom Basket"])
    {
        pageContentViewController.pagesArray = [[PxePlayer sharedInstance] getCustomBasketTree:[self.tocParents objectAtIndex:index]];

    }
    
//    NSLog(@"pageContentViewController pagesArray: %@", pageContentViewController.pagesArray);
    pageContentViewController.pagesIndex = index;
    pageContentViewController.delegate = self;
    pageContentViewController.displayTitle = self.displayTitle;
    NSLog(@"pageContentViewController.displayTitle = %@", pageContentViewController.displayTitle);
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.tocParents count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.tocParents count] - 1;
}

#pragma mark pageContentDelegate
- (void) moveForwardToBranchWithID:(NSString*)parentId
{
    NSLog(@"moveForwardTo: %@", parentId);
    self.currentParentId = parentId;
    [self.tocParents addObject:parentId];
    
    PxeReaderTOCPageContentViewController *currentViewController = [self contentViewControllerAtIndex:[self.tocParents count]-1];
    NSArray *viewControllers = @[currentViewController];

    NSLog(@"viewControllers: %@", viewControllers);
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
}

- (void) moveBackward
{
    [self.tocParents removeLastObject];
    self.currentParentId = [self.tocParents lastObject];
    
    PxeReaderTOCPageContentViewController *currentViewController = [self contentViewControllerAtIndex:[self.tocParents count]-1];
    NSArray *viewControllers = @[currentViewController];
    
    NSLog(@"viewControllers: %@", viewControllers);
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
}

- (void) tocSelectionEventWithURI:(NSString*)uri
{
    [self.delegate tocSelectionEventWithURI:uri];
}

@end
