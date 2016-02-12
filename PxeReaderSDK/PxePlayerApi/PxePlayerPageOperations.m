//
//  PxePlayerPageDownloader.m
//  PxePlayerApi
//
//  Created by Saro Bear on 18/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerPageOperations.h"
#import "PxePlayerPageOperation.h"
#import "PxePlayerPagesQuery.h"
#import "PXEPlayerMacro.h"

#define MAX_OPERATION 7

@interface PxePlayerPageOperations () <PxePlayerOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSMutableDictionary *operations;

@end

@implementation PxePlayerPageOperations

#pragma mark - Private methods

-(void)setOperationsLowPriority
{
    NSArray *operations = [self.operations allKeys];
    for (short i = 0; i < [self.operations count]; i++)
    {
        NSString *key = [operations objectAtIndex:i];
        NSOperation *operation = [self.operations objectForKey:key];
        [operation setQueuePriority:NSOperationQueuePriorityLow];
    }
}


#pragma mark - Self methods

-(id)init
{
    self = [super init];
    
    if(self){
        //initialize the dictionary which holds the number of 
        self.downloadQueue = [[NSOperationQueue alloc] init];
        self.downloadQueue.name = @"pages_download_queue";
        [self.downloadQueue setMaxConcurrentOperationCount:1];
        
        self.operations = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return self;
}

-(void)dealloc
{
    self.downloadQueue = nil;
    self.operations = nil;
}

#pragma mark - Public methods

- (void) addOperations:(NSArray*)operations
     withPriorityIndex:(NSInteger)priorityIndex
         dataInterface:(PxePlayerDataInterface*)dataInterface
             authToken:(NSString *)authToken
                userId:(NSString *)userId
{
    DLog(@"OPERATIONS: %@\n\n", operations);
    //reset the old operations priority as low
    [self setOperationsLowPriority];    
    
    for (short i = 0; i < [operations count]; i++)
    {
        NSString *pageUrl = [operations objectAtIndex:i];
        PxePlayerPageOperation *pageOperation = [self.operations objectForKey:pageUrl];
        if(!pageOperation)
        {
            PxePlayerPagesQuery *query = [[PxePlayerPagesQuery alloc] init];
            [query setAuthToken:authToken];
            [query setUserUUID:userId];
            [query setPageUrl:pageUrl];
            
            pageOperation = [[PxePlayerPageOperation alloc] initWithQuery:query
                                                            dataInterface:dataInterface];
            [pageOperation setPageDelegate:self];
            if(pageUrl) {
                [self.operations setObject:pageOperation forKey:pageUrl];
                [self.downloadQueue addOperation:pageOperation];
            }
        }
        
        //set the queue priority
        if(i == priorityIndex) {
            [pageOperation setQueuePriority:NSOperationQueuePriorityHigh];
        }
        else {
            [pageOperation setQueuePriority:NSOperationQueuePriorityNormal];
        }
    }
    
    //remove low priority operations if queue reached maximum number of operations.
    [self cancelOldOperations];
}

- (void) addOperation:(NSString*)page
        dataInterface:(PxePlayerDataInterface*) dataInterface
            authToken:(NSString *)authToken
               userId:(NSString *)userId
{
    DLog(@"page: %@", page);
    //add a new operation with high priority
    if(page)
    {
        PxePlayerPagesQuery *query = [[PxePlayerPagesQuery alloc] init];
        [query setAuthToken:authToken];
        [query setUserUUID:userId];
        [query setPageUrl:page];
    
        PxePlayerPageOperation *pageOperation = [[PxePlayerPageOperation alloc] initWithQuery:query
                                                                                dataInterface:dataInterface];
        [pageOperation setPageDelegate:self];
        [pageOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [self.downloadQueue addOperation:pageOperation];
        [self.operations setObject:pageOperation forKey:page];
    }
    else {
        //TODO :: throw error
    }
}

-(BOOL)setOperationPriority:(NSString*)key priority:(NSInteger)priority
{
    NSOperation *operation = [self.operations objectForKey:key];
    if(operation) {
        [operation setQueuePriority:priority];        
        return YES;
    }
    return NO;
}

-(BOOL)isOperationFound:(NSString*)key
{
    NSOperation *operation = [self.operations objectForKey:key];
    if(operation){
        return YES;
    }    
    return NO;
}

-(BOOL)cancelOperation:(NSString*)key
{
    NSOperation *operation = [self.operations objectForKey:key];
    
    if(operation)
    {
        if([operation isExecuting]) {
            [operation cancel];
        }
        
        [self.operations removeObjectForKey:key];
        
        return YES;
    }
    
    return NO;
}

-(void)cancelOldOperations
{
    NSArray *operations = [self.operations allKeys];
    if([operations count] >= MAX_OPERATION)
    {
        //remove the old operations with low priorities
        for (short i = 0; i < MAX_OPERATION; i++)
        {
            NSString *key = [operations objectAtIndex:i];
            NSOperation *operation = [self.operations objectForKey:key];
            if(operation.queuePriority == NSOperationQueuePriorityLow)
            {
                if([operation isExecuting]) {
                    [operation cancel];
                }
                
                [self.operations removeObjectForKey:key];
            }
        }
    }
}

-(void)cancelAllOperations
{
    [self.downloadQueue cancelAllOperations];
    [self.operations removeAllObjects];
}

-(void)suspendAllOperations
{
    [self.downloadQueue setSuspended:YES];
}

-(void)resumeAllOperations
{
    [self.downloadQueue setSuspended:NO];
}

#pragma mark - Pageoperation delegate methods

-(void)operationSuccess:(NSString *)key
{
    DLog(@"KEY: %@", key);
    //remove the operation from the queue if successfully downloaded
    [self cancelOperation:key];
    
    if([[self delegate] respondsToSelector:@selector(OperationFinished:)]) {
        [[self delegate] OperationFinished:key];
    }
}

-(void)operationFailed:(NSString *)key error:(NSError *)error {
    [self cancelOperation:key];
}

@end
