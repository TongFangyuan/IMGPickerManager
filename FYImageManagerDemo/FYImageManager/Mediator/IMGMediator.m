//
//  IMGMediator.m
//  FYImageManagerDemo
//
//  Created by 童方园 on 2018/3/30.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import "IMGMediator.h"

static IMGMediator *_shareInstance=nil;

@interface IMGMediator()

@end

@implementation IMGMediator

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

@end
