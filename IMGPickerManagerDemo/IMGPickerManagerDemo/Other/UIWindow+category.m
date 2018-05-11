//
//  UIWindow+category.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "UIWindow+category.h"
#import "YYFPSLabel.h"
#import <objc/runtime.h>

@implementation UIWindow (category)

- (void)addSubview:(UIView *)view {
    
    NSLog(@"%@",view);
    
    if (!self.fpsLabel) {
        self.fpsLabel = [YYFPSLabel new];
        [self.fpsLabel sizeToFit];
        CGFloat fpsHeight = self.fpsLabel.frame.size.height;
        self.fpsLabel.frame = CGRectMake(20, self.frame.size.height-fpsHeight-10, self.fpsLabel.frame.size.width, fpsHeight);
        [self insertSubview:self.fpsLabel atIndex:self.subviews.count];
    }
    
    if (self.fpsLabel && view!=self.fpsLabel) {
        [self insertSubview:view belowSubview:self.fpsLabel];
        return;
    }
    
    [super addSubview:view];
}


- (void)setFpsLabel:(YYFPSLabel *)fpsLabel{
    objc_setAssociatedObject(self, _cmd, fpsLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YYFPSLabel *)fpsLabel
{
    return objc_getAssociatedObject(self, @selector(setFpsLabel:));
}

@end
