//
//  IMGPickerTool.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/28.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGPickerManager.h"
#import "IMGPickerController.h"

@implementation IMGPickerManager

+ (void)start:(IMGCompleteBlock)completeBlock {
    
    UIViewController *rootCtr = [UIApplication sharedApplication].keyWindow.rootViewController;
    IMGPickerController *picker=[[IMGPickerController alloc] init];
    [picker setCompleteBlock:completeBlock];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:picker];
    [navController setNavigationBarHidden:YES animated:NO];
    [rootCtr presentViewController:navController animated:YES completion:nil];
}

@end
