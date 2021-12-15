//
//  KRMUtils.m
//  Karmies
//
//  Created by Robert Nelson on 23/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

#import "KRMUtls.h"

@import UIKit;


@implementation KRMUtils

+ (void)openURL:(NSURL *)url
{
    typedef void (*OpenURLInstanceMethodType)(UIApplication *, SEL, NSURL *);

    UIApplication *app = [UIApplication sharedApplication];
    OpenURLInstanceMethodType method = (OpenURLInstanceMethodType)[[UIApplication class] instanceMethodForSelector:@selector(openURL:)];
    method(app, @selector(openURL:), url);
}

@end
