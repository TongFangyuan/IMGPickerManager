//
//  FYThumbCell.h
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/13.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYAssetModel.h"

@interface FYThumbCell : UICollectionViewCell

@property (nonatomic,strong) FYAssetModel *model;
@property (nonatomic,strong) UIImageView *thumbView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UIImageView *maskView;

- (void)setButtonSelected:(BOOL)selected;

@end
