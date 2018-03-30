//
//  IMGDataTool.h
//  FYImageManagerDemo
//
//  Created by 童方园 on 2018/3/31.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface IMGDataTool : NSObject

+ (NSMutableArray<PHAssetCollection *> *)fetchAssetCollections;

+ (NSMutableArray<PHAsset *> *)fetchAssetsWithAssetCollection:(PHAssetCollection *)collection;

@end
