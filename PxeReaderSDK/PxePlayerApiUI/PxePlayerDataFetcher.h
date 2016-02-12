//
//  PxePlayerDataFetcher.h
//  PxeReader
//
//  Created by Tomack, Barry on 8/18/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerDataInterface.h"
#import "PxePlayerBookmarks.h"
#import "PxePlayerAnnotationsTypes.h"

@interface PxePlayerDataFetcher : NSObject

- (instancetype) initWithDataInterface:(PxePlayerDataInterface *)dataInterface;

- (void) fetchDataWithCompletionHandler:(void (^)(BOOL success, NSError *error))handler;

- (void) fetchBookmarksWithCompletionHandler:(void (^)(PxePlayerBookmarks*, NSError*))handler;

- (void) fetchGlossaryWithCompletionHandler:(void (^)(NSArray*, NSError*))handler;

- (void) fetchAnnotationsWithCompletionHandler:(void (^)(PxePlayerAnnotationsTypes *, NSError *))handler;

@end
