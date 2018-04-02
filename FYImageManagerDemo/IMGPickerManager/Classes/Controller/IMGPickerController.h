//
//  FYImagePickerController.h
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/11.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMGPickerConstant.h"

/// 定义block
typedef void(^IMGPickerCompleteBlock)(NSArray *result,NSError *error);

@interface IMGPickerController : UIViewController

/// 完成回调
@property (nonatomic,copy) IMGPickerCompleteBlock completeBlock;

@end
