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


typedef void(^IMGFetchCompletionBlock)(UIImage *__nullable image, NSData *__nullable imageData, PHAsset * __nullable asset);

typedef void(^IMGFetchCollectionsCompletionBlock)(NSArray<PHAssetCollection *> * _Nullable collections);

typedef void(^IMGFetchAssetsCompletionBlock)(NSArray<PHAsset *> * _Nullable assets);

typedef enum : NSInteger {
    IMGMediaTypeUnknow,
    IMGMediaTypeImage,
    IMGMediaTypeGif,
    IMGMediaTypeLivePhoto,
    IMGMediaTypeVideo
} IMGMediaType;

@interface IMGPhotoManager : NSObject

@property (nonatomic, strong, readonly) IMGRequestOptions * _Nullable requestOtions;


+ (nonnull instancetype)shareManager;


#pragma mark - fetch Ops

- (void)loadImageWithAsset:(PHAsset *_Nonnull)asset
                targetSize:(CGSize)targetSize
                      mode:(PHImageContentMode)mode
                completion:(IMGFetchCompletionBlock _Nullable)completion;

- (void)loadCollectionsWithMediaType:(IMGAssetMediaType)mediaType
                          completion:(IMGFetchCollectionsCompletionBlock _Nullable)completion;

/**
 Asynchronous fetch assets

 @param mediaType Target media type
 @param completion Blcok on main queue
 */
- (void)loadAssetsWithMediaType:(IMGAssetMediaType)mediaType
                   inCollection:(PHAssetCollection * _Nonnull)collection
                     completion:(IMGFetchAssetsCompletionBlock _Nullable)completion;

/**
 Synchronous fetch assets

 @param mediaType Target media type
 */
- (NSArray<PHAsset *> *_Nullable)loadAssetsForMediaType:(IMGAssetMediaType)mediaType
                                      inAssetColelction:(PHAssetCollection *_Nonnull)collection;

/// Cache images for target size
+ (void)cacheImageForAsset:(NSArray<PHAsset *> *_Nonnull)assets targetSize:(CGSize)targetSzie;

+ (IMGMediaType)getMediaTypeForAsset:(PHAsset *_Nonnull)asset;



#pragma mark - Request Data

//MARK: MediaData
+ (void)requestDataForAsset:(PHAsset *_Nullable)asset
                    handler:(void(^_Nullable)(NSData * _Nullable mediaData, IMGMediaType mediaType))handler;

//MARK: Image
+ (void)requestImageForAsset:(PHAsset *_Nullable)asset
                  targetSize:(CGSize)targetSize
                     handler:(void(^_Nullable)(UIImage * _Nullable image,IMGMediaType imageType))handler;

/// 任意线程调用,handler在主线程回调
+ (void)requestImageDataForAsset:(PHAsset *_Nonnull)asset
                         handler:(void(^_Nullable)(NSData * _Nullable imageData,IMGMediaType imageType))handler;

/// synchronous:是否同步调用 handler在主线程回调
+ (void)requestImageDataForAsset:(PHAsset *_Nonnull)asset
                 synchronous:(BOOL)synchronous
                         handler:(void(^_Nullable)(NSData * _Nullable imageData,IMGMediaType imageType))handler;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

//MARK: LivePhoto
+ (void)requestLivePhotoForAsset:(PHAsset *_Nonnull)asset
                      targetSize:(CGSize)size
                         handler:(void(^_Nullable)(PHLivePhoto * _Nullable livePhoto))handler;


#pragma clang diagnostic pop

//MARK:  Video
+ (void)requestPlayerItemForVideo:(PHAsset *_Nonnull)asset handler:(void(^_Nullable)(AVPlayerItem * _Nonnull playerItem))handler;

+ (void)requestAVAssetForVideo:(PHAsset * _Nonnull)asset handler:(void(^_Nullable)(AVAsset * _Nullable avsset))handler;

@end
