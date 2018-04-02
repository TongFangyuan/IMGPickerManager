//
//  ViewController.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/4/2.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "ViewController.h"
#import "IMGPickerManagerHeader.h"

@interface ViewController ()

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

- (IBAction)chooseAction:(id)sender {
    
    [IMGPickerManager start:^(NSArray *result, NSError *error) {
        if (!error) {
            NSLog(@"%@",result);
        }else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}

@end
