//
//  PxePlayerPageDownload.h
//  PxePlayerApi
//
//  Created by Saro Bear on 18/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import "PxePlayerDataInterface.h"

#pragma mark - Delegate

/**
 A Protocol which send's the instructions while parsing to the class which implemented it
 @Extension <NSObject>, extented from NSObject
 */
@protocol PxePlayerOperationDelegate <NSObject>

/**
 This method would be called when given operation has been successfull executed
 @param NSString, key to identify the operation in the queue
 */
-(void)operationSuccess:(NSString*)key;

/**
 This method would be called when given operation has been failed
 @param NSString, key to identify the operation in the queue
 @param NSError, returns cause of error
 */
-(void)operationFailed:(NSString*)key error:(NSError*)error;

@end




#pragma mark - Class

@class PxePlayerPagesQuery;

/**
 A simple class derived from the NSOperation to perform operation in the operation queue
 */
@interface PxePlayerPageOperation : NSOperation {
}

/**
 A PxePlayerOperationDelegate protocol instance to send information to class which implements it
 */
@property (nonatomic, weak) id <PxePlayerOperationDelegate> pageDelegate;

/**
 This method would be called to initialise the operation with required query parameters
 @param PxePlayerPagesQuery, query is a model instance contains required page information to downlaod page data from the server
 */
- (id) initWithQuery:(PxePlayerPagesQuery*)query
       dataInterface:(PxePlayerDataInterface*)dataInterface;

/**
 This method would be called to retrive the operation key
 @return NSString, returns the identification key 
 */
-(NSString*)getKey;

@end
