//
//  PHImageManager+FetchImage.h
//  FYImageManagerDemo
//
//  Created by admin on 2018/3/9.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHImageManager (FetchImage)

+ (void)fetchImageForAsset:(PHAsset *)asset handler:(void(^)(NSData *imageData,NSDictionary *info))handler;

@end
