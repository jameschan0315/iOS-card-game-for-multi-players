//
//  KRMProxyDelegate.m
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

#import "KRMProxyDelegate.h"


@implementation KRMProxyDelegate

@synthesize krm_delegate = _krm_delegate;

- (instancetype)initWithDelegate:(id)delegate
{
    if (self = [super init]) {
		_krm_delegate = delegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)selector
{
    return [super respondsToSelector:selector] || [_krm_delegate respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([super respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self];
    }
    else {
        [invocation invokeWithTarget:_krm_delegate];
    }
}

@end
