//
//  FYThumbCell.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/13.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import "IMGPickerThumbCell.h"
#import "IMGPickerConstant.h"
#import "PHAsset+IMGProperty.h"
#import "IMGPhotoManager.h"

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
        [button addTarget:self action:@selector(buttionClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
        _button = button;
        
        UIImageView *maskView = [UIImageView new];
        maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        maskView.frame = imageView.bounds;
        maskView.userInteractionEnabled = YES;
        [self.contentView insertSubview:maskView belowSubview:imageView];
        _maskView = maskView;
        
        UILabel *durationLabel = [UILabel new];
        durationLabel.textColor = [UIColor whiteColor];
        durationLabel.font = [UIFont boldSystemFontOfSize:10];
        durationLabel.textAlignment = NSTextAlignmentRight;
        durationLabel.frame = CGRectMake(0, frame.size.height-14, frame.size.width-4, 14);
        [self.contentView addSubview:durationLabel];
        _durationLabel = durationLabel;
        
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


- (void)setAsset:(PHAsset *)asset{
    _asset = asset;
    
    [self setButtonSelected:asset.select];
    
    __weak typeof(self) weakSelf = self;
    [IMGPhotoManager requestImageForAsset:asset targetSize:self.bounds.size handler:^(UIImage *image, IMGImageType imageType) {
        weakSelf.thumbView.image = image;
        if (imageType==IMGImageTypeGif) {
            weakSelf.durationLabel.text = @"Gif";
        } else if (imageType==IMGImageTypeLivePhoto && [IMGConfigManager shareManager].allowLivePhoto) {
            weakSelf.durationLabel.text = @"Live";
        } else {
            weakSelf.durationLabel.text = @"";
        }
    }];
    
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
