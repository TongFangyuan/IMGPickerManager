//
//  UIImage+IMGMultiFormat.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "UIImage+IMGMultiFormat.h"
#import <objc/runtime.h>

@implementation UIImage (IMGMultiFormat)

- (NSUInteger)img_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    NSNumber *value = objc_getAssociatedObject(self, @selector(img_imageLoopCount));
    if ([value isKindOfClass:[NSNumber class]]) {
        imageLoopCount = value.unsignedIntegerValue;
    }
    return imageLoopCount;
}

- (void)setImg_imageLoopCount:(NSUInteger)sd_imageLoopCount {
    NSNumber *value = @(sd_imageLoopCount);
    objc_setAssociatedObject(self, @selector(img_imageLoopCount), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
