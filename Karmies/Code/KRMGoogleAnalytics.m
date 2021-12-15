//
//  KRMGoogleAnalytics.m
//  Karmies
//
//  Created by Robert Nelson on 23/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

#import "KRMGoogleAnalytics.h"

#import "GA/GAI.h"
#import "GA/GAITracker.h"
#import "GA/GAIDictionaryBuilder.h"
#import "GA/GAIFields.h"


@interface KRMGoogleAnalytics ()
{
    NSString* _trackingID;
}

@property (readonly) id<GAITracker> tracker;

@end


@implementation KRMGoogleAnalytics

- (instancetype)initWithTrackingID:(NSString *)trackingID defaultDimensions:(KRMDimensionDictionary *_Nullable)dimensions
{
    if (self = [super init]) {
        _trackingID = trackingID;
        
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:_trackingID];
        if ([tracker get:kGAIClientId] == nil) {
            [tracker set:kGAIClientId value:[[NSUUID UUID] UUIDString]];
        }
        [dimensions enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, NSString *value, BOOL *stop) {
            [tracker set:[GAIFields customDimensionForIndex:index.unsignedIntegerValue] value:value];
        }];
    }
    return self;
}

- (id<GAITracker>)tracker
{
    return [[GAI sharedInstance] trackerWithTrackingId:_trackingID];
}

- (NSString *)clientID
{
    return [self.tracker get:kGAIClientId];
}

- (void)sendEventWithCategory:(NSString *_Nonnull)category action:(NSString *_Nonnull)action dimensions:(NSDictionary<NSNumber *, NSString *> *_Nullable)dimensions metrics:(NSDictionary<NSNumber *, NSNumber *> *_Nullable)metrics;
{
    GAIDictionaryBuilder *eventBuilder = [GAIDictionaryBuilder createEventWithCategory:category action:action label:nil value:nil];
    [dimensions enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL *stop) {
        [eventBuilder set:obj forKey:[GAIFields customDimensionForIndex:key.unsignedIntegerValue]];
    }];
    [metrics enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *obj, BOOL *stop) {
        [eventBuilder set:obj.stringValue forKey:[GAIFields customMetricForIndex:key.unsignedIntegerValue]];
    }];
    [self.tracker send:[eventBuilder build]];
}

+ (void)setup
{
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;
    gai.logger.logLevel = kGAILogLevelVerbose;
    gai.dispatchInterval = 5;
}

@end
