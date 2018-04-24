//
//  UIView+SuitableSize.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/4/24.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SuitableSize)
+ (CGSize)fitSize:(CGSize)originalSize toSize:(CGSize)fitSize;
@end
