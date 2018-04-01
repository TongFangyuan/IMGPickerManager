//
//  IMGPickerTool.h
//  FYImageManagerDemo
//
//  Created by admin on 2018/3/28.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGPickerManager.h"

typedef void(^IMGCompleteBlock)(NSArray *result,NSError *error);

@interface IMGPickerTool : NSObject

+ (void)start:(IMGCompleteBlock)completeBlock;

@end
