//
//  FYThumbCell.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/13.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+IMGProperty.h"

@interface IMGPickerThumbCell : UICollectionViewCell

@property (nonatomic,strong) PHAsset *model;
@property (nonatomic,strong) UIImageView *thumbView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UIImageView *maskView;

- (void)setButtonSelected:(BOOL)selected;

@end
