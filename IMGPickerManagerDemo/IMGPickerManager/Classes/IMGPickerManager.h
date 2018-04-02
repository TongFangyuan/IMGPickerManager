//
//  IMGPickerTool.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/28.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^IMGCompleteBlock)(NSArray *result,NSError *error);

@interface IMGPickerManager : NSObject

+ (void)start:(IMGCompleteBlock)completeBlock;

@end
