//
//  FYImagePickerController.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/11.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import "IMGPickerController.h"
#import "IMGPickerManager.h"

#import "IMGConfigManager.h"
#import "IMGPhotoManager.h"
#import "IMGPickerAlbumsCell.h"
#import "IMGCameraCell.h"
#import "IMGPickerThumbCell.h"
#import "IMGPickerFlowLayout.h"
#import "IMGPickerTopBar.h"
#import "IMGPickerBottomBar.h"
#import "IMGPreviewController.h"
#import "PHAsset+IMGProperty.h"

static CGFloat kAlbumsCellHeight = 70;

@interface IMGPickerController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UITableViewDelegate,
UITableViewDataSource,
UIViewControllerPreviewingDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
IMGPickerThumbCellDelegate
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
@property (nonatomic,strong) IMGPickerTopBar *topBar;
@property (nonatomic,strong) IMGPickerBottomBar *bottomBar;
@property (nonatomic,strong) UIImagePickerController *imagePicker;

/// FYAsset 资源数组
@property (nonatomic,strong) NSArray<PHAsset *> *assets;
/// 选中的 FYAsset
@property (nonatomic,strong) NSMutableArray<PHAsset *> *selectedAssets;
/// PHAssetCollection 资源数组
@property (nonatomic,strong) NSArray<PHAssetCollection *> *assetCollections;
/// 当前选中的 PHAssetCollection
@property (nonatomic,strong) PHAssetCollection *selectedAssetCollection;

/// 动态约束
@property (nonatomic,strong) NSLayoutConstraint *dynamicConstraint;

@property (nonatomic,assign) CGSize imageSize;

@end

static NSString *kThubmbCellIdentifier = @"FYThumbCell";
static NSString *kCameraCellIdentifier = @"IMGCameraCell";

@implementation IMGPickerController

#pragma mark - LifeCycle

- (instancetype)init
{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.selectedAssets = [NSMutableArray array];
        self.assets = [NSArray array];
        self.assetCollections = [NSArray array];
        cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setNeedsStatusBarAppearanceUpdate];
   
    [self initSubviews];
    [self fetchAssetCollections];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    self.dynamicConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.f];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[constraint21,constraint22,constraint23,self.dynamicConstraint]];
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Event response

- (void)closedButtonAction:(UIButton *)button
{
    NSError *error = [NSError errorWithDomain:@"user cancel" code:100 userInfo:@{NSLocalizedDescriptionKey:@"用户取消"}];
    [[NSNotificationCenter defaultCenter] postNotificationName:IMGPickerManagerCancelPickNotification object:nil userInfo:@{@"error":error}];
}

- (void)doneButtonAction:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IMGPickerManagerWillPickCompleteNotification object:nil userInfo:@{@"data":self.selectedAssets}];
}

- (void)titleViewAction:(UITapGestureRecognizer *)tap
{
    BOOL show = !CGRectGetHeight(self.tableView.frame);
    
    if (show) {
        self.topBar.line.hidden = YES;
        
        [self.contentView removeConstraint:self.dynamicConstraint];
        self.dynamicConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-120.f];
        [self.contentView addConstraint:self.dynamicConstraint];
       
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
        

        [self.contentView removeConstraint:self.dynamicConstraint];
        self.dynamicConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:self.dynamicConstraint];
        
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

- (void)previewButtonAction:(id)sender {
    
    IMGPreviewController *previewController = [IMGPreviewController new];
    previewController.assets = self.selectedAssets;
    previewController.originalSelectedAssets = self.selectedAssets;
    
    __weak typeof(self) weakSelf = self;
    [previewController setCancelBlock:^(NSArray<PHAsset *> *asstes) {
        weakSelf.selectedAssets = [NSMutableArray arrayWithArray:asstes];
        [weakSelf reloadCollectionViewData];
    }];
    
    [self.navigationController pushViewController:previewController animated:YES];
    
}

