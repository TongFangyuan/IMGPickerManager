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

@interface FYImagePickerController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray<FYAsset *> *assets;

@end

@implementation FYImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PHFetchOptions *options = [PHFetchOptions new];
    options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    
    NSMutableArray *tempAssets = [NSMutableArray arrayWithCapacity:result.count];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FYAsset *asset = [FYAsset new];
        asset.asset = obj;
        [tempAssets addObject:asset];
    }];
    _assets = [NSArray arrayWithArray:tempAssets];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20-44) collectionViewLayout:[FYImageFlowLayout new]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[FYThumbCell class] forCellWithReuseIdentifier:@"FYThumbCell"];
    }
    return _collectionView;
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

@end
