//
//  IMGDataTool.m
//  FYImageManagerDemo
//
//  Created by 童方园 on 2018/3/31.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import "IMGDataTool.h"
#import "IMGBlockDefine.h"

@implementation IMGDataTool

+ (NSMutableArray<PHAssetCollection *> *)fetchAssetCollections {
    
    PHFetchOptions *options = [PHFetchOptions new];
    if (IOS9) {
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
    
    NSMutableArray<PHAssetCollection *> *tempAssetCollections = [NSMutableArray array];
    
    // 相机胶卷
    PHFetchResult<PHAssetCollection *> *cameraResults = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:options];
    [cameraResults enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempAssetCollections addObject:obj];
    }];
    
    // 最近添加
    PHFetchResult<PHAssetCollection *> *recentlyAddeds = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:options];
    [recentlyAddeds enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempAssetCollections addObject:obj];
    }];
    
    // 屏幕快照
    if (IOS9) {
        PHFetchResult<PHAssetCollection *> *screenshots = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:options];
        [screenshots enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tempAssetCollections addObject:obj];
        }];
    }
    
    // 我的相册
    PHFetchResult<PHAssetCollection *> *userLibrary = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:options];
    [userLibrary enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempAssetCollections addObject:obj];
    }];
    
    return tempAssetCollections;
}


+ (NSMutableArray<PHAsset *> *)fetchAssetsWithAssetCollection:(PHAssetCollection *)assetCollection {
    PHFetchOptions *options = [PHFetchOptions new];
    if (IOS9) {
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    NSMutableArray<PHAsset *> *resultAssets = [NSMutableArray arrayWithCapacity:result.count];
    [result enumerateObjectsUsingBlock:^(PHAsset  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultAssets addObject:obj];
    }];
    return resultAssets;
}
@end
