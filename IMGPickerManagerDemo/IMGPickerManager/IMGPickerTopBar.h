//
//  PickerTopBar.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/14.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMGPickerTopBar : UIView

/// 关闭按钮
@property (nonatomic,strong) UIButton *closedButton;
/// 完成按钮
@property (nonatomic,strong) UIButton *doneButton;
/// 图片张数按钮
@property (nonatomic,strong) UIButton *numberButton;

/// titleView
@property (nonatomic,strong) UIView *titleView;
/// 标题, titleView 子视图
@property (nonatomic,strong) UILabel *titleLabel;
/// tips 标题,titleView 子视图
@property (nonatomic,strong) UILabel *tipsLabel;

/// 底部灰色线条
@property (nonatomic,strong) UIImageView *line;

@end
