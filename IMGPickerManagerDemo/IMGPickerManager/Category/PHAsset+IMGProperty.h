//
//  PHAsset+IMGProperty.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/30.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (IMGProperty)

@property (nonatomic,assign) BOOL select;
/// 是否超出了最大选择数
@property (nonatomic,assign) BOOL overflow;

@end
