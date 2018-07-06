//
//  FYImagePickerController.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2017/11/11.
//  Copyright © 2017年 tongfangyuan. All rights reserved.
//

#import "IMGPikcerHeader.h"

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
#import "IMG3DTouchViewController.h"
#import "UIImageView+Cache.h"

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
}

/// 图片选择视图
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) IMGPickerFlowLayout *layout;
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

@property (nonatomic,assign) CGSize imageSize;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setNeedsStatusBarAppearanceUpdate];
   
    [self initSubviews];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status==PHAuthorizationStatusNotDetermined) {
            NSLog(@"User has not yet made a choice with regards to this application");
        } else if (status==PHAuthorizationStatusDenied) {
            NSLog(@"User has explicitly denied this application access to photos data");
        } else if (status==PHAuthorizationStatusAuthorized) {
            [self fetchAssetCollections];;
        } else if (status==PHAuthorizationStatusRestricted) {
            NSLog(@"This application is not authorized to access photo data.");
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(20);
    }];
    
    [_topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(55.f);
    }];
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(47.f);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBar.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.bottomBar.mas_top);
    }];
    
    // maskview
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.collectionView);
    }];
    
    // tableview
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.maskView);
        make.height.mas_equalTo(0);
    }];
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
        NSInteger times = CGRectGetWidth(self.view.frame)<CGRectGetHeight(self.view.frame) ? 5 : 3;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kAlbumsCellHeight*times);
        }];
       
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

        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
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
    __weak typeof(self) weakSelf = self;
    IMGFetchCollectionsCompletionBlock completionBlock = ^(NSArray<PHAssetCollection *> * _Nullable collections){
        weakSelf.assetCollections = [collections copy];
        weakSelf.selectedAssetCollection = weakSelf.assetCollections.firstObject;
        selectedTableViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        weakSelf.topBar.titleLabel.text = weakSelf.selectedAssetCollection.localizedTitle;
        [weakSelf.tableView reloadData];
        [weakSelf fetchAssets];
    };
    [[IMGPhotoManager shareManager] loadCollectionsWithMediaType:[IMGConfigManager shareManager].targetMediaType completion:completionBlock];

}

/// 获取某个相册中的所有照片
- (void)fetchAssets
{
    __weak typeof(self) weakSelf = self;
    [[IMGPhotoManager shareManager] loadAssetsWithMediaType:[IMGConfigManager shareManager].targetMediaType inCollection:self.selectedAssetCollection completion:^(NSArray<PHAsset *> * _Nullable assets) {
        weakSelf.assets = assets.copy;
        [weakSelf.collectionView reloadData];
    }];
}

