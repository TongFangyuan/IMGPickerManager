//
//  IMGWebImageFrame.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGWebImageFrame.h"

@interface IMGWebImageFrame ()

@property (nonatomic, strong, readwrite, nonnull) UIImage *image;
@property (nonatomic, readwrite, assign) NSTimeInterval duration;

@end

@implementation IMGWebImageFrame

+ (instancetype)frameWithImage:(UIImage *)image duration:(NSTimeInterval)duration {
    IMGWebImageFrame *frame = [[IMGWebImageFrame alloc] init];
    frame.image = image;
    frame.duration = duration;
    return frame;
}

@end
