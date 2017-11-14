//
//  FYImagePickerController.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/11.
//  Copyright © 2017年 tongfy. All rights reserved.
//


#import "FYImagePickerController.h"
#import "FYThumbCell.h"
#import "FYImageFlowLayout.h"
#import "PickerTopBar.h"
#import "PickerBottomBar.h"

@interface FYImagePickerController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>
{
    /// 是否达到最大选择数量,控制 cell 是否展示 maskView;
    BOOL countOverflow;
}

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) NSArray<FYAsset *> *assets;
@property (nonatomic,strong) PickerTopBar *topBar;
@property (nonatomic,strong) PickerBottomBar *bottomBar;
@property (nonatomic,strong) NSMutableArray<FYAsset *> *selectedAssets;

@end

@implementation FYImagePickerController

- (instancetype)init
{
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _maxCount = 9;
        _selectedAssets = [NSMutableArray array];
        _assets = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self setNeedsStatusBarAppearanceUpdate];
   
    [self initSubviews];
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FYThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FYThumbCell" forIndexPath:indexPath];
    FYAsset *asset = [_assets objectAtIndex:indexPath.item];
    cell.asset = asset;
    
    cell.button.tag = indexPath.row;
    [cell.button addTarget:self action:@selector(cellButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL show = countOverflow&&!asset.select;
    show ? [cell.maskView.superview bringSubviewToFront:cell.maskView] : [cell.maskView.superview sendSubviewToBack:cell.maskView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapMaskView:)];
    show ? [cell.maskView addGestureRecognizer:tap] : nil;
    cell.maskView.userInteractionEnabled = show;
    
    return cell;
}

- (void)cellButtonClicked:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
    FYAsset *asset = _assets[indexPath.item];
    asset.select = !asset.select;
    
    FYThumbCell *cell = (FYThumbCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    [cell setButtonSelected:asset.select];

    // 保存或移除对应的 asset
    asset.select ? [_selectedAssets addObject:asset] : [_selectedAssets removeObject:asset];
    
    // 是否显示 cell 的 maskview
    countOverflow =  _selectedAssets.count >= 9;
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    
    // topbar 和 bottombar 联动
    self.topBar.doneButton.enabled = _selectedAssets.count;
    self.topBar.numberButton.hidden = !_selectedAssets.count;
    [self.topBar.numberButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)_selectedAssets.count] forState:UIControlStateNormal];
    
    self.bottomBar.previewButton.enabled = _selectedAssets.count;
    
}

- (void)cellTapMaskView:(UITapGestureRecognizer *)tap
{
    NSLog(@"最多只能选择%ld张照片",(long)_maxCount);
}

- (void)closedButtonAction:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonAction:(UIButton *)button
{
    
}

#pragma mark - Private

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

/// 获取相册数据
- (void)requestData
{
    PHFetchOptions *options = [PHFetchOptions new];
    if (@available(iOS 9.0,*)) {
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    
    NSMutableArray *tempAssets = [NSMutableArray arrayWithCapacity:result.count];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FYAsset *asset = [FYAsset new];
        asset.asset = obj;
        [tempAssets addObject:asset];
    }];
    _assets = [NSArray arrayWithArray:tempAssets];
}

/// 初始化子视图
- (void)initSubviews
{
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.topBar];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.bottomBar];
    
    /// 约束
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.f];
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.f];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[constraint1,constraint2,constraint3,constraint4]];

    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:55.f];
    self.topBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[constraint5,constraint6,constraint7,constraint8]];
    
    NSLayoutConstraint *constraint13 = [NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8.f];
    NSLayoutConstraint *constraint14 = [NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint15 = [NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint16 = [NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:47.f];
    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[constraint13,constraint14,constraint15,constraint16]];
    
    NSLayoutConstraint *constraint9 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint10 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomBar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[constraint9,constraint10,constraint11,constraint12]];

}

//MARK:  property
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 8;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[FYImageFlowLayout new]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[FYThumbCell class] forCellWithReuseIdentifier:@"FYThumbCell"];
    }
    return _collectionView;
}

- (PickerTopBar *)topBar
{
    if (!_topBar) {
        _topBar = [PickerTopBar new];
        [_topBar.closedButton addTarget:self action:@selector(closedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar.doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar.numberButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBar;
}

- (PickerBottomBar *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [PickerBottomBar new];
    }
    return _bottomBar;
}

@end
