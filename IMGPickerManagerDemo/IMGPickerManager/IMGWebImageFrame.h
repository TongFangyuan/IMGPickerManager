//
//  IMGWebImageFrame.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGPickerCompat.h"

@interface IMGWebImageFrame : NSObject

// This class is used for creating animated images via `animatedImageWithFrames` in `SDWebImageCoderHelper`. Attention if you need to specify animated images loop count, use `sd_imageLoopCount` property in `UIImage+MultiFormat`.

/**
 The image of current frame. You should not set an animated image.
 */
@property (nonatomic, strong, readonly, nonnull) UIImage *image;
/**
 The duration of current frame to be displayed. The number is seconds but not milliseconds. You should not set this to zero.
 */
@property (nonatomic, readonly, assign) NSTimeInterval duration;

/**
 Create a frame instance with specify image and duration
 
 @param image current frame's image
 @param duration current frame's duration
 @return frame instance
 */
+ (instancetype _Nonnull)frameWithImage:(UIImage * _Nonnull)image duration:(NSTimeInterval)duration;

@end
