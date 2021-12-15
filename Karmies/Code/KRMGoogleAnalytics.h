//
//  KRMGoogleAnalytics.h
//  Karmies
//
//  Created by Robert Nelson on 23/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

@import Foundation;


typedef NSDictionary<NSNumber *, NSString *> KRMDimensionDictionary;
typedef NSDictionary<NSNumber *, NSNumber *> KRMMetricsDictionary;


@interface KRMGoogleAnalytics : NSObject

@property (readonly) NSString *_Nonnull clientID;

- (instancetype _Nonnull)initWithTrackingID:(NSString *_Nonnull)trackerID defaultDimensions:(KRMDimensionDictionary *_Nullable)dimensions;

- (void)sendEventWithCategory:(NSString *_Nonnull)category action:(NSString *_Nonnull)action dimensions:(KRMDimensionDictionary *_Nullable)dimensions metrics:(KRMMetricsDictionary *_Nullable)metrics;

+ (void)setup;

@end
