//
//  ViewController.m
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/11.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import "ViewController.h"
#import "IMGPicker.h"


@interface ViewController ()

- (IBAction)takePhotoAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)takePhotoAction:(id)sender {
    
    [IMGPickerTool start:^(NSArray *result, NSError *error) {
        if (!error) {
            NSLog(@"%@",result);
        }else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
//    [self presentViewController:[IMGPickerController new] animated:YES completion:nil];
}

@end
