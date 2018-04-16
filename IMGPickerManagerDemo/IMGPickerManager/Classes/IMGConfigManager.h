//
//  IMGConfiguration.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/28.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IMGAssetMediaType) {
    IMGAssetMediaTypeUnknown = 0,
    IMGAssetMediaTypeImage   = 1,
    IMGAssetMediaTypeVideo   = 2,
    IMGAssetMediaTypeAudio   = IMGAssetMediaTypeUnknown,
    IMGAssetMediaTypeAll
};

@interface IMGConfigManager : NSObject

+ (IMGConfigManager *)shareManager;

/// 最多能选几张图片,默认9张
@property (nonatomic,assign) NSInteger maxCount;
/// IMGAssetMediaTypeImage default
@property (nonatomic,assign) IMGAssetMediaType mediaType;
/// default NO
@property(nonatomic,assign) BOOL allowsEditing;
/// default NO, will show 'live' tag and play LivePhoto if YES
@property(nonatomic,assign) BOOL allowLivePhoto;
/// default YES
@property(nonatomic,assign) BOOL allowGif;

@end

