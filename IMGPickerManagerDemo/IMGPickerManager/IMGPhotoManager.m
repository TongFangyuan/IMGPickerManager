//
//  IMGDataTool.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/31.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGPhotoManager.h"
#import "PHAssetCollection+Category.h"
#import <AVFoundation/AVFoundation.h>

@interface IMGPhotoManager()

@property (nonatomic, weak) PHImageManager *imageManager;

@end

@implementation IMGPhotoManager

+ (nonnull instancetype)shareManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}


- (instancetype)init{
    if (self=[super init]) {
        _requestOtions = [IMGRequestOptions shareOptions];
        _imageManager = [PHImageManager defaultManager];
    }
    return self;
}


#pragma mark - fetch Ops

- (void)loadImageWithAsset:(PHAsset *_Nullable)asset
                targetSize:(CGSize)targetSize
                      mode:(PHImageContentMode)mode
                completion:(IMGFetchCompletionBlock _Nullable)completion {
    
    [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:mode options:self.requestOtions.imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            completion(result,info);
        }
    }];
    
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
    if (mediaType==IMGAssetMediaTypeAll) {
//        NSLog(@"options.predicate: %@",options.predicate);
    } else {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",mediaType];
//        NSLog(@"options.predicate: %@",options.predicate);
    }
        
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    NSMutableArray *results = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![IMGConfigManager shareManager].allowGif) {
            NSString *typeIdentifier = [obj valueForKey:@"uniformTypeIdentifier"];
            if (![typeIdentifier isEqualToString:@"com.compuserve.gif"]){
                [results addObject:obj];
            } else {
                NSLog(@"Filter out the GIF images.");
            }
        } else {
            [results addObject:obj];
        }
    }];
    
    collection.assetCount = fetchResult.count;
    
    return results.copy;
}

+ (void)cacheImageForAsset:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSzie
{
    [(PHCachingImageManager *)[PHCachingImageManager defaultManager] startCachingImagesForAssets:assets targetSize:targetSzie contentMode:PHImageContentModeAspectFill options:[self defaultImageRequestOPtions]];
}

+ (IMGMediaType)getMediaTypeForAsset:(PHAsset *)asset{
    
    if (@available(iOS 9.1, *)) {
        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
            return IMGMediaTypeLivePhoto;
        }
    }


    if (asset.mediaType==PHAssetMediaTypeVideo) {
        return IMGMediaTypeVideo;
    }
    
    IMGMediaType mediaType = IMGMediaTypeImage;
    
    NSString *typeIdentifier = [asset valueForKey:@"uniformTypeIdentifier"];
    if (asset.mediaType==PHAssetMediaTypeImage) {
        mediaType = IMGMediaTypeImage;
        if ([typeIdentifier isEqualToString:@"com.compuserve.gif"]) {
            mediaType = IMGMediaTypeGif;
        }
    }
    
    if (mediaType==IMGMediaTypeUnknow) {
        NSLog(@"----------------[IMGMediaTypeUnknow] typeIdentifier is %@",typeIdentifier);
    }
    return mediaType;
}

+ (void)requestDataForAsset:(PHAsset *)asset handler:(void(^)(NSData *mediaData, IMGMediaType mediaType))handler
{
    IMGMediaType mediaType = [IMGPhotoManager getMediaTypeForAsset:asset];
    if (mediaType==IMGMediaTypeImage || mediaType==IMGMediaTypeGif || mediaType==IMGMediaTypeLivePhoto) {
        [IMGPhotoManager requestImageDataForAsset:asset synchronous:YES handler:^(NSData *imageData, IMGMediaType imageType) {
            handler(imageData,imageType);
        }];
    } else if(mediaType==IMGMediaTypeVideo ) {
        [IMGPhotoManager requestAVAssetForVideo:asset handler:^(AVAsset *avsset) {
            NSData *data = [NSData dataWithContentsOfURL:[avsset valueForKey:@"URL"]];
            handler(data,mediaType);
        }];
    }
}

#pragma mark - request imageData
+ (void)requestImageForAsset:(PHAsset *)asset
              targetSize:(CGSize)targetSize
             handler:(void(^)(UIImage *image,IMGMediaType imageType))handler
{
    [self requestImageForAsset:asset targetSize:targetSize synchronous:YES handler:handler];
}

+ (void)requestImageForAsset:(PHAsset *)asset
                  targetSize:(CGSize)targetSize
                 synchronous:(BOOL)synchronous
                     handler:(void(^)(UIImage *image,IMGMediaType imageType))handler
{
    PHImageRequestOptions *options = [self defaultImageRequestOPtions];
    options.synchronous = synchronous;
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (handler) {
            handler(result,[IMGPhotoManager getMediaTypeForAsset:asset]);
        }
    }];
}

+ (void)requestImageDataForAsset:(PHAsset *)asset
                     handler:(void(^)(NSData *imageData,IMGMediaType imageType))handler
{
    [self requestImageDataForAsset:asset synchronous:NO handler:handler];
}

+ (void)requestImageDataForAsset:(PHAsset *)asset
                 synchronous:(BOOL)synchronous
                     handler:(void(^)(NSData *imageData,IMGMediaType imageType))handler
{
    PHImageRequestOptions *options = [self defaultImageRequestOPtions];
    options.synchronous = synchronous;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset  options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (handler) {
            handler(imageData,[self getMediaTypeForAsset:asset]);
        }
    }];
}


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
    if (@available(iOS 9.0, *)) {
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    }
    return options;
}

@end
