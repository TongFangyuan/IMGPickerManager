//
//  ViewController.m
//  IMGPickerManagerDemo
//
//  Created by tongfangyuan on 2018/4/2.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "ViewController.h"
#import "IMGPickerManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic,strong) PHAsset *asset;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView.hidden=YES;
    self.playButton.hidden=YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseAction:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [IMGPickerManager startChoose:^(NSArray<PHAsset *> *results, NSError *error) {
        if (!error) {
            NSLog(@"user chosse %@",results);
            if(results.count){
                PHAsset *asset = results.firstObject;
                weakSelf.asset = asset;

                CGFloat scale = [UIScreen mainScreen].scale;
                CGSize targetSize = CGSizeMake(weakSelf.imageView.frame.size.width*scale, weakSelf.imageView.frame.size.height*scale);

                /// request image for targetSize
                [IMGPhotoManager requestImageForAsset:asset targetSize:targetSize handler:^(UIImage *image, IMGMediaType imageType) {
                    weakSelf.imageView.image = image;
                    weakSelf.imageView.hidden = NO;
                    weakSelf.playButton.hidden = imageType!=IMGMediaTypeVideo;
                }];

                /// request original size image
//                [IMGPhotoManager requestImageDataForAsset:asset handler:^(NSData *imageData, IMGMediaType imageType) {
//                    weakSelf.imageView.image = [[UIImage alloc] initWithData:imageData];
//                    weakSelf.imageView.hidden = NO;
//                    weakSelf.playButton.hidden = imageType!=IMGMediaTypeVideo;
//                }];

                /// request data for asset
                [IMGPhotoManager requestDataForAsset:asset handler:^(NSData *mediaData, IMGMediaType mediaType) {
                    NSLog(@"mediaType=%ld dataLength=%lu",(long)mediaType,(unsigned long)mediaData.length);
                }];
            }
        }
    }];
    
//    [IMGPickerManager startChooseForType:IMGAssetMediaTypeAll block:^(NSArray<PHAsset *> *results, NSError *error) {
//        NSLog(@"%@",results);
//    }];

}

- (IBAction)playButtonAction:(id)sender {
    
}



@end
