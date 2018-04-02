//
//  IMGPickerTool.h
//  FYImageManagerDemo
//
//  Created by admin on 2018/3/28.
//  Copyright © 2018年 tongfy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^IMGCompleteBlock)(NSArray *result,NSError *error);

@interface IMGPickerManager : NSObject

+ (void)start:(IMGCompleteBlock)completeBlock;

@end
