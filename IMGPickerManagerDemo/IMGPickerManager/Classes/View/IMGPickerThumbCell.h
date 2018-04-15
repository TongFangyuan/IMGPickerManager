//
//  FYThumbCell.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/13.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class IMGPickerThumbCell;

@protocol IMGPickerThumbCellDelegate <NSObject>

- (void)pickerThumbCellDidClickButton:(IMGPickerThumbCell *)cell;

@end

@interface IMGPickerThumbCell : UICollectionViewCell

@property (nonatomic,weak) id<IMGPickerThumbCellDelegate> delegate;
@property (nonatomic,strong) PHAsset *asset;
@property (nonatomic,strong) UIImageView *thumbView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UIImageView *maskView;
@property (nonatomic,strong) UILabel *durationLabel;

- (void)setButtonSelected:(BOOL)selected;
- (void)updateMaskViewStatus:(BOOL)isShow;

@end
