//
//  KRMProxyDelegate.h
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

@import Foundation;


@interface KRMProxyDelegate : NSObject

@property (nonatomic, readonly, weak) id _Nullable krm_delegate;

- (instancetype _Nonnull)initWithDelegate:(id _Nullable)delegate;

@end
