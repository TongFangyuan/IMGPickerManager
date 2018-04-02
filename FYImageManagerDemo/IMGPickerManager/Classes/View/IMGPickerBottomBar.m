//
//  PickerBottomBar.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/14.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "IMGPickerBottomBar.h"

@implementation IMGPickerBottomBar

- (instancetype)init
{
    if (self = [super init]) {
        UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [previewButton setTitle:@"预览" forState:UIControlStateNormal];
        [previewButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [previewButton setTitleColor:[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.00] forState:UIControlStateDisabled];
        previewButton.enabled = NO;
        previewButton.titleLabel.font = [UIFont  systemFontOfSize:16];
        previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:previewButton];
        _previewButton = previewButton;
        
        UIImageView *line = [UIImageView new];
        line.backgroundColor = [UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.00];
        [self addSubview:line];
        _line = line;
        
        /// 约束
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:previewButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15];
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:previewButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:previewButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:previewButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        previewButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint1,constraint2,constraint3,constraint4]];
        
        NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
        NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
        NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
        NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.3f];
        line.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint5,constraint6,constraint7,constraint8]];
    }
    return self;
}

@end
