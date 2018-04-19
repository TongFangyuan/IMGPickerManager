//
//  FYPrivewCell.h
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/16.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+IMGProperty.h"

@class IMGPreviewCell;

@protocol IMGPreviewCellDelegate <NSObject>

- (void)previewCellDidClickPlayButton:(IMGPreviewCell *)cell;

@end
@interface IMGPreviewCell : UICollectionViewCell
<
UIScrollViewDelegate
>

@property (nonatomic,weak) id<IMGPreviewCellDelegate> delegate;
@property (nonatomic,strong) PHAsset *model;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UIButton *playButton;

- (void)setPlayButtonHidden:(BOOL)hidden;
- (void)loadImage;
- (void)displayGifImage;
@end
