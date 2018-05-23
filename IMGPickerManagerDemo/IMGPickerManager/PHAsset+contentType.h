//
//  PHAsset+contentType.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, IMGAssetFormat) {
    IMGAssetFormatUndefined = -1,
    IMGAssetFormatPNG,
    IMGAssetFormatGIF,
    IMGAssetFormatHEIC,
    IMGAssetFormatVideo,
    IMGAssetFormatLivePhoto,
};

@interface PHAsset (contentType)

+ (IMGAssetFormat)img_assetFormatForAsset:(PHAsset *)asset;

@end
