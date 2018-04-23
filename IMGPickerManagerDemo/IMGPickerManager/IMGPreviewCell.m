//
//  FYPrivewCell.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/16.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import "IMGPreviewCell.h"
#import "UIImage+animatedGIF.h"
#import "IMGPhotoManager.h"
#import <Masonry/Masonry.h>

@implementation IMGPreviewCell


- (void)setModel:(PHAsset *)model
{
    _model = model;

    if (model.mediaType == PHAssetMediaTypeVideo) {
        self.playButton.hidden = NO;
    } else {
        self.playButton.hidden = YES;
    }
    
    
}

- (void)loadImage {
    
    __weak typeof(self) weakSelf = self;
//    __block CGFloat scale = [UIScreen mainScreen].scale;
    __block CGFloat scale = 1;
    __block CGSize targetSize = CGSizeMake(self.iconView.frame.size.width*scale, self.iconView.frame.size.height*scale);
    
    [IMGPhotoManager requestImageForAsset:self.model targetSize:targetSize handler:^(UIImage *image, IMGMediaType imageType) {
//        NSLog(@"image:%@",image);
        CGRect frame = CGRectZero;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        
        frame.size = CGSizeMake(image.size.width/scale, image.size.height/scale);
        
        while (frame.size.width>screenSize.width || frame.size.height>screenSize.height) {
            
            if (frame.size.width>screenSize.width) {
                frame.size.width = screenSize.width;
                frame.size.height = image.size.height/image.size.width * frame.size.width;
            }
            if (frame.size.height>screenSize.height) {
                frame.size.height = screenSize.height;
                frame.size.width = image.size.width/image.size.height * frame.size.height;
            }
        }
        
        [IMGPhotoManager cacheImageForAsset:@[weakSelf.model] targetSize:image.size];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.iconView.frame = frame;
            weakSelf.iconView.center = weakSelf.superview.center;
            weakSelf.iconView.image = image;
        });
    }];
    
}

- (void)displayGifImage {
    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [IMGPhotoManager requestImageDataForAsset:self.model handler:^(NSData *imageData, IMGMediaType imageType) {
            UIImage *gifImage = [UIImage animatedImageWithAnimatedGIFData:imageData];
            CGFloat imageHeight = gifImage.size.height/gifImage.size.width * [UIScreen mainScreen].bounds.size.width;
            CGFloat imageY = [UIScreen mainScreen].bounds.size.height*0.5 - imageHeight*0.5;
//            NSLog(@"gifImage:%@",gifImage);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.iconView.image = gifImage;
                weakSelf.iconView.frame = CGRectMake(0, imageY, [UIScreen mainScreen].bounds.size.width, imageHeight);
            });
        }];
    });

}

- (void)setPlayButtonHidden:(BOOL)hidden {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.model.mediaType == PHAssetMediaTypeVideo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.playButton.hidden = hidden;
            });
        } else {
            self.playButton.hidden = YES;
        }
    });
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.iconView];
        [self.contentView addSubview:self.playButton];
        
        self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.iconView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.playButton.frame = CGRectMake(0, 0, 80, 80);
        self.playButton.center = self.contentView.center;
        
    }
    return self;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView  = [UIImageView new];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"play@2x.png" ofType:nil]];
        [_playButton setImage:image forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.iconView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    //    NSLog(@"%@",view);
    //    NSLog(@"%f",scale);
    //    NSLog(@"%@",scrollView);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat scrollViewWidth = self.scrollView.frame.size.width;
    CGFloat scrollViewHeight = self.scrollView.frame.size.height;
    CGFloat offsetX = (scrollViewWidth > self.scrollView.contentSize.width) ? ((scrollViewWidth - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (scrollViewHeight > _scrollView.contentSize.height) ? ((scrollViewHeight - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.iconView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    self.scrollView.zoomScale = 1;
}


- (void)playButtonCliked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(previewCellDidClickPlayButton:)]) {
        [self.delegate previewCellDidClickPlayButton:self];
    }
}


@end
