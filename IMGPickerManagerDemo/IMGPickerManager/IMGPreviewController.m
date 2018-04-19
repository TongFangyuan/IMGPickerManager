//
//  FYImagePrivewController.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/15.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import "IMGPreviewController.h"
#import "IMGPreviewCell.h"
#import "IMGPreviewOperationView.h"
#import "UIViewController+FYAlert.h"
#import "IMGPlayerManager.h"
#import "IMGPhotoManager.h"
#import "IMGPickerManager.h"

@interface IMGPreviewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
IMGPreviewCellDelegate,
IMGPlayerDelegate
>
{
    BOOL isCollectionViewTop;
}

@property (nonatomic,assign) BOOL isNeedScroll;//defaulf is YES
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,strong) IMGPreviewOperationView *operationView;
@property (nonatomic,strong) IMGPreviewCell *playCell;
@property (nonatomic,strong) IMGPreviewCell *playLiveCell;

/// 选中的资源
@property (nonatomic,strong) NSMutableArray<PHAsset *> *selectedAssets;



@end


@implementation IMGPreviewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubviews];
    
    /// 设置选中的资源
    self.isNeedScroll = YES;
    self.selectedAssets = [NSMutableArray arrayWithArray:self.originalSelectedAssets];
    
    [self.operationView.doneButton setEnabled:self.selectedAssets.count];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (self.selectIndexPath && self.isNeedScroll) {
        [self.collectionView setContentOffset:CGPointMake((self.flowLayout.minimumLineSpacing+self.flowLayout.itemSize.width)*self.selectIndexPath.item, 0) animated:NO];
    }
    [self needShowCellAtIndexPath:self.selectIndexPath];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self needShowCellAtIndexPath:self.selectIndexPath];
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

- (void)dealloc {
    [[IMGPlayerManager shareManager] stop];
    [[IMGPlayerManager shareManager] stopPlayLivePhoto];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//MARK: -  Event Respones

- (void)operationViewTap:(UITapGestureRecognizer *)tap
{
    if (isCollectionViewTop) {
        [self.collectionView.superview sendSubviewToBack:self.collectionView];
    } else {
        [self.collectionView.superview bringSubviewToFront:self.collectionView];
    }
    
    isCollectionViewTop = !isCollectionViewTop;
}

- (void)needShowCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) {
        return;
    }
    
    PHAsset *asset = self.assets[indexPath.item];
    IMGPreviewCell *displayCell = (IMGPreviewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    // 播放livePhoto
    if ( @available(iOS 9.1, *)) {
        __weak typeof(self) weakSelf = self;
        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive && displayCell.iconView) {
            [IMGPhotoManager requestLivePhotoForAsset:asset targetSize:displayCell.iconView.frame.size handler:^(PHLivePhoto *livePhoto) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[IMGPlayerManager shareManager] playLivePhoto:livePhoto contentView:displayCell.iconView];
                    weakSelf.playLiveCell = displayCell;
                });
            }];
        }
    }
    
    // 加载gif图片
    if ([IMGPhotoManager getMediaTypeForAsset:displayCell.model]==IMGMediaTypeGif) {
        [displayCell displayGifImage];
    }

    //// 底部按钮选中状态
    [self.operationView setButtonSelected:[self.selectedAssets containsObject:asset]];
    [self.operationView.doneButton setEnabled:self.selectedAssets.count];
    
    // 顶部是否展示选中数量按钮
    if (self.selectedAssets.count) {
        self.operationView.numberButton.hidden = NO;
        [self.operationView.numberButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.selectedAssets.count] forState:UIControlStateNormal];
    } else {
        self.operationView.numberButton.hidden = YES;
    }
    
    self.selectIndexPath = indexPath;
    
}

