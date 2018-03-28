//
//  IMGConfiguration.m
//  FYImageManagerDemo
//
//  Created by admin on 2018/3/28.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import "IMGConfiguration.h"

static IMGConfiguration *_sharedInstance = nil;

@implementation IMGConfiguration

+ (IMGConfiguration *) sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _maxCount = 9;
    }
    return self;
}

@end
