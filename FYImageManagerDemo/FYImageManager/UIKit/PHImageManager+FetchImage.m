//
//  PHImageManager+FetchImage.m
//  FYImageManagerDemo
//
//  Created by admin on 2018/3/9.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import "PHImageManager+FetchImage.h"

@implementation PHImageManager (FetchImage)

+ (void)fetchImageForAsset:(PHAsset *)asset handler:(void(^)(NSData *imageData,NSDictionary *info))handler{

    if (@available(iOS 11.0, *)) {
        NSLog(@"%ld",(long)asset.playbackStyle);
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset  options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        if (handler) {
            handler(imageData,info);
        }
        
    }];
}
@end
