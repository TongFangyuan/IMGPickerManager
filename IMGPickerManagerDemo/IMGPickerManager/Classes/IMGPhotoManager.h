//
//  IMGDataTool.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/31.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "IMGConfigManager.h"

typedef enum : NSInteger {
    IMGImageTypeDefault,
    IMGImageTypeGif,
    IMGImageTypeLivePhoto
} IMGImageType;

@interface IMGPhotoManager : NSObject

+ (instancetype)shareManager;

/// 获取所有相册
+ (NSArray<PHAssetCollection *> *)fetchAssetCollectionsForMediaType:(IMGAssetMediaType)mediaType;

/// 获取某个相册下类型为mediaType的PHAsset
+ (NSArray<PHAsset *> *)fetchAssetsForMediaType:(IMGAssetMediaType)mediaType
                         inAssetColelction:(PHAssetCollection *)collection;

/// 缓存图片
+ (void)cacheImageForAsset:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSzie;

#pragma mark - request image
+ (void)requestImageForAsset:(PHAsset *)asset
                  targetSize:(CGSize)targetSize
                 handler:(void(^)(UIImage *image,IMGImageType imageType))handler;

/// 任意线程调用,handler在主线程回调
+ (void)requestImageDataForAsset:(PHAsset *)asset
                     handler:(void(^)(NSData *imageData,IMGImageType imageType))handler;

/// synchronous:是否同步调用 handler在主线程回调
+ (void)requestImageDataForAsset:(PHAsset *)asset
                 synchronous:(BOOL)synchronous
                     handler:(void(^)(NSData *imageData,IMGImageType imageType))handler;

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_1
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

#pragma mark - request LivePhoto
+ (void)requestLivePhotoForAsset:(PHAsset *)asset
                      targetSize:(CGSize)size
                         handler:(void(^)(PHLivePhoto * livePhoto))handler;


#pragma clang diagnostic pop
#endif

#pragma mark - requset video
//TODO: 获取视频
+ (void)requestPlayerItemForVideo:(PHAsset *)asset handler:(void(^)(AVPlayerItem *playerItem))handler;

+ (void)requestAVAssetForVideo:(PHAsset *)asset handler:(void(^)(AVAsset *avsset))handler;

@end
