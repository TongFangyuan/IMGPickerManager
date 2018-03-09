//
//  OperationView.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/16.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "OperationView.h"

@implementation OperationView

- (instancetype)init
{
    if (self=[super init]) {
        
        UIButton *closedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closedButton setImage:[UIImage imageNamed:@"ic_close_white"] forState:UIControlStateNormal];
//        closedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:closedButton];
        _closedButton = closedButton;
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:doneButton];
        _doneButton = doneButton;
        
        UIButton *numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        numberButton.backgroundColor = [UIColor colorWithRed:0.19 green:0.57 blue:0.83 alpha:1.00];
        [numberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        numberButton.titleLabel.font = [UIFont systemFontOfSize:16];
        numberButton.layer.cornerRadius = 10;
        numberButton.layer.borderWidth = 1;
        numberButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [numberButton setTitle:@"1" forState:UIControlStateNormal];
        numberButton.hidden = YES;
        [self addSubview:numberButton];
        _numberButton = numberButton;
        
        UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectedButton.layer.borderWidth = 1;
        selectedButton.layer.borderColor = [UIColor whiteColor].CGColor;
        selectedButton.layer.cornerRadius = 15;
        [selectedButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        [selectedButton setBackgroundImage:[UIImage imageNamed:@"ic_photo_choosesel"] forState:UIControlStateSelected];
//        [selectedButton setImage:[UIImage new] forState:UIControlStateNormal];
//        [selectedButton setImage:[UIImage imageNamed:@"ic_photo_choosesel"] forState:UIControlStateSelected];
        [self addSubview:selectedButton];
        _selectedButton = selectedButton;
        
        UIImageView *topMask = [UIImageView new];
//        topMask.image = [UIImage imageNamed:@"mask_gray"];
        topMask.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        [self insertSubview:topMask belowSubview:closedButton];
        _topMask = topMask;
        
        UIImageView *bottomMask = [UIImageView new];
//        bottomMask.image = [UIImage imageNamed:@"mask_gray"];
        bottomMask.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        [self insertSubview:bottomMask belowSubview:closedButton];
        _bottomMask = bottomMask;
        
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:closedButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:closedButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5];
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:closedButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:closedButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        closedButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint1,constraint2,constraint3,constraint4]];
        
        NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-13];
        NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:closedButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint5,constraint6,constraint7,constraint8]];
        
        // number button
        NSLayoutConstraint *constraint9 = [NSLayoutConstraint constraintWithItem:numberButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:doneButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint10 = [NSLayoutConstraint constraintWithItem:numberButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:doneButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:numberButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:numberButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        numberButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint9,constraint10,constraint11,constraint12]];
        
        // selectedButton
        NSLayoutConstraint *constraint13 = [NSLayoutConstraint constraintWithItem:selectedButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15];
        NSLayoutConstraint *constraint14 = [NSLayoutConstraint constraintWithItem:selectedButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15];
        NSLayoutConstraint *constraint15 = [NSLayoutConstraint constraintWithItem:selectedButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30];
        NSLayoutConstraint *constraint16 = [NSLayoutConstraint constraintWithItem:selectedButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30];
        selectedButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint13,constraint14,constraint15,constraint16]];

        // topmask
        NSLayoutConstraint *constraint17 = [NSLayoutConstraint constraintWithItem:topMask attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint18 = [NSLayoutConstraint constraintWithItem:topMask attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint19 = [NSLayoutConstraint constraintWithItem:topMask attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint20 = [NSLayoutConstraint constraintWithItem:topMask attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
        topMask.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint17,constraint18,constraint19,constraint20]];
        
        // bottom_mask
        NSLayoutConstraint *constraint21 = [NSLayoutConstraint constraintWithItem:bottomMask attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint22 = [NSLayoutConstraint constraintWithItem:bottomMask attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint23 = [NSLayoutConstraint constraintWithItem:bottomMask attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint24 = [NSLayoutConstraint constraintWithItem:bottomMask attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:56];
        bottomMask.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[constraint21,constraint22,constraint23,constraint24]];

    }
    return self;
}

- (void)setButtonSelected:(BOOL)selected
{
    _selectedButton.selected = selected;
    
    if (selected) {
        _selectedButton.backgroundColor = [UIColor clearColor];
        _selectedButton.layer.borderWidth = 0;
    } else {
        _selectedButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        _selectedButton.layer.borderWidth = 1;
    }
    
}

@end
