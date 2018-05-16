//
//  IMGPickerCompat.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGPickerCompat.h"
#import "UIImage+IMGMultiFormat.h"

inline UIImage *IMGScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    
    if (!image) {
        return nil;
    }
    
    if (image.images.count>0) {
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:IMGScaledImageForKey(key, tempImage)];
        }
        
        UIImage *animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
        if (animatedImage) {
            animatedImage.img_imageLoopCount = image.img_imageLoopCount;
        }
        return animatedImage;
    } else {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGFloat scale = 1;
            if (key.length >= 8) {
                NSRange range = [key rangeOfString:@"@2x."];
                if (range.location != NSNotFound) {
                    scale = 2.0;
                }
                
                range = [key rangeOfString:@"@3x."];
                if (range.location != NSNotFound) {
                    scale = 3.0;
                }
                
                UIImage *scaleImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
                image = scaleImage;
            }
        }
        return image;
    }
}

