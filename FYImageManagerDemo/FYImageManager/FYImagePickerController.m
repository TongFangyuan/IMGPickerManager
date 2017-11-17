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
#import "FYAlbumsCell.h"
#import "FYImagePrivewController.h"

@interface FYImagePickerController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UITableViewDelegate,
UITableViewDataSource
>
{
    /// 是否达到最大选择数量,控制 cell 是否展示 maskView;
    BOOL countOverflow;
    BOOL showTableView;
    NSIndexPath *selectedTableViewIndexPath;
    PHCachingImageManager *cachingImageManager;
}

/// 图片选择视图
@property (nonatomic,strong) UICollectionView *collectionView;
/// 相册选择视图
@property (nonatomic,strong) UITableView *tableView;
/// 遮罩视图(在tableView展开时显示,反之隐藏)
@property (nonatomic,strong) UIView *maskView;

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) PickerTopBar *topBar;
@property (nonatomic,strong) PickerBottomBar *bottomBar;

/// FYAsset 资源数组
@property (nonatomic,strong) NSArray<FYAssetModel *> *assets;
/// 选中的 FYAsset
@property (nonatomic,strong) NSMutableArray<FYAssetModel *> *selectedAssets;
/// PHAssetCollection 资源数组
@property (nonatomic,strong) NSArray<PHAssetCollection *> *assetCollections;
/// 当前选中的 PHAssetCollection
@property (nonatomic,strong) PHAssetCollection *selectedAssetCollection;

/// 动态约束
@property (nonatomic,strong) NSLayoutConstraint *dynamicConstraint;

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
        _assetCollections = [NSArray array];
        cachingImageManager = [PHCachingImageManager new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self setNeedsStatusBarAppearanceUpdate];
   
    [self initSubviews];
    [self fetchAssetCollections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - user action

- (void)cellButtonClicked:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
    FYAssetModel *asset = _assets[indexPath.item];
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

- (void)titleViewAction:(UITapGestureRecognizer *)tap
{
    BOOL show = !CGRectGetHeight(self.tableView.frame);
    
    if (show) {
        self.topBar.line.hidden = YES;
        
        [self.contentView removeConstraint:_dynamicConstraint];
        _dynamicConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-120.f];
        [self.contentView addConstraint:_dynamicConstraint];
       
        [self.maskView.superview bringSubviewToFront:self.maskView];
        [self.tableView.superview bringSubviewToFront:self.tableView];
        
        self.contentView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.contentView.userInteractionEnabled = YES;
            self.topBar.tipsLabel.text = @"轻触这里收起";
        }];
        
    } else {
        

        [self.contentView removeConstraint:_dynamicConstraint];
        _dynamicConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:_dynamicConstraint];
        
        self.contentView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.contentView.userInteractionEnabled = YES;
            self.topBar.tipsLabel.text = @"轻触更改相册";
            [self.maskView.superview sendSubviewToBack:self.maskView];
            self.topBar.line.hidden = NO;
        }];
    }
}

