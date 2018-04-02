//
//  IMGDataTool.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/31.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface IMGPhotoManager : NSObject

+ (instancetype)shareManager;

/// 获取所有相册
- (NSMutableArray<PHAssetCollection *> *)fetchAssetCollections;
/// 获取相册下的所有 PHAsset
- (NSMutableArray<PHAsset *> *)fetchAssetsWithAssetCollection:(PHAssetCollection *)collection;
/// 获取图片
- (void)getImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize resultBlock:(void(^)(UIImage *image))block;
/// 缓存图片
- (void)cacheImageForAsset:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSzie;

@end
