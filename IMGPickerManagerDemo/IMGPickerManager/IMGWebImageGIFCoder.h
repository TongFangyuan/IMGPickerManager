//
//  IMGWebImageGIFCoder.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGWebImageCoder.h"

/**
 Built in coder using ImageIO that supports GIF encoding/decoding
 @note `SDWebImageIOCoder` supports GIF but only as static (will use the 1st frame).
 @note Use `SDWebImageGIFCoder` for fully animated GIFs - less performant than `FLAnimatedImage`
 @note If you decide to make all `UIImageView`(including `FLAnimatedImageView`) instance support GIF. You should add this coder to `SDWebImageCodersManager` and make sure that it has a higher priority than `SDWebImageIOCoder`
 @note The recommended approach for animated GIFs is using `FLAnimatedImage`. It's more performant than `UIImageView` for GIF displaying
 */
@interface IMGWebImageGIFCoder : NSObject <IMGWebImageCoder>

+ (nonnull instancetype)shareCoder;

@end
