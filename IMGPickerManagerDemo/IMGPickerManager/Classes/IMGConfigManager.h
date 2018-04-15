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
    IMGAssetMediaTypeAudio   = 3,
};

@interface IMGConfigManager : NSObject

+ (IMGConfigManager *)shareManager;

/// 最多能选几张图片,默认9张
@property (nonatomic,assign) NSInteger maxCount;
/// IMGAssetMediaTypeImage default
@property (nonatomic,assign) IMGAssetMediaType mediaType;
/// 
@property(nonatomic,assign) BOOL allowsEditing;

//TODO: 属性
//1.相机拍完照之后是否可编辑
//2.颜色主题
//...

@end

