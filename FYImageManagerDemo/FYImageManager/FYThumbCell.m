//
//  FYThumbCell.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/13.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "FYThumbCell.h"

@interface FYThumbCell()

@property (nonatomic,assign) PHImageRequestID imageRequsetID;

@end

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
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.frame = CGRectMake(frame.size.width-22-2, 2, 22, 22);
        button.layer.cornerRadius = 11;
        
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
    _imageRequsetID = [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(ScreenWidth/[UIScreen mainScreen].scale, ScreenHeight/[UIScreen mainScreen].scale) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
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
        _button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    }
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // 取消下载图片
    if (_imageRequsetID) {
        [[PHImageManager defaultManager] cancelImageRequest:_imageRequsetID];
    }
    
}

@end
