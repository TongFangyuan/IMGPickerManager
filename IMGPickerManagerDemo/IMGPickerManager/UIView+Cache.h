//
//  UIView+Cache.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMGPhotoManager.h"
#import "PHAsset+contentType.h"

typedef void(^IMGSetImageBlock)(UIImage * _Nullable image, NSData * _Nullable imageData);

@interface UIView (Cache)


/**
 * Set the imageView `image` with an `phasset` and optionally a placeholder image.
 *
 * The operation is asynchronous and cached
 *
 *
 * @param asset the asset for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @param completedBlock A block called when operation has been completed.
 */
- (void)img_localSetImageWithAsset:(nullable PHAsset *)asset
                  placeholderImage:(nullable UIImage *)placeholder
                        targetSize:(CGSize)targetSize
                              mode:(PHImageContentMode)mode
                     setImageBlock:(nullable IMGSetImageBlock)setImageBlock
                         completed:(nullable IMGFetchCompletionBlock)completedBlock;


@end