/// 获取相册数据
- (void)fetchAssetCollections
{
    self.assetCollections = [IMGPhotoManager fetchAssetCollectionsForMediaType:[IMGConfigManager shareManager].mediaType];
    self.selectedAssetCollection = self.assetCollections.firstObject;
    selectedTableViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.topBar.titleLabel.text = self.selectedAssetCollection.localizedTitle;
    
    [self fetchAssets];
}

/// 获取某个相册中的所有照片
- (void)fetchAssets
{
    NSArray *results = [IMGPhotoManager fetchAssetsForMediaType:[IMGConfigManager shareManager].mediaType inAssetColelction:self.selectedAssetCollection];
    [IMGPhotoManager cacheImageForAsset:results targetSize:self.imageSize];
    
    self.assets = [NSArray arrayWithArray:results];
    [self.collectionView reloadData];
    
}

- (void)reloadCollectionViewData {
    
    //// 是否显示 cell 的 maskview
    countOverflow =  self.selectedAssets.count >= 9;
    
    //// topbar 选中图片数字和title颜色
    self.topBar.doneButton.enabled = self.selectedAssets.count;
    self.topBar.numberButton.hidden = !self.selectedAssets.count;
    [self.topBar.numberButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.selectedAssets.count] forState:UIControlStateNormal];
    
    //// bottomBar `预览` 按钮交互状态
    self.bottomBar.previewButton.enabled = self.selectedAssets.count;
    
    //// 刷新 collectionView
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];

}

#pragma mark - Notification
- (void)applicationDidBecomeActive:(NSNotification *)noti {
    
    [self fetchAssetCollections];
    [self.tableView reloadData];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ///////////// IMGCameraCell
    if (indexPath.row==0) {
        IMGCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCameraCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    /////////////// IMGPickerThumbCell
    PHAsset *asset = self.assets[indexPath.item-1];
    
    IMGPickerThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FYThumbCell" forIndexPath:indexPath];
    cell.asset = asset;
    cell.delegate = self;
    
    BOOL show = countOverflow&&!asset.select;
    [cell updateMaskViewStatus:show];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    // 3Dtouch
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
#pragma clang diagnostic pop
#endif
    return cell;
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //////////////// show UIImagePickerController
    if (indexPath.row==0) {
        
        if (!self.imagePicker) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.allowsEditing = [IMGConfigManager shareManager].allowsEditing;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [imagePicker setDelegate:self];
            self.imagePicker = imagePicker;
        }
        [self presentViewController:self.imagePicker animated:YES completion:nil];
        return;
    }
    
    //////////////// show IMGPreviewController
    IMGPreviewController *previewController = [IMGPreviewController new];
    previewController.assets = self.assets;
    previewController.originalSelectedAssets = self.selectedAssets;
    previewController.selectIndexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
    
    __weak typeof(self) weakSelf = self;
    [previewController setCancelBlock:^(NSArray<PHAsset *> *asstes) {
        weakSelf.selectedAssets = [NSMutableArray arrayWithArray:asstes];
        [weakSelf reloadCollectionViewData];
    }];
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMGPickerAlbumsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FYAlbumsCell"];
    PHAssetCollection *collection = self.assetCollections[indexPath.row];
    cell.titleLabel.text = collection.localizedTitle;
    cell.accessoryType = (collection==self.selectedAssetCollection) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    NSArray *assets = [IMGPhotoManager fetchAssetsForMediaType:[IMGConfigManager shareManager].mediaType inAssetColelction:collection];
    cell.numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)assets.count];
    
    // 设置封面图
    __weak typeof(cell) weakCell = cell;
    [IMGPhotoManager requestImageForAsset:assets.firstObject targetSize:self.imageSize handler:^(UIImage *image,IMGImageType type) {
        weakCell.iconView.image = image;
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedTableViewIndexPath == indexPath) return;
    
    self.assets = nil;
    [self.selectedAssets removeAllObjects];
    countOverflow = NO;
    
    // topbar 和 bottombar 联动
    self.topBar.doneButton.enabled = self.selectedAssets.count;
    self.topBar.numberButton.hidden = !self.selectedAssets.count;
    [self.topBar.numberButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.selectedAssets.count] forState:UIControlStateNormal];
    self.bottomBar.previewButton.enabled = self.selectedAssets.count;

    PHAssetCollection *collection = self.assetCollections[indexPath.row];
    self.selectedAssetCollection = collection;
    
    // tableview 刷新
    selectedTableViewIndexPath ? [self.tableView reloadRowsAtIndexPaths:@[selectedTableViewIndexPath] withRowAnimation:UITableViewRowAnimationNone] : nil;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    selectedTableViewIndexPath = indexPath;
    
    // 刷新数据源
    [self fetchAssets];
    
    // 收起弹窗
    [self titleViewAction:nil];
    
    self.topBar.titleLabel.text = self.selectedAssetCollection.localizedTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kAlbumsCellHeight;
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

