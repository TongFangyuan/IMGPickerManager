//
//  FYPrivewCell.h
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/16.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYPrivewCell : UICollectionViewCell
<
UIScrollViewDelegate
>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *iconView;

@end
