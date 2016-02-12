//
//  PxePlayerGoogleAnalyticsManager.m
//  PxeReader
//
//  Created by Tomack, Barry on 1/20/16.
//  Copyright © 2016 Pearson. All rights reserved.
//

#import "PxePlayerGoogleAnalyticsManager.h"
#import "PxePlayer.h"
#import "PXEPlayerMacro.h"

@interface PxePlayerGoogleAnalyticsManager()

@property (nonatomic, strong) NSMutableDictionary *trackers;

@end


@implementation PxePlayerGoogleAnalyticsManager

- (void) addTrackerId:(NSString*)trackerId forKey:(NSString*)key
{
    if(!self.trackers)
    {
        self.trackers = [NSMutableDictionary new];
    }
    [self.trackers setObject:trackerId forKey:key];
}

- (NSString*) getTrackingIdForKey:(NSString*)key
{
    return [self.trackers objectForKey:key];
}

- (void) dispatchGAIEventWithCategory:(NSString*)category
                               action:(NSString*)action
                                label:(NSString*)label
                                value:(NSNumber*)value
                        forTrackerKey:(NSString*)trackerKey
{
    NSMutableDictionary *gaEvent = [[GAIDictionaryBuilder createEventWithCategory:category
                                                                           action:action
                                                                            label:label
                                                                            value:value] build];
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:[self getTrackingIdForKey:trackerKey]];
    
    [tracker send:gaEvent];
    [[GAI sharedInstance] dispatch];
}

- (void) dispatchGAIScreenEventForPage:(NSString*)pageURL
                         forTrackerKey:(NSString*)trackerKey
{
    if (pageURL)
    {
        // PAGE VIEW EVENT FOR GOOGLE TRACKER
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:[self getTrackingIdForKey:trackerKey]];
        [tracker set:kGAIScreenName value:pageURL];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
}

@end
