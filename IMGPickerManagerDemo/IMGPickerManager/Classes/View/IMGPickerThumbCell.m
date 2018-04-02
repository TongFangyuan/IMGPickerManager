//
//  FYThumbCell.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/13.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import "IMGPickerThumbCell.h"
#import "IMGPickerConstant.h"

static CGFloat kButtonWidth = 22;

@interface IMGPickerThumbCell()

@end

@implementation IMGPickerThumbCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self =[super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:imageView];
        _thumbView = imageView;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.frame = CGRectMake(frame.size.width-kButtonWidth-2, 2, kButtonWidth, kButtonWidth);
        button.layer.cornerRadius = kButtonWidth*0.5;
        [button setBackgroundImage:[UIImage imageNamed:@"ic_photo_choosesel"] forState:UIControlStateSelected];

        [self.contentView addSubview:button];
        _button = button;
        
        UIImageView *maskView = [UIImageView new];
        maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        maskView.frame = imageView.bounds;
        maskView.userInteractionEnabled = YES;
        [self.contentView insertSubview:maskView belowSubview:imageView];
        _maskView = maskView;
    }
    return self;
}

- (void)setButtonSelected:(BOOL)selected
{
    _button.selected = selected;
    
    if (selected) {
        _button.backgroundColor = [UIColor whiteColor];
        _button.layer.borderWidth = 1;
    } else {
        _button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        _button.layer.borderWidth = 1;
    }
    
}

@end