#pragma mark - IMGPickerThumbCellDelegate

- (void)pickerThumbCellDidClickButton:(IMGPickerThumbCell *)cell
{
    PHAsset *asset = cell.asset;
    asset.select = !asset.select;
    [cell setButtonSelected:asset.select];
    
    // 保存或移除对应的 asset
    asset.select ? [self.selectedAssets addObject:asset] : [self.selectedAssets removeObject:asset];
    
    [self reloadCollectionViewData];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

#pragma mark - UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    UICollectionViewCell *cell = (UICollectionViewCell* )[previewingContext sourceView];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PHAsset *asset = self.assets[indexPath.item-1];
    
    IMGPreviewController *previewController = [IMGPreviewController new];
    previewController.assets = self.assets;
    previewController.originalSelectedAssets = self.selectedAssets;
    previewController.selectIndexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
    
    __weak typeof(previewController) weakController = previewController;
    [IMGPhotoManager requestImageDataForAsset:asset synchronous:YES handler:^(NSData *imageData,IMGImageType imageType) {
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        CGFloat width = CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds) - 40;
        CGFloat maxHeight = 500;
        CGFloat height = image.size.height/image.size.width * width;
        if (height>maxHeight) {
            height = maxHeight;
        }
        weakController.preferredContentSize = CGSizeMake(width, height);
    }];
    previewingContext.sourceRect = cell.bounds;
    
    return previewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

#pragma clang diagnostic pop
#endif

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ImageSavedPhotosAlbumCompletionHander
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (!error) {
        NSLog(@"imageSaveSuccess");
    } else {
        NSLog(@"imageSaveError:%@",error.localizedDescription);
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    ///刷新视图
    [self fetchAssets];
}

//MARK: -  setter and getter
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
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[IMGPickerFlowLayout new]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[IMGPickerThumbCell class] forCellWithReuseIdentifier:@"FYThumbCell"];
        [_collectionView registerClass:[IMGCameraCell class] forCellWithReuseIdentifier:@"IMGCameraCell"];
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
        [_tableView registerClass:[IMGPickerAlbumsCell class] forCellReuseIdentifier:@"FYAlbumsCell"];
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
- (IMGPickerTopBar *)topBar
{
    if (!_topBar) {
        _topBar = [IMGPickerTopBar new];
        [_topBar.closedButton addTarget:self action:@selector(closedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar.doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar.numberButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewAction:)];
        [_topBar.titleView addGestureRecognizer:tap];
        
    }
    return _topBar;
}

- (IMGPickerBottomBar *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [IMGPickerBottomBar new];
        [_bottomBar.previewButton addTarget:self action:@selector(previewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBar;
}

- (CGSize)imageSize{
    return CGSizeMake(kAlbumsCellHeight*[UIScreen mainScreen].scale, kAlbumsCellHeight*[UIScreen mainScreen].scale);
}

@end
