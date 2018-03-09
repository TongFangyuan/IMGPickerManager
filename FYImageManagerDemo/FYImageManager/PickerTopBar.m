//
//  PickerTopBar.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/14.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "PickerTopBar.h"

@implementation PickerTopBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIButton *closedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closedButton setImage:[UIImage imageNamed:@"ic_photo_close"] forState:UIControlStateNormal];
//        closedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        closedButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        [self addSubview:closedButton];
        _closedButton = closedButton;
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor colorWithRed:0.19 green:0.57 blue:0.83 alpha:1.00] forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.00] forState:UIControlStateDisabled];
        doneButton.enabled = NO;
        doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:doneButton];
        _doneButton = doneButton;
        
        UIButton *numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        numberButton.backgroundColor = [UIColor colorWithRed:0.19 green:0.57 blue:0.83 alpha:1.00];
        [numberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        numberButton.titleLabel.font = [UIFont systemFontOfSize:16];
        numberButton.layer.cornerRadius = 10;
        [numberButton setTitle:@"1" forState:UIControlStateNormal];
        numberButton.hidden = YES;
        [self addSubview:numberButton];
        _numberButton = numberButton;
        
        UIView *titleView = [UIView new];
        [self addSubview:titleView];
        _titleView = titleView;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.f];
        titleLabel.text = @"相机胶卷";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UILabel *tipsLabel = [UILabel new];
        tipsLabel.font = [UIFont boldSystemFontOfSize:10.f];
        tipsLabel.text = @"轻触更改相册";
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        [_titleView addSubview:tipsLabel];
        _tipsLabel = tipsLabel;
        
        
        UIImageView *line = [UIImageView new];
        line.backgroundColor = [UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.00];
        [self addSubview:line];
        _line = line;

        /// 添加约束
        // closed button
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:closedButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:closedButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:closedButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:closedButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        closedButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint1,constraint2,constraint3,constraint4]];
        
        // done button
        NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15.0];
        NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint5,constraint6,constraint7,constraint8]];

        // number button
        NSLayoutConstraint *constraint9 = [NSLayoutConstraint constraintWithItem:numberButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:doneButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint10 = [NSLayoutConstraint constraintWithItem:numberButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:numberButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:numberButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        numberButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint9,constraint10,constraint11,constraint12]];
        
        // title view
        NSLayoutConstraint *constraint13 = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:closedButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint14 = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:numberButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint15 = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint16 = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        titleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint13,constraint14,constraint15,constraint16]];
        
        
        // titleLabel
        NSLayoutConstraint *constraint17 = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.f];
        NSLayoutConstraint *constraint18 = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [titleView addConstraints:@[constraint17,constraint18]];

        // tipsLabel
        NSLayoutConstraint *constraint19 = [NSLayoutConstraint constraintWithItem:tipsLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:2.f];
        NSLayoutConstraint *constraint20 = [NSLayoutConstraint constraintWithItem:tipsLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
         tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [titleView addConstraints:@[constraint19,constraint20]];
        
        // line
        NSLayoutConstraint *constraint21 = [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.f];
        NSLayoutConstraint *constraint22 = [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
        NSLayoutConstraint *constraint23 = [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
        NSLayoutConstraint *constraint24 = [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.3f];
        line.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint21,constraint22,constraint23,constraint24]];
        
    }
    return self;
}

@end