#pragma mark - Delegate and DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FYThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FYThumbCell" forIndexPath:indexPath];
    FYAssetModel *asset = [_assets objectAtIndex:indexPath.item];
    cell.model = asset;
    
    cell.button.tag = indexPath.row;
    [cell.button addTarget:self action:@selector(cellButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL show = countOverflow&&!asset.select;
    show ? [cell.maskView.superview bringSubviewToFront:cell.maskView] : [cell.maskView.superview sendSubviewToBack:cell.maskView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapMaskView:)];
    show ? [cell.maskView addGestureRecognizer:tap] : nil;
    cell.maskView.userInteractionEnabled = show;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FYImagePrivewController *previewController = [FYImagePrivewController new];
    previewController.assets = _assets;
    previewController.selectedAssets = _selectedAssets;
    previewController.selectIndexPath = indexPath;
    [self presentViewController:previewController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FYAlbumsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FYAlbumsCell"];
    PHAssetCollection *collection = _assetCollections[indexPath.row];
    cell.titleLabel.text = collection.localizedTitle;
    cell.accessoryType = (collection==_selectedAssetCollection) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    cell.numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)result.count];
    
    // 设置封面图
    PHAsset *thumAsset = result.firstObject;
    [[PHImageManager defaultManager] requestImageForAsset:thumAsset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.iconView.image = result;
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedTableViewIndexPath == indexPath) return;
    
    _assets = nil;
    [_selectedAssets removeAllObjects];
    countOverflow = NO;
    
    // topbar 和 bottombar 联动
    self.topBar.doneButton.enabled = _selectedAssets.count;
    self.topBar.numberButton.hidden = !_selectedAssets.count;
    [self.topBar.numberButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)_selectedAssets.count] forState:UIControlStateNormal];
    self.bottomBar.previewButton.enabled = _selectedAssets.count;
    
    PHAssetCollection *collection = _assetCollections[indexPath.row];
    _selectedAssetCollection = collection;
    
    // tableview 刷新
    selectedTableViewIndexPath ? [self.tableView reloadRowsAtIndexPaths:@[selectedTableViewIndexPath] withRowAnimation:UITableViewRowAnimationNone] : nil;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    selectedTableViewIndexPath = indexPath;
    
    // 刷新数据源
    [self fetchAssets];
    
    // 收起弹窗
    [self titleViewAction:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - Private

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

/// 获取相册数据
- (void)fetchAssetCollections
{
    
    PHFetchOptions *options = [PHFetchOptions new];
    if (@available(iOS 9.0,*)) {
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
    
    NSMutableArray<PHAssetCollection *> *tempAssetCollections = [NSMutableArray array];
    
    // 相机胶卷
    PHFetchResult<PHAssetCollection *> *cameraResults = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:options];
    [cameraResults enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempAssetCollections addObject:obj];
    }];
    
    // 最近添加
    PHFetchResult<PHAssetCollection *> *recentlyAddeds = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:options];
    [recentlyAddeds enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempAssetCollections addObject:obj];
    }];
    
    // 屏幕快照
    if (@available(iOS 9.0, *)) {
        PHFetchResult<PHAssetCollection *> *screenshots = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:options];
        [screenshots enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tempAssetCollections addObject:obj];
        }];
    }
    
    // 我的相册
    PHFetchResult<PHAssetCollection *> *userLibrary = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:options];
    [userLibrary enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempAssetCollections addObject:obj];
    }];
    
    _assetCollections = [NSArray arrayWithArray:tempAssetCollections];
    _selectedAssetCollection = _assetCollections.firstObject;
    selectedTableViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.topBar.tipsLabel.text = _selectedAssetCollection.localizedTitle;
    
    [_assetCollections enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
    }];
    
    [self fetchAssets];
}

/// 获取某个相册的照片
- (void)fetchAssets
{
    PHFetchOptions *options = [PHFetchOptions new];
    if (@available(iOS 9.0,*)) {
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:_selectedAssetCollection options:options];
    
    NSMutableArray<FYAssetModel *> *tempAssets = [NSMutableArray arrayWithCapacity:result.count];
    NSMutableArray<PHAsset *> *cacheAssets = [NSMutableArray arrayWithCapacity:result.count];
    [result enumerateObjectsUsingBlock:^(PHAsset  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FYAssetModel *asset = [FYAssetModel new];
        asset.asset = obj;
        [tempAssets addObject:asset];
        [cacheAssets addObject:obj];
    }];
    _assets = [NSArray arrayWithArray:tempAssets];
    
    // 缓存图片
    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
    [cachingImageManager startCachingImagesForAssets:cacheAssets targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFill options:requestOptions];
    
    [self.collectionView reloadData];
    
}

/// 初始化子视图
- (void)initSubviews
{
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.maskView];
    [self.contentView addSubview:self.topBar];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.bottomBar];
    [self.contentView addSubview:self.tableView];
    
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
    
    // maskview
    NSLayoutConstraint *constraint17 = [NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint18 = [NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint19 = [NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint20 = [NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.f];
    self.maskView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[constraint17,constraint18,constraint19,constraint20]];
    
    // tableview
    NSLayoutConstraint *constraint21 = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint22 = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.f];
    NSLayoutConstraint *constraint23 = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.f];
    _dynamicConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[constraint21,constraint22,constraint23,_dynamicConstraint]];

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

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[FYAlbumsCell class] forCellReuseIdentifier:@"FYAlbumsCell"];
        _tableView.separatorColor = [UIColor clearColor];
    }
    return _tableView;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    }
    return _maskView;
}
- (PickerTopBar *)topBar
{
    if (!_topBar) {
        _topBar = [PickerTopBar new];
        [_topBar.closedButton addTarget:self action:@selector(closedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar.doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar.numberButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewAction:)];
        [_topBar.titleView addGestureRecognizer:tap];
        
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
