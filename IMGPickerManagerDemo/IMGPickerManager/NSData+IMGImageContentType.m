//
//  NSData+IMGImageContentType.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "NSData+IMGImageContentType.h"
#import <MobileCoreServices/MobileCoreServices.h>

// Currently Image/IO does not support WebP
#define kSDUTTypeWebP ((__bridge CFStringRef)@"public.webp")
// AVFileTypeHEIC is defined in AVFoundation via iOS 11, we use this without import AVFoundation
#define kSDUTTypeHEIC ((__bridge CFStringRef)@"public.heic")

@implementation NSData (IMGImageContentType)

+ (IMGImageFormat)img_imageFormatForImageData:(NSData *)data {
    if (!data) {
        return IMGImageFormatUndefined;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return IMGImageFormatJPEG;
        case 0x89:
            return IMGImageFormatPNG;
        case 0x47:
            return IMGImageFormatGIF;
        case 0x49:
        case 0x4D:
            return IMGImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) {
                //RIFF....WEBP
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return IMGImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return IMGImageFormatHEIC;
                }
            }
            break;
        }
    }
    return IMGImageFormatUndefined;
    
}

+ (nonnull CFStringRef)img_UTTypeFromIMGImageFormat:(IMGImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case IMGImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case IMGImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case IMGImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case IMGImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case IMGImageFormatWebP:
            UTType = kSDUTTypeWebP;
            break;
        case IMGImageFormatHEIC:
            UTType = kSDUTTypeHEIC;
            break;
        default:
            // default is kUTTypePNG
            UTType = kUTTypePNG;
            break;
    }
    return UTType;
}

@end
