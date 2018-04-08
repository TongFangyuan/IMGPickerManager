//
//  ViewController.m
//  IMGPickerManagerDemo
//
//  Created by tongfangyuan on 2018/4/2.
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
    
    self.view.backgroundColor = [UIColor greenColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseAction:(id)sender {
    
    [IMGPickerManager startChoose:^(NSArray<PHAsset *> *results, NSError *error) {
        if (!error) {
            NSLog(@"user chosse %@",results);
        }else {
            NSLog(@"chosse error: %@",error.localizedDescription);
        }
    }];
    
}

@end
