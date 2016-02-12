//
//  PxePlayerPageDownloader.h
//  PxePlayerApi
//
//  Created by Saro Bear on 18/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PxePlayerDataInterface.h"

#pragma mark - Delegates

/**
 A Protocol which send's the instructions while parsing to the class which implemented it
 @Extension <NSObject>, extented from NSObject
 */
@protocol PxePlayerOperationQueueDelegate <NSObject>

@optional

/**
 This method would be called when given operation has been finished
 @param NSString, key to identify the operation in the queue
 */
-(void)OperationFinished:(NSString*)key;

@end

#pragma mark - Classes

/**
 A simple class to manage the operations in the queue
 */
@interface PxePlayerPageOperations : NSObject

/**
 A PxePlayerOperationQueueDelegate protocol instance to send information to class which implements it
 */
@property (nonatomic, weak) id <PxePlayerOperationQueueDelegate> delegate;

/**
 This method would be called to add page download operation into the operation queue
 @param NSString, page that needs to be downloaded 
 @param NSString, authToken is required to attach with query stirng when initiate download data
 @param NSString, userId is required to attach with query stirng when initiate download data
 */
- (void) addOperation:(NSString*)page
        dataInterface:(PxePlayerDataInterface*) dataInterface
            authToken:(NSString *)authToken
               userId:(NSString *)userId;

/**
 This method would be to list of page download operation into the operation queue
 @param NSArray, operations is a list of page details that need to be downloaded from the server 
 @param NSInteger, priorityIndex is a index to set the priority level for the operation
 @param NSString, authToken is required to attach with query stirng when initiate download data
 @param NSString, userId is required to attach with query stirng when initiate download data
 */
- (void) addOperations:(NSArray*)operations
     withPriorityIndex:(NSInteger)priorityIndex
         dataInterface:(PxePlayerDataInterface*)dataInterface
             authToken:(NSString *)authToken
                userId:(NSString *)userId;

/**
 This method would be called to cancel all page download operation in the operation queue
 */
-(void)cancelAllOperations;

/**
 This method would be called to suspend all page download operation in the operation queue
 */
-(void)suspendAllOperations;

/**
This method would be called to resume all suspended page download operation in the operation queue
 */
-(void)resumeAllOperations;

/**
 This method would be called to set the each operation priority level in the operation queue
 @param NSString, key used to identify the operation in the queue 
 @param NSInteger, priority is level of the priority in the queue
 @return BOOL, return yes if operation priority successfully set else return no as a error 
 */
-(BOOL)setOperationPriority:(NSString*)key priority:(NSInteger)priority;

/**
 This method would be called to check whether particular operation found in the queue
 @param NSString, key to identify the operation in the queue
 */
-(BOOL)isOperationFound:(NSString*)key;

/**
 This method would be called to cancel the particular operation in the queue 
 @param NSString, key to identity the operation in the queue 
 @return BOOL, return yes if operation successfully cancelled else return no as a error
 */
-(BOOL)cancelOperation:(NSString*)key;


@end
