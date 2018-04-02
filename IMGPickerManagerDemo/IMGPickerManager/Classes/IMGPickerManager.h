//
//  IMGPickerTool.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/28.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;

typedef void(^IMGCompleteBlock)(NSArray<PHAsset *> *results,NSError *error);

@interface IMGPickerManager : NSObject

+ (void)startChoose:(IMGCompleteBlock)completeBlock;

@end
