//
//  IMGDataTool.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/31.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGPhotoManager.h"
#import "IMGPickerConstant.h"
#import "PHAssetCollection+Category.h"
#import <AVFoundation/AVFoundation.h>

static IMGPhotoManager *_shareManager = nil;

@interface IMGPhotoManager()

@end

@implementation IMGPhotoManager

+ (instancetype)shareManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [[[self class] alloc] init];
    });
    return _shareManager;
}

+ (NSArray<PHAssetCollection *> *)fetchAssetCollectionsForMediaType:(IMGAssetMediaType)mediaType {
    
    PHFetchOptions *options = [self defaultFetchOptions];
    //按创建时间逆序
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES]];

    NSMutableArray<PHAssetCollection *> *tempAssetCollections = [NSMutableArray array];
    
    // 相机胶卷
    PHFetchResult<PHAssetCollection *> *cameraResults = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options];
    [cameraResults enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetCollectionSubtype!=1000000201 && [self fetchAssetsForMediaType:mediaType inAssetColelction:obj].count) {
//            NSLog(@"%@:%ld",obj.localizedTitle,(long)obj.assetCount);
            [tempAssetCollections addObject:obj];
        }
    }];
    
    // 我的相册
    PHFetchResult<PHAssetCollection *> *userLibrary = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:options];
    [userLibrary enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self fetchAssetsForMediaType:mediaType inAssetColelction:obj].count) {
//            NSLog(@"%@:%ld",obj.localizedTitle,(long)obj.assetCount);
            [tempAssetCollections addObject:obj];
        }
    }];
    
    [tempAssetCollections sortUsingComparator:^NSComparisonResult(PHAssetCollection  *obj1, PHAssetCollection *obj2) {
        return obj1.assetCount<obj2.assetCount;
    }];
    return tempAssetCollections.copy;
}

+ (NSArray<PHAsset *> *)fetchAssetsForMediaType:(IMGAssetMediaType)mediaType
                         inAssetColelction:(PHAssetCollection *)collection
{
    PHFetchOptions *options = [self defaultFetchOptions];
    //按创建时间逆序
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",mediaType];
    
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    NSMutableArray *results = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [results addObject:obj];
    }];
    
    collection.assetCount = fetchResult.count;
    
    return results.copy;
}

+ (void)cacheImageForAsset:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSzie
{
    [(PHCachingImageManager *)[PHCachingImageManager defaultManager] startCachingImagesForAssets:assets targetSize:targetSzie contentMode:PHImageContentModeAspectFill options:[self defaultImageRequestOPtions]];
}

#pragma mark - request imageData
+ (void)requestImageForAsset:(PHAsset *)asset
              targetSize:(CGSize)targetSize
             handler:(void(^)(UIImage *image,IMGImageType imageType))handler
{
    [self requestImageForAsset:asset targetSize:targetSize synchronous:YES handler:handler];
}

+ (void)requestImageForAsset:(PHAsset *)asset
                  targetSize:(CGSize)targetSize
                 synchronous:(BOOL)synchronous
                     handler:(void(^)(UIImage *image,IMGImageType imageType))handler
{
    PHImageRequestOptions *options = [self defaultImageRequestOPtions];
    options.synchronous = synchronous;
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (handler) {
            IMGImageType imageType = IMGImageTypeDefault;
            
            NSString *typeIdentifier = [asset valueForKey:@"uniformTypeIdentifier"];
//            NSLog(@"%@",typeIdentifier);
            if ([typeIdentifier isEqualToString:@"com.compuserve.gif"]) {
                imageType = IMGImageTypeGif;
            }
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_1
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            
            else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                imageType = IMGImageTypeLivePhoto;
            }
            
#pragma clang diagnostic pop
#endif
            handler(result,imageType);
        }
    }];
}

+ (void)requestImageDataForAsset:(PHAsset *)asset
                     handler:(void(^)(NSData *imageData,IMGImageType imageType))handler
{
    [self requestImageDataForAsset:asset synchronous:NO handler:handler];
}

+ (void)requestImageDataForAsset:(PHAsset *)asset
                 synchronous:(BOOL)synchronous
                     handler:(void(^)(NSData *imageData,IMGImageType imageType))handler
{
    PHImageRequestOptions *options = [self defaultImageRequestOPtions];
    options.synchronous = synchronous;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset  options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (handler) {
            IMGImageType imageType = IMGImageTypeDefault;
            if ([dataUTI isEqualToString:@"com.compuserve.gif"]) {
                imageType = IMGImageTypeGif;
            }
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_1
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            
            else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                imageType = IMGImageTypeLivePhoto;
            }
            
#pragma clang diagnostic pop
#endif
            handler(imageData,imageType);
        }
    }];
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_1
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

#pragma mark LivePhoto
+ (void)requestLivePhotoForAsset:(PHAsset *)asset targetSize:(CGSize)size handler:(void(^)(PHLivePhoto * livePhoto))handler
{
    PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        handler(livePhoto);
    }];
}

#pragma clang diagnostic pop
#endif


#pragma mark request video
+ (void)requestPlayerItemForVideo:(PHAsset *)asset handler:(void(^)(AVPlayerItem *playerItem))handler
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        handler(playerItem);
    }];
}

+ (void)requestAVAssetForVideo:(PHAsset *)asset handler:(void(^)(AVAsset *asset))handler
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        handler(asset);
    }];
}



#pragma mark - private
+ (PHImageRequestOptions *)defaultImageRequestOPtions
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    return options;
}

+ (PHFetchOptions *)defaultFetchOptions
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_1
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    
    options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    
#pragma clang diagnostic pop
#endif
    return options;
}

@end
