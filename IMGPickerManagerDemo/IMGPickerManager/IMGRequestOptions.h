//
//  IMGRequestOptions.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/17.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "IMGPickerCompat.h"

@interface IMGRequestOptions : NSObject

@property (nonatomic,strong, nonnull) PHImageRequestOptions * imageOptions;
@property (nonatomic,strong, nonnull) PHVideoRequestOptions * videoOptions;
@property (nonatomic,strong, nullable) PHLivePhotoRequestOptions * livePhotoOptions IMG_AVAILABLE_IOS(9_1);

+ (nonnull instancetype)shareOptions;

@end

