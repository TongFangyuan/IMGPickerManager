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
                [IMGPhotoManager requestImageForAsset:asset targetSize:weakSelf.imageView.frame.size handler:^(UIImage *image, IMGMediaType imageType) {
                    weakSelf.imageView.image = image;
                    weakSelf.imageView.hidden = NO;
                    weakSelf.playButton.hidden = imageType!=IMGMediaTypeVideo;
                }];
            }
        }
    }];

}

@end
