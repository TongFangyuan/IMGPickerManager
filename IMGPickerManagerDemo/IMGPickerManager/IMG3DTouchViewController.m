//
//  IMG3DTouchViewController.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/4/24.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMG3DTouchViewController.h"
#import "IMGPhotoManager.h"
#import "IMGPlayerManager.h"

@interface IMG3DTouchViewController ()

@end

@implementation IMG3DTouchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    IMGMediaType mediaType = [IMGPhotoManager getMediaTypeForAsset:self.asset];
    __weak typeof(self) weakSelf = self;
    switch (mediaType) {
        case IMGMediaTypeVideo:{
            //暂不支持
//            [IMGPhotoManager requestPlayerItemForVideo:self.asset handler:^(AVPlayerItem *playerItem) {
//                [[IMGPlayerManager shareManager] playWithItem:playerItem contentView:weakSelf.imageView];
//            }];
        }break;
        case IMGMediaTypeLivePhoto:{
            if (@available(iOS 9.1, *)) {
                [IMGPhotoManager requestLivePhotoForAsset:self.asset targetSize:weakSelf.imageView.frame.size handler:^(PHLivePhoto *livePhoto) {
                    [[IMGPlayerManager shareManager] playLivePhoto:livePhoto contentView:weakSelf.imageView];
                }];
            }
        }break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}



@end
