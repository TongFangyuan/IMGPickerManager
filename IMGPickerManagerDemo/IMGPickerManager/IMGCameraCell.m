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
        iconView.image = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"take_photo@2x.png" ofType:nil]];
        [self.contentView addSubview:iconView];
        self.iconView = iconView;
    }
    return self;
}

@end
