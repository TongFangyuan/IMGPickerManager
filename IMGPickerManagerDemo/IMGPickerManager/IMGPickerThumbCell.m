//
//  FYThumbCell.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/13.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import "IMGPikcerHeader.h"

#import "IMGPickerThumbCell.h"
#import "PHAsset+IMGProperty.h"
#import "IMGPhotoManager.h"
#import "UIImageView+Cache.h"

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
        imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:imageView];
        _thumbView = imageView;
        [_thumbView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self.contentView);
        }];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.cornerRadius = kButtonWidth*0.5;
        UIImage *btnImage = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ic_photo_choosesel@2x.png" ofType:nil]];
        [button setBackgroundImage:btnImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttionClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
        _button = button;
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(kButtonWidth);
            make.top.mas_equalTo(2);
            make.right.equalTo(self.contentView.mas_right).offset(-2);
        }];
        
        UIImageView *maskView = [UIImageView new];
        maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        maskView.userInteractionEnabled = YES;
        [self.contentView insertSubview:maskView belowSubview:imageView];
        _maskView = maskView;
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.thumbView);
        }];
        
        UILabel *durationLabel = [UILabel new];
        durationLabel.textColor = [UIColor whiteColor];
        durationLabel.font = [UIFont boldSystemFontOfSize:10];
        durationLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:durationLabel];
        _durationLabel = durationLabel;
        [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.height.mas_equalTo(14);
            make.bottom.equalTo(self.contentView);
            make.width.equalTo(self.contentView).offset(-4);
        }];
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints {
    
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


- (void)setAsset:(PHAsset *)asset{
    _asset = asset;
    
    [self setButtonSelected:asset.select];
    
    __weak typeof(self) weakSelf = self;
//    [IMGPhotoManager requestImageForAsset:asset targetSize:self.bounds.size handler:^(UIImage *image, IMGMediaType imageType) {
//        weakSelf.thumbView.image = image;
//        if (imageType==IMGMediaTypeGif) {
//            weakSelf.durationLabel.text = @"Gif";
//        } else if (imageType==IMGMediaTypeLivePhoto && [IMGConfigManager shareManager].allowLivePhoto) {
//            weakSelf.durationLabel.text = @"Live";
//        } else {
//            weakSelf.durationLabel.text = @"";
//        }
//    }];
    
    CGSize targetSize = CGSizeZero;
    CGSize imageViewSize = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (CGSizeEqualToSize(imageViewSize, targetSize)) {
        targetSize = [UIScreen mainScreen].bounds.size;
    } else {
        targetSize = CGSizeMake(imageViewSize.width*scale, imageViewSize.height*scale);
    }
    
//    NSLog(@"targetSize:%@",NSStringFromCGSize(targetSize));
    
    [self.thumbView img_setImageWithAsset:asset targetSize:targetSize completed:nil];
    
    [PHAsset img_assetFormatForAsset:asset];
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {

        [IMGPhotoManager requestAVAssetForVideo:asset handler:^(AVAsset *avsset) {
            int64_t durationSeconds = CMTimeGetSeconds(avsset.duration);
            
            NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
            dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
            dcFormatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
            dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
            NSString *string = [dcFormatter stringFromTimeInterval:durationSeconds];

            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.durationLabel.text = string;
            });
            
        }];
    }
    
}


- (void)updateMaskViewStatus:(BOOL)isShow{
    if (isShow) {
        [self.maskView.superview bringSubviewToFront:self.maskView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView:)];
        [self.maskView addGestureRecognizer:tap];
        [self.maskView setUserInteractionEnabled:YES];
    } else {
        [self.maskView.superview sendSubviewToBack:self.maskView];
        [self.maskView setUserInteractionEnabled:NO];
    }
}


- (void)buttionClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pickerThumbCellDidClickButton:)]) {
        [self.delegate pickerThumbCellDidClickButton:self];
    }
}

- (void)tapMaskView:(id)sender {
    NSLog(@"%@",sender);
}

@end
