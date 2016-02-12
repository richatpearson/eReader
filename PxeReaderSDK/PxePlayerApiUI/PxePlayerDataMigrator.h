//
//  PxePlayerDataMigrator.h
//  PxeReader
//
//  Created by Tomack, Barry on 11/11/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayer.h"
#import "PxePlayerDataManager.h"

typedef void (^MigrationComplete)(NSString *results, NSError *error);

@interface PxePlayerDataMigrator : NSObject

@property (copy, nonatomic) MigrationComplete onMigrationComplete;

- (void) migrateDataForContext:(NSManagedObjectContext*)objectContext
                    onComplete:(MigrationComplete)migrationComplete;

@end