- (void)reloadCollectionViewData {
    
    //// 是否显示 cell 的 maskview
    countOverflow =  self.selectedAssets.count >= [IMGConfigManager shareManager].maxCount;
    
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

- (void)orientationDidChange:(NSNotification *)noti{
    UIDeviceOrientation orientation =[UIDevice currentDevice].orientation;
    if (orientation==UIDeviceOrientationPortraitUpsideDown) return;
    if (!UIDeviceOrientationIsPortrait(orientation) && !UIDeviceOrientationIsLandscape(orientation)) return;
    
    NSLog(@"orientation:%ld",(long)orientation);
    CGFloat contentViewTop = CGRectGetMinY(self.contentView.frame);
    CGFloat bottomHeight = CGRectGetHeight(self.bottomBar.frame);
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
        {
            contentViewTop = 20;
            bottomHeight = 47;
        } break;
        case UIDeviceOrientationLandscapeLeft:
        {
            contentViewTop = 0;
            bottomHeight = 35;
        } break;
        case UIDeviceOrientationLandscapeRight:
        {
            contentViewTop = 0;
            bottomHeight = 35;
        } break;
        default:
            break;
    }
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentViewTop);
    }];
    
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(bottomHeight);
    }];

    CGSize newItemSize = [self.layout reloadItemSize];
    if (!CGSizeEqualToSize(newItemSize, self.layout.itemSize)) {
        [self.collectionView.collectionViewLayout invalidateLayout];
        self.layout.itemSize = newItemSize;
        [self.collectionView reloadData];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
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
    
    // 3Dtouch
    if (@available(iOS 9.0, *)) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:cell];
        }
    }
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
            imagePicker.delegate = self;
            
            switch ([IMGConfigManager shareManager].targetMediaType) {
                case IMGAssetMediaTypeImage: {
                    imagePicker.mediaTypes = @[@"public.image"];
                } break;
                case IMGAssetMediaTypeVideo:{
                    imagePicker.mediaTypes = @[@"public.movie"];
                    imagePicker.videoQuality = (UIImagePickerControllerQualityType)[IMGConfigManager shareManager].videoQuality;
                    imagePicker.videoMaximumDuration = [IMGConfigManager shareManager].videoMaximumDuration;
                }break;
                case IMGAssetMediaTypeAll:{
                    imagePicker.mediaTypes = @[@"public.image",@"public.movie"];
                    imagePicker.videoQuality = (UIImagePickerControllerQualityType)[IMGConfigManager shareManager].videoQuality;
                    imagePicker.videoMaximumDuration = [IMGConfigManager shareManager].videoMaximumDuration;
                }break;
                default:
                    break;
            }
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
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) wSelf = self;
    [[IMGPhotoManager shareManager] loadAssetsWithMediaType:[IMGConfigManager shareManager].targetMediaType inCollection:collection completion:^(NSArray<PHAsset *> * _Nullable assets) {
        weakCell.numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)assets.count];
        __strong typeof(weakCell) ssCell = weakCell;
        [ssCell.iconView img_setImageWithAsset:assets.firstObject targetSize:wSelf.imageSize];
        
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
    
    IMG3DTouchViewController *previewController = [IMG3DTouchViewController new];
    previewController.asset = asset;
    __weak typeof(previewController) weakController = previewController;
    [IMGPhotoManager requestImageDataForAsset:asset synchronous:NO handler:^(NSData *imageData,IMGMediaType imageType) {
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        weakController.imageView.image = imageType==IMGMediaTypeGif ? [UIImage animatedImageWithAnimatedGIFData:imageData]:image;
    }];
    
    CGFloat width = CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds) - 40;
    CGFloat maxHeight = 500;
    weakController.preferredContentSize = [UIView fitSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) toSize:CGSizeMake(width, maxHeight)];
    previewingContext.sourceRect = cell.bounds;

    self.selectedIndexPath = indexPath;
    
    return previewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{

    IMGPreviewController *previewController = [IMGPreviewController new];
    previewController.assets = self.assets;
    previewController.originalSelectedAssets = self.selectedAssets;
    previewController.selectIndexPath = [NSIndexPath indexPathForRow:(self.selectedIndexPath.row-1) inSection:self.selectedIndexPath.section];
    
    __weak typeof(self) weakSelf = self;
    [previewController setCancelBlock:^(NSArray<PHAsset *> *asstes) {
        weakSelf.selectedAssets = [NSMutableArray arrayWithArray:asstes];
        [weakSelf reloadCollectionViewData];
    }];
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma clang diagnostic pop
#endif

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (!image) {
            image = info[UIImagePickerControllerOriginalImage];
        }
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    } else if ([mediaType isEqualToString:@"public.movie"]){
        NSURL *fileURL = info[UIImagePickerControllerMediaURL];
        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileURL.path))
        {
            UISaveVideoAtPathToSavedPhotosAlbum(fileURL.path,self,@selector(video:didFinishSavingWithError:contextInfo:),nil);
        }

    }
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
    [self fetchAssets];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (!error) {
        NSLog(@"videoSaveSuccess");
    } else {
        NSLog(@"videoSaveError:%@",error.localizedDescription);
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self fetchAssets];
}

//MARK: -  setter and getter
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[IMGPickerThumbCell class] forCellWithReuseIdentifier:@"FYThumbCell"];
        [_collectionView registerClass:[IMGCameraCell class] forCellWithReuseIdentifier:@"IMGCameraCell"];
    }
    return _collectionView;
}

- (IMGPickerFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[IMGPickerFlowLayout alloc] init];
    }
    return _layout;
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
        _bottomBar.backgroundColor = [UIColor whiteColor];
        [_bottomBar.previewButton addTarget:self action:@selector(previewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBar;
}

- (CGSize)imageSize{
    return CGSizeMake(kAlbumsCellHeight*[UIScreen mainScreen].scale, kAlbumsCellHeight*[UIScreen mainScreen].scale);
}

@end
