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

@implementation IMGPreviewCell


- (void)setModel:(PHAsset *)model
{
    _model = model;
    
    if (model.mediaType == PHAssetMediaTypeVideo) {
        self.playButton.hidden = NO;
    } else {
        self.playButton.hidden = YES;
    }
    
    [self loadImage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"viewWillTransitionToSize" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillTransitionToSize:) name:@"viewWillTransitionToSize" object:nil];
    
}

- (void)updateFrame
{
    if (CGSizeEqualToSize(self.scrollView.bounds.size, self.contentView.bounds.size)) {
        return;
    }
    
    self.scrollView.frame = self.contentView.bounds;
    self.playButton.center = self.contentView.center;
    
    CGSize size = self.scrollView.frame.size;
    CGRect iconFrame = CGRectZero;
    CGSize fitSize =  [UIView fitSize:self.iconView.image.size toSize:size];
    iconFrame.size = fitSize;
    iconFrame.origin.y = size.height*0.5 - fitSize.height*0.5;
    iconFrame.origin.x = size.width*0.5 - fitSize.width*0.5;
    self.iconView.frame = iconFrame;
}

- (void)updateUI {

    //initUI
    [self updateFrame];
    
}

- (void)loadImage {
    __weak typeof(self) weakSelf = self;
    __block CGFloat scale = [UIScreen mainScreen].scale;
    __block CGSize screenSize = self.contentView.bounds.size;
    __block CGSize targetSize = CGSizeMake(self.iconView.frame.size.width*scale, self.iconView.frame.size.height*scale);
    [IMGPhotoManager requestImageForAsset:self.model targetSize:targetSize handler:^(UIImage *image, IMGMediaType imageType) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            CGRect frame = CGRectZero;
            CGSize oriSize = CGSizeMake(image.size.width/scale, image.size.height/scale);
            frame.size = [UIView fitSize:oriSize toSize:screenSize];
            frame.origin.y = screenSize.height*0.5 - frame.size.height*0.5;
            frame.origin.x = screenSize.width*0.5 - frame.size.width*0.5;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.iconView.frame = frame;
                weakSelf.iconView.center = weakSelf.superview.center;
                weakSelf.iconView.image = image;
            });
        });
    }];
    
}

- (void)displayGifImage {
    
    __weak typeof(self) weakSelf = self;
    __block CGFloat scale = [UIScreen mainScreen].scale;
    __block CGSize screenSize = self.contentView.bounds.size;
    [IMGPhotoManager requestDataForAsset:self.model handler:^(NSData *mediaData, IMGMediaType mediaType) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [UIImage animatedImageWithAnimatedGIFData:mediaData];
            CGRect frame = CGRectZero;
            CGSize oriSize = CGSizeMake(image.size.width/scale, image.size.height/scale);
            frame.size = [UIView fitSize:oriSize toSize:screenSize];
            frame.origin.y = screenSize.height*0.5 - frame.size.height*0.5;
            frame.origin.x = screenSize.width*0.5 - frame.size.width*0.5;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.iconView.frame = frame;
                weakSelf.iconView.center = weakSelf.superview.center;
                weakSelf.iconView.image = image;
            });
        });
        
    }];
    
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
        
        self.clipsToBounds = YES;
        
    }
    return self;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Notification
- (void)viewWillTransitionToSize:(NSNotification *)noti{
    
    CGSize size = CGSizeFromString(noti.userInfo[@"size"]);
    
    if (CGSizeEqualToSize(self.scrollView.frame.size, size)) {
        return;
    }

    if (!self.iconView.image) {
        return;
    }
    
    self.scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGRect iconFrame = CGRectZero;
    CGSize fitSize =  [UIView fitSize:self.iconView.image.size toSize:size];
    iconFrame.size = fitSize;
    iconFrame.origin.y = size.height*0.5 - fitSize.height*0.5;
    iconFrame.origin.x = size.width*0.5 - fitSize.width*0.5;
    self.iconView.frame = iconFrame;
    
    self.playButton.center = self.scrollView.center;

}

@end
