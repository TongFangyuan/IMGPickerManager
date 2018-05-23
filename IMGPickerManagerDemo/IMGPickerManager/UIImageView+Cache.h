//
//  UIImageView+Cache.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PHAsset+contentType.h"

@interface UIImageView (Cache)

- (void)img_setImageWithAsset:(nullable PHAsset *)asset;

- (void)img_setImageWithAsset:(nullable PHAsset *)asset targetSize:(CGSize)targetSize;

- (void)img_setImageWithAsset:(PHAsset *)asset
                   targetSize:(CGSize)targetSize
                    completed:(nullable void(^)(UIImage * _Nullable image,  NSData * _Nullable imageData,  NSDictionary * _Nullable info))completedBlock;
;

- (void)img_setImageWithAsset:(nullable PHAsset *)asset
                  placeholderImage:(nullable UIImage *)placeholder
                   targetSize:(CGSize)targetSize
                         mode:(PHImageContentMode)mode
                         completed:(nullable void(^)(UIImage * _Nullable image,  NSData * _Nullable imageData,  NSDictionary * _Nullable info))completedBlock;

@end
