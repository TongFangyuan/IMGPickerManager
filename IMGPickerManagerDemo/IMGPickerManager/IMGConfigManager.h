//
//  IMGConfiguration.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/28.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, IMGAssetMediaType) {
    IMGAssetMediaTypeUnknown = PHAssetMediaTypeUnknown,
    IMGAssetMediaTypeImage   = PHAssetMediaTypeImage,
    IMGAssetMediaTypeVideo   = PHAssetMediaTypeVideo,
    IMGAssetMediaTypeAudio   = PHAssetMediaTypeAudio,
    IMGAssetMediaTypeAll 
};


typedef NS_ENUM(NSInteger, IMGVideoQualityType) {
    IMGVideoQualityTypeHigh = 0,        // highest quality
    IMGVideoQualityTypeMedium = 1,      // medium quality, suitable for transmission via Wi-Fi
    IMGVideoQualityTypeLow = 2,         // lowest quality, suitable for tranmission via cellular network
    IMGVideoQualityType640x480 =3,      // VGA quality
    IMGVideoQualityTypeIFrame1280x720  = 4,
    IMGVideoQualityTypeIFrame960x540  = 5,
};

@interface IMGConfigManager : NSObject

+ (IMGConfigManager *)shareManager;

/// 最多能选几张图片,默认9张
@property (nonatomic,assign) NSInteger maxCount;
/// IMGAssetMediaTypeImage default
@property (nonatomic,assign) IMGAssetMediaType mediaType;
/// default NO, only effect when maxCount equal to 1 if YES
@property(nonatomic,assign) BOOL allowsEditing;
/// default NO, will show 'live' tag and play LivePhoto if YES
@property(nonatomic,assign) BOOL allowLivePhoto;
/// default YES
@property(nonatomic,assign) BOOL allowGif;
/// default value is IMGVideoQualityTypeMedium. If the cameraDevice does not support the videoQuality, it will use the default value.
@property(nonatomic,assign) IMGVideoQualityType  videoQuality ;
/// default value is 10 seconds.
@property(nonatomic,assign) NSTimeInterval videoMaximumDuration;


@end

