//
//  FYAlbumsCell.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/15.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "IMGAlbumsCell.h"

@implementation IMGAlbumsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.tintColor = [UIColor colorWithRed:0.20 green:0.56 blue:0.77 alpha:1.00];
        _iconView = [UIImageView new];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
        _iconView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_iconView];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:16.f];
        [self.contentView addSubview:_titleLabel];
        
        _numberLabel = [UILabel new];
        _numberLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:_numberLabel];
        
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:56];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:56];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:@[constraint1,constraint2,constraint3,constraint4]];

        NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeRight multiplier:1.0 constant:20];
        NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:@[constraint5,constraint6]];
        
        NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:_numberLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
        NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:_numberLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:6.];
        _numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:@[constraint7,constraint8]];

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
