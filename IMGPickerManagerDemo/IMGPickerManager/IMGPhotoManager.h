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
#import "IMGRequestOptions.h"


typedef void(^IMGFetchCompletionBlock)(UIImage *__nullable result, NSDictionary *__nullable info);

typedef enum : NSInteger {
    IMGMediaTypeUnknow,
    IMGMediaTypeImage,
    IMGMediaTypeGif,
    IMGMediaTypeLivePhoto,
    IMGMediaTypeVideo
} IMGMediaType;

@interface IMGPhotoManager : NSObject

@property (nonatomic, weak, readonly) IMGRequestOptions * _Nullable requestOtions;


+ (nonnull instancetype)shareManager;


#pragma mark - fetch Ops

- (void)loadImageWithAsset:(PHAsset *_Nullable)asset
                targetSize:(CGSize)targetSize
                      mode:(PHImageContentMode)mode
                completion:(IMGFetchCompletionBlock _Nullable)completion;


/// Get all AssetCollections for the mediaType
+ (NSArray<PHAssetCollection *> *)fetchAssetCollectionsForMediaType:(IMGAssetMediaType)mediaType;

/// Get PHAssets in a PHAssetCollection for the mediaType
+ (NSArray<PHAsset *> *)fetchAssetsForMediaType:(IMGAssetMediaType)mediaType
                         inAssetColelction:(PHAssetCollection *)collection;

/// Cache images for target size
+ (void)cacheImageForAsset:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSzie;

+ (IMGMediaType)getMediaTypeForAsset:(PHAsset *)asset;



#pragma mark - Request Data

//MARK: MediaData
+ (void)requestDataForAsset:(PHAsset *)asset
                    handler:(void(^)(NSData *mediaData, IMGMediaType mediaType))handler;

//MARK: Image
+ (void)requestImageForAsset:(PHAsset *)asset
                  targetSize:(CGSize)targetSize
                 handler:(void(^)(UIImage *image,IMGMediaType imageType))handler;

/// 任意线程调用,handler在主线程回调
+ (void)requestImageDataForAsset:(PHAsset *)asset
                     handler:(void(^)(NSData *imageData,IMGMediaType imageType))handler;

/// synchronous:是否同步调用 handler在主线程回调
+ (void)requestImageDataForAsset:(PHAsset *)asset
                 synchronous:(BOOL)synchronous
                     handler:(void(^)(NSData *imageData,IMGMediaType imageType))handler;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

//MARK: LivePhoto
+ (void)requestLivePhotoForAsset:(PHAsset *)asset
                      targetSize:(CGSize)size
                         handler:(void(^)(PHLivePhoto * livePhoto))handler;


#pragma clang diagnostic pop

//MARK:  Video
+ (void)requestPlayerItemForVideo:(PHAsset *)asset handler:(void(^)(AVPlayerItem *playerItem))handler;

+ (void)requestAVAssetForVideo:(PHAsset *)asset handler:(void(^)(AVAsset *avsset))handler;

@end
