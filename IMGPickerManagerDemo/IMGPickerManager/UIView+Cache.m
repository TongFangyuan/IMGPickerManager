//
//  UIView+Cache.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "UIView+Cache.h"
#import "IMGPickerCompat.h"

@implementation UIView (Cache)

- (void)img_localSetImageWithAsset:(PHAsset *)asset
                  placeholderImage:(UIImage *)placeholder
                        targetSize:(CGSize)targetSize
                              mode:(PHImageContentMode)mode
                     setImageBlock:(IMGSetImageBlock)setImageBlock
                         completed:(IMGFetchCompletionBlock)completedBlock
{
    if (!asset || ![asset isKindOfClass:[PHAsset class]]) {
        if (completedBlock) {
            completedBlock(nil,nil,nil);
        }
        return;
    }
    
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        if (completedBlock) {
            completedBlock(nil,nil,nil);
        }
        return;
    }

    __weak typeof(self) wSelf = self;
    IMGPhotoManager *manager = [IMGPhotoManager shareManager];
    [manager loadImageWithAsset:asset targetSize:targetSize mode:mode completion:^(UIImage * _Nullable image, NSData * _Nullable imageData, PHAsset * _Nullable asset) {
        
        dispatch_main_async_safe(^{
            [wSelf img_setImage:image imageData:imageData asset:asset setImageBlock:setImageBlock];
            if (completedBlock) {
                completedBlock(image,imageData,asset);
            }
        });
        
    }];
}


- (void)img_setImage:(UIImage *)image imageData:(NSData *)imageData asset:(PHAsset *)asset setImageBlock:(IMGSetImageBlock)setImageBlock
{
    UIView *view = self;
    IMGSetImageBlock finalSetImageBlock;
    if (setImageBlock) {
        finalSetImageBlock = setImageBlock;
    }
    else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, PHAsset *asset){
            imageView.image = setImage;
        };
    }
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, PHAsset *asset){
            [button setImage:setImage forState:UIControlStateNormal];
        };
    }
    
    if (finalSetImageBlock) {
        finalSetImageBlock(image, imageData, asset);
    }
    
}

@end
