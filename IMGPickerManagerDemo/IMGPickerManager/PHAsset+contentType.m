//
//  PHAsset+contentType.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "PHAsset+contentType.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation PHAsset (contentType)

+ (IMGAssetFormat)img_assetFormatForAsset:(PHAsset *)asset
{
    if (!asset) {
        return IMGAssetFormatUndefined;
    }
    
    if (asset.mediaType==PHAssetMediaTypeVideo) {
        return IMGAssetFormatVideo;
    }
    
    if (@available(iOS 9.1, *)) {
        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
            return IMGAssetFormatLivePhoto;
        }
    }
    
    NSString *uniformTypeIdentifier = [asset valueForKey:@"uniformTypeIdentifier"];
    if ([uniformTypeIdentifier isEqualToString:(NSString *)kUTTypeGIF]) {
        return IMGAssetFormatGIF;
    } else {
//        NSLog(@"%@",uniformTypeIdentifier);
    }
    
    return IMGAssetFormatPNG;
}

@end
