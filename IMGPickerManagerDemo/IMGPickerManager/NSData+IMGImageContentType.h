//
//  NSData+IMGImageContentType.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGPickerCompat.h"

typedef NS_ENUM(NSInteger, IMGImageFormat) {
    IMGImageFormatUndefined = -1,
    IMGImageFormatJPEG = 0,
    IMGImageFormatPNG,
    IMGImageFormatGIF,
    IMGImageFormatTIFF,
    IMGImageFormatWebP,
    IMGImageFormatHEIC
};

@interface NSData (IMGImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `IMGImageFormat` (enum)
 */
+ (IMGImageFormat)img_imageFormatForImageData:(nullable NSData *)data;

/**
 Convert IMGImageFormat to UTType
 
 @param format Format as IMGImageFormat
 @return The UTType as CFStringRef
 */
+ (nonnull CFStringRef)img_UTTypeFromIMGImageFormat:(IMGImageFormat)format;

@end
