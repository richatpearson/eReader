//
//  PxePlayerGoogleAnalyticsManager.h
//  PxeReader
//
//  Created by Tomack, Barry on 1/20/16.
//  Copyright © 2016 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface PxePlayerGoogleAnalyticsManager : NSObject

- (void) addTrackerId:(NSString*)trackerId forKey:(NSString*)key;

- (NSString*) getTrackingIdForKey:(NSString*)key;

- (void) dispatchGAIEventWithCategory:(NSString*)category
                               action:(NSString*)action
                                label:(NSString*)label
                                value:(NSNumber*)value
                        forTrackerKey:(NSString*)trackerKey;

- (void) dispatchGAIScreenEventForPage:(NSString*)pageURL
                         forTrackerKey:(NSString*)trackerKey;

@end
