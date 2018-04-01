//
//  FYImagePrivewController.h
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/15.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMGPickerConstant.h"
#import "IMGConfiguration.h"
#import <Photos/Photos.h>

typedef void(^IMGPrivewCompleteBlock)(NSArray *result,NSError *error);
typedef void(^IMGPrivewCancelBlock)(NSArray *result);


@interface FYImagePrivewController : UIViewController

/// 所有资源数组
@property (nonatomic,strong) NSArray<PHAsset *> *assets;
/// 初始选中的资源数组
@property (nonatomic,strong) NSMutableArray<PHAsset *> *originalSelectedAssets;
/// 当前选中的 indexPath
@property (nonatomic,strong) NSIndexPath *selectIndexPath;
/// 选择完成
@property (nonatomic,copy) IMGPrivewCompleteBlock completeBlock;
/// 取消选择
@property (nonatomic,copy) IMGPrivewCancelBlock cancelBlock;

@end
