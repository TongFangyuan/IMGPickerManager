//
//  FYImagePrivewController.h
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/15.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYAssetModel.h"

@interface FYImagePrivewController : UIViewController

/// 最多能选几张图片,默认9张
@property (nonatomic,assign) NSInteger maxCount;
/// 所有资源数组
@property (nonatomic,strong) NSArray<FYAssetModel *> *assets;
/// 初始选中的资源数组
@property (nonatomic,strong) NSMutableArray<FYAssetModel *> *originalSelectedAssets;
/// 当前选中的 indexPath
@property (nonatomic,strong) NSIndexPath *selectIndexPath;
/// 数据回调
@property (nonatomic,copy) void(^complete)(NSArray *selectedAssets);
- (void)setupCompleteBlock:(void(^)(NSArray *selectedAssets))block;


/// 暂时隐藏掉,感觉没比较暴露出去
///// 当前选中资源,应当在用户退出当前控制器的时候调用,当用户点击 'x' 按钮的时候,返回的是 originalSelectedAssets ,点击 '完成' 返回用户实时选中的资源
//@property (nonatomic,strong,readonly) NSMutableArray<FYAssetModel *> *selectedAssets;



@end
