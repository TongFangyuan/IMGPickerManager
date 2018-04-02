//
//  FYPrivewCell.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/16.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+IMGProperty.h"

@interface IMGPreviewCell : UICollectionViewCell
<
UIScrollViewDelegate
>

@property (nonatomic,strong) PHAsset *model;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *iconView;

@end
