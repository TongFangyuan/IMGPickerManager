//
//  FYImagePrivewController.h
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/15.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYAsset.h"

@interface FYImagePrivewController : UIViewController

@property (nonatomic,strong) UICollectionView *collectionView;
/// FYAsset 资源数组
@property (nonatomic,strong) NSArray<FYAsset *> *assets;
/// 选中的 FYAsset
@property (nonatomic,strong) NSMutableArray<FYAsset *> *selectedAssets;
/// 当前选中的 indexPath
@property (nonatomic,strong) NSIndexPath *selectIndexPath;

@end
