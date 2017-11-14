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

@interface FYImagePickerController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) NSArray<FYAsset *> *assets;
@property (nonatomic,strong) PickerTopBar *topBar;

@end

@implementation FYImagePickerController

- (instancetype)init
{
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _maxCount = 9;
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
    cell.asset = [_assets objectAtIndex:indexPath.item];
    
    cell.button.tag = indexPath.row;
    [cell.button addTarget:self action:@selector(cellButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)cellButtonClicked:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
    FYAsset *asset = _assets[indexPath.item];
    asset.select = !asset.select;
    
    FYThumbCell *cell = (FYThumbCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    [cell setButtonSelected:asset.select];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - private

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
    
    /// 约束
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.f];
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.f];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[constraint1,constraint2,constraint3,constraint4]];

    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:55.f];
    self.topBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[constraint5,constraint6,constraint7,constraint8]];
    
    NSLayoutConstraint *constraint9 = [NSLayoutConstraint constraintWithItem:self.topBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint10 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.f];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[constraint9,constraint10,constraint11,constraint12]];

}

#pragma mark  property

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
    }
    return _topBar;
}



@end
