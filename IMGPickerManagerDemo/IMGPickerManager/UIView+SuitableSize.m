//
//  UIView+SuitableSize.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/4/24.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "UIView+SuitableSize.h"

@implementation UIView (SuitableSize)

+ (CGSize)fitSize:(CGSize)originalSize toSize:(CGSize)fitSize
{
    
    CGSize resultSize = CGSizeMake(originalSize.width, originalSize.height);
    
    while (resultSize.width>fitSize.width || resultSize.height>fitSize.height) {
        
        if (resultSize.width>fitSize.width) {
            resultSize.width = fitSize.width;
            resultSize.height = originalSize.height/originalSize.width * resultSize.width;
        }
        if (resultSize.height>fitSize.height) {
            resultSize.height = fitSize.height;
            resultSize.width = originalSize.width/originalSize.height * resultSize.height;
        }
    }
    
    if (resultSize.width<fitSize.width && resultSize.height<fitSize.height) {
        if (fitSize.width>fitSize.height) {
            resultSize.height = fitSize.height;
            resultSize.width = originalSize.width/originalSize.height * resultSize.height;
        } else {
            resultSize.width = fitSize.width;
            resultSize.height = originalSize.height/originalSize.width * resultSize.width;
        }
    }
    
    return resultSize;
}

@end
