//
//  SettingViewController.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/4/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "SettingViewController.h"
#import "IMGPickerManagerHeader.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)chooseVideo:(id)sender {
    [IMGConfigManager shareManager].mediaType = IMGAssetMediaTypeVideo;
}
- (IBAction)chooseImage:(id)sender {
    [IMGConfigManager shareManager].mediaType = IMGAssetMediaTypeImage;
}
- (IBAction)chooseAllType:(id)sender {
    [IMGConfigManager shareManager].mediaType = IMGAssetMediaTypeAll;
}
- (IBAction)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
