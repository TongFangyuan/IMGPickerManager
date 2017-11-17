//
//  FYPrivewCell.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/16.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "FYPrivewCell.h"

@implementation FYPrivewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.iconView];
        
        /*
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:@[constraint1,constraint2,constraint3,constraint4]];
        
        NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
        NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:@[constraint5,constraint6]];
         */
         
        self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.iconView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        

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


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.iconView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    NSLog(@"%@",view);
    NSLog(@"%f",scale);
    NSLog(@"%@",scrollView);
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
@end
