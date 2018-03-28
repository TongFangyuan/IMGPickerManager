//
//  IMGConfiguration.h
//  FYImageManagerDemo
//
//  Created by admin on 2018/3/28.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMGConfiguration : NSObject

/// 最多能选几张图片,默认9张
@property (nonatomic,assign) NSInteger maxCount;

+ (IMGConfiguration *)sharedInstance;

@end
