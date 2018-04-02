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

- (NSMutableArray<PHAssetCollection *> *)fetchAssetCollections;

- (NSMutableArray<PHAsset *> *)fetchAssetsWithAssetCollection:(PHAssetCollection *)collection;

@end
