//
//  BlueManageUtils.m
//  pc300_health_sdk
//
//  Created by axun on 2020/11/19.
//

#import "BlueManageUtils.h"

@implementation BlueManageUtils

+ (instancetype)shareEngine
{
    static BlueManageUtils *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[[self class] alloc] init];
    });
    return _sharedEngine;
}

@end
