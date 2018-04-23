//
//  FYImageFlowLayout.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/11.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import "IMGPickerFlowLayout.h"

@implementation IMGPickerFlowLayout

- (instancetype)init
{
    if (self = [super init]) {
        self.minimumLineSpacing = 1;
        self.minimumInteritemSpacing = 1;
        self.itemSize = [self reloadItemSize];
    }
    return self;
}

- (CGSize)reloadItemSize
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGFloat column = 4.0;
    if (UIDeviceOrientationIsLandscape(orientation)){
        column = 6.0;
    }
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat width = (screenSize.width-(column-1))/column;
    return CGSizeMake(width, width);
}

@end
