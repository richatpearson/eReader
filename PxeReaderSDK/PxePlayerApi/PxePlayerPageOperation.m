//
//  PxePlayerPageDownload.m
//  PxePlayerApi
//
//  Created by Saro Bear on 18/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import "PxePlayerPagesQuery.h"
#import "PxePlayerPageOperation.h"
#import "PxePlayerInterface.h"
#import "HMCache.h"
#import "NSString+Extension.h"
#import "PxePlayerDataInterface.h"

@interface PxePlayerPageOperation ()

@property (nonatomic, strong) PxePlayerPagesQuery *query;
@property (nonatomic, strong) PxePlayerDataInterface *dataInterface;

@end

@implementation PxePlayerPageOperation

#pragma mark -
#pragma mark -Life Cycle
- (id) initWithQuery:(PxePlayerPagesQuery*)query
       dataInterface:(PxePlayerDataInterface*)dataInterface
{
    self = [super init];
    if(self){
        self.query = query;
        self.dataInterface = dataInterface;
    }
    
    return self;
}

-(NSString*)getKey {
    return self.query.pageUrl;
}

-(void)main
{
    @autoreleasepool {
        if(self.isCancelled){
            return;
        }
        
        [PxePlayerInterface getTOCPage:self.query
                         dataInterface:self.dataInterface
                     completionHandler:^(PxePlayerPage *page, NSError *error)
        {
            NSLog(@"PageOperation getTOCPage: page: %@", page);
            //if operation cancelled than don't need to perform any further operations
            if (self.isCancelled)
                return;
            
            if(!error)
            {                
                NSData *pageData = (NSData*)[NSKeyedArchiver archivedDataWithRootObject:page];
                NSString *key = [self.query.pageUrl md5];
                if(key)
                {
                    if([self.query.pageUrl rangeOfString:@"quiz"].location == NSNotFound)
                        [HMCache setObject:pageData forKey:key];
                    
                    if([self.pageDelegate respondsToSelector:@selector(operationSuccess:)]){
                        [self.pageDelegate operationSuccess:self.query.pageUrl];
                    }
                }
                else
                {
                    if([[self pageDelegate] respondsToSelector:@selector(operationFailed:error:)]){
                        [[self pageDelegate] operationFailed:self.query.pageUrl error:error];
                    }
                }
            }
            else
            {
                if([[self pageDelegate] respondsToSelector:@selector(operationFailed:error:)]){
                    [[self pageDelegate] operationFailed:self.query.pageUrl error:error];
                }
            }
        }];
    }
}

@end
