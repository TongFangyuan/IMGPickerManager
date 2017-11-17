//
//  FYImagePrivewController.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/15.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "FYImagePrivewController.h"
#import "FYPrivewCell.h"
#import "OperationView.h"

@interface FYImagePrivewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>
{
    BOOL isCollectionViewTop;
}

@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,strong) OperationView *operationView;

@end

@implementation FYImagePrivewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.selectIndexPath) {
        [self.collectionView scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - private
- (void)operationVIewTap:(UITapGestureRecognizer *)tap
{
    if (isCollectionViewTop) {
        [self.collectionView.superview sendSubviewToBack:self.collectionView];
    } else {
        [self.collectionView.superview bringSubviewToFront:self.collectionView];
    }
    
    isCollectionViewTop = !isCollectionViewTop;
}

- (void)showCellAtIndexPath:(NSIndexPath *)indexPath
{
    FYAssetModel *asset = self.assets[indexPath.item];
    
    // 底部按钮选中状态
    [self.operationView setButtonSelected:[self.selectedAssets containsObject:asset]];
    
    // 顶部是否展示选中数量按钮
    if (self.selectedAssets.count) {
        self.operationView.numberButton.hidden = NO;
        [self.operationView.numberButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.selectedAssets.count] forState:UIControlStateNormal];
    } else {
        self.operationView.numberButton.hidden = YES;
    }
}

- (void)userClickedSelectedButton:(UIButton *)button
{
    
    // 添加还是移除
    FYAssetModel *asset = self.assets[self.selectIndexPath.item];
    if ([self.selectedAssets containsObject:asset]) {
        [self.selectedAssets removeObject:asset];
    } else {
        [self.selectedAssets addObject:asset];
    }
    
    [self showCellAtIndexPath:self.selectIndexPath];
}

- (void)closedButtonAction:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - property

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[FYPrivewCell class] forCellWithReuseIdentifier:@"FYPrivewCell"];
    }
    return _collectionView;
}

- (OperationView *)operationView
{
    if (!_operationView) {
        _operationView = [OperationView new];
        _operationView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(operationVIewTap:)];
        [_operationView addGestureRecognizer:tap];
        [_operationView.closedButton addTarget:self action:@selector(closedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.selectedButton addTarget:self action:@selector(userClickedSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationView;
}

- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 10;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}


- (void)initSubviews
{
    [self.view addSubview:self.operationView];
    [self.operationView addSubview:self.collectionView];
    
    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:self.operationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:self.operationView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.];
    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:self.operationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:self.operationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    self.operationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[constraint5,constraint6,constraint7,constraint8]];
    
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.operationView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-5.f];
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.operationView attribute:NSLayoutAttributeRight multiplier:1.0 constant:5.];
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.operationView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.operationView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.operationView addConstraints:@[constraint1,constraint2,constraint3,constraint4]];
    [self.collectionView.superview sendSubviewToBack:self.collectionView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FYPrivewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FYPrivewCell" forIndexPath:indexPath];
    FYAssetModel *asset = _assets[indexPath.item];
    cell.model = asset;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[FYPrivewCell class]]) {
        [[(FYPrivewCell *)cell scrollView] setZoomScale:1.0 animated:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[FYPrivewCell class]]) {
        [[(FYPrivewCell *)cell scrollView] setZoomScale:1.0 animated:NO];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==self.collectionView) {
        
        CGPoint point = [self.collectionView convertPoint:self.operationView.center fromView:self.operationView.superview];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
//        NSLog(@"%@",indexPath);
        [self showCellAtIndexPath:indexPath];
        self.selectIndexPath = indexPath;
    }
}

@end
