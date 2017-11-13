//
//  FYThumbCell.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/13.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "FYThumbCell.h"

@implementation FYThumbCell

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
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        button.frame = CGRectMake(frame.size.width-20-2, 2, 20, 20);
        
        [self.contentView addSubview:button];
        _button = button;
    }
    return self;
}

- (void)setAsset:(FYAsset *)asset
{
    _asset = asset;
    
    PHAsset *phAsset = asset.asset;
    
    // 图片
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(ScreenWidth, ScreenHeight) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        _thumbView.image = result;
    }];
    
    // 选中状态
    [self setButtonSelected:asset.select];
    
}

- (void)setButtonSelected:(BOOL)selected
{
    _button.selected = selected;
    
    if (selected) {
        _button.backgroundColor = [UIColor redColor];
    } else {
        _button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    }
    
}

@end
