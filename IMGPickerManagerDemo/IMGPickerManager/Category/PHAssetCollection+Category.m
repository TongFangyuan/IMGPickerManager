//
//  PHAssetCollection+Category.m
//  IMGPickerManagerDemo
//
//  Created by 童方园 on 2018/4/15.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "PHAssetCollection+Category.h"
#import <objc/runtime.h>

static NSString *kAssetCountKey = @"kAssetCountKey";

@implementation PHAssetCollection (Category)

- (void)setAssetCount:(NSUInteger)assetCount{
    objc_setAssociatedObject(self, &kAssetCountKey, [NSNumber numberWithUnsignedInteger:assetCount], OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)assetCount{
    return [objc_getAssociatedObject(self, &kAssetCountKey) integerValue];
}

@end
