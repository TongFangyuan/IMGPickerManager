//
//  PHAsset+IMGProperty.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/30.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "PHAsset+IMGProperty.h"
#import <objc/runtime.h>

static NSString *selectWithSetterGetterKey = @"selectWithSetterGetterKey";
static NSString *overflowWithSetterGetterKey = @"overflowWithSetterGetterKey";


@implementation PHAsset (IMGProperty)

@dynamic select;
- (void)setSelect:(BOOL)select {
    objc_setAssociatedObject(self, &selectWithSetterGetterKey, [NSNumber numberWithBool:select], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)select{
    return [objc_getAssociatedObject(self, &selectWithSetterGetterKey) boolValue];
}

@dynamic overflow;
- (void)setOverflow:(BOOL)overflow {
    objc_setAssociatedObject(self, &overflowWithSetterGetterKey, [NSNumber numberWithBool:overflow], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)overflow {
    return [objc_getAssociatedObject(self, &overflowWithSetterGetterKey) boolValue];
}

@end
