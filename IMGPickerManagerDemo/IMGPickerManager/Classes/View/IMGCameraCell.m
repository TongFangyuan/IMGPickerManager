//
//  IMGCameraCell.m
//  IMGPickerManagerDemo
//
//  Created by 童方园 on 2018/4/13.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGCameraCell.h"

@implementation IMGCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        iconView.contentMode = UIViewContentModeCenter;
        iconView.image = [UIImage imageNamed:@"take_photo"];
        [self.contentView addSubview:iconView];
        self.iconView = iconView;
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

@end
