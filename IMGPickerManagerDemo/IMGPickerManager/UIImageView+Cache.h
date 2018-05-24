//
//  UIImageView+Cache.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Cache.h"
#import "IMGPhotoManager.h"

@interface UIImageView (Cache)

- (void)img_setImageWithAsset:(nullable PHAsset *)asset;

- (void)img_setImageWithAsset:(nullable PHAsset *)asset targetSize:(CGSize)targetSize;

- (void)img_setImageWithAsset:(nullable PHAsset *)asset
                   targetSize:(CGSize)targetSize
                    completed:(nullable IMGFetchCompletionBlock)completedBlock;

- (void)img_setImageWithAsset:(nullable PHAsset *)asset
                  placeholderImage:(nullable UIImage *)placeholder
                   targetSize:(CGSize)targetSize
                         mode:(PHImageContentMode)mode
                         completed:(nullable IMGFetchCompletionBlock)completedBlock;

@end