- (void)userClickedSelectedButton:(UIButton *)button
{
    self.isNeedScroll = NO;
    
    PHAsset *asset = self.assets[self.selectIndexPath.item];
    
    if ( (self.selectedAssets.count>=[IMGConfigManager shareManager].maxCount) && ![self.selectedAssets containsObject:asset]) {
        NSString *msg= [NSString stringWithFormat:@"最多只能选择%ld张",(long)[IMGConfigManager shareManager].maxCount];
        [self fy_showTitle:@"提示" message:msg];
        return;
    }
    
    // 添加还是移除
    if ([self.selectedAssets containsObject:asset]) {
        [self.selectedAssets removeObject:asset];
        [asset setSelect:NO];
    } else {
        [self.selectedAssets addObject:asset];
        [asset setSelect:YES];
    }
    
    [self needShowCellAtIndexPath:self.selectIndexPath];
}

- (void)closedButtonAction:(UIButton *)button
{
    //// 设置选中状态
    [self.assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.selectedAssets containsObject:obj]) {
            [obj setSelect:YES];
        } else {
            [obj setSelect:NO];
        }
    }];
    
    //// 数据回调
    if (self.cancelBlock) {
        self.cancelBlock(self.selectedAssets);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonAction:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IMGPickerManagerWillPickCompleteNotification object:nil userInfo:@{@"data":self.selectedAssets}];
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

#pragma mark - IMGPreviewCellDelegate
- (void)previewCellDidClickPlayButton:(IMGPreviewCell *)cell {
    PHAsset *asset = cell.model;
    
    self.playCell = cell;
    
    __weak typeof(cell) weakCell = cell;
    [IMGPhotoManager requestPlayerItemForVideo:asset handler:^(AVPlayerItem *playerItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [IMGPlayerManager shareManager].delegate = self;
            [[IMGPlayerManager shareManager] playWithItem:playerItem contentView:weakCell.iconView];
            [weakCell setPlayButtonHidden:YES];
        });
    }];
    
}

#pragma mark - IMGPlayerDelegate
- (void)playerDidPlayToEndTime:(IMGPlayerManager *)player {
    [self.playCell setPlayButtonHidden:NO];
    self.playCell = nil;
}

- (void)playerDidPlayWithError:(NSError *)error {
    [self.playCell setPlayButtonHidden:NO];
    self.playCell = nil;
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IMGPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FYPrivewCell" forIndexPath:indexPath];
    PHAsset *asset = _assets[indexPath.item];
    cell.model = asset;
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[IMGPreviewCell class]]) {
        [[(IMGPreviewCell *)cell scrollView] setZoomScale:1.0 animated:NO];
        [(IMGPreviewCell *)cell loadImage];
    }
//    NSLog(@"willDisplayCellAtIndexPath:%@",indexPath);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[IMGPreviewCell class]]) {
        IMGPreviewCell *preivewCell = (IMGPreviewCell *)cell;
        [[preivewCell scrollView] setZoomScale:1.0 animated:NO];
        
        // stop play live photo
        if (@available(iOS 9.1, *)) {
            if (preivewCell.model.mediaSubtypes==PHAssetMediaSubtypePhotoLive) {
                [[IMGPlayerManager shareManager] stopPlayLivePhoto];
                self.playLiveCell = nil;
            }
        }
        
        // stop play video
        if (preivewCell.model.mediaType==PHAssetMediaTypeVideo) {
            [self.playCell setPlayButtonHidden:NO];
            self.playCell = nil;
            [[IMGPlayerManager shareManager] stop];
        }
    }
//    NSLog(@"didEndDisplayingCell:%@",indexPath);
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==self.collectionView) {
        
        CGPoint point = [self.collectionView convertPoint:self.operationView.center fromView:self.operationView.superview];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        
        
        
        //  NSLog(@"%@",indexPath);
        [self needShowCellAtIndexPath:indexPath];
        
        
    }
}

#pragma mark - Setter Getter

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[IMGPreviewCell class] forCellWithReuseIdentifier:@"FYPrivewCell"];
    }
    return _collectionView;
}

- (IMGPreviewOperationView *)operationView
{
    if (!_operationView) {
        _operationView = [IMGPreviewOperationView new];
        _operationView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(operationViewTap:)];
        [_operationView addGestureRecognizer:tap];
        [_operationView.closedButton addTarget:self action:@selector(closedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.selectedButton addTarget:self action:@selector(userClickedSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationView;
}

- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = self.view.frame.size;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 10;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

@end
