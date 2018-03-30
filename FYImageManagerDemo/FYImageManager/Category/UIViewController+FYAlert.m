//
//  UIViewController+FYAlert.m
//  FYCategoryExample
//
//  Created by 童方园 on 16/4/22.
//  Copyright © 2016年 IOS. All rights reserved.
//

#import "UIViewController+FYAlert.h"

@implementation UIViewController (FYAlert)

- (void)fy_showTitle:(NSString *)title message:(NSString *)message
{
    [self fy_alertActionWithTitle:title message:message style:UIAlertActionStyleDefault handler:nil];
}

- (void)fy_showTitle:(NSString *)title message:(NSString *)message confirmHandler:(void(^)(void))confirmHandler{
    
    UIAlertAction *confirmAlertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirmHandler();
    }];
    
    [self fy_showTitle:title
                     message:message
           cancelAlertAction:nil
          confirmAlertAction:confirmAlertAction];
}

- (void)fy_showTitle:(NSString *)title
                   message:(NSString *)message
            confirmHandler:(void(^)(void))confirmHandler
             cancelHandler:(void(^)(void))cancelHandler{
    UIAlertAction *confirmAlertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirmHandler();
    }];
    
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        cancelHandler();
    }];
    
    [self fy_showTitle:title
                     message:message
           cancelAlertAction:cancelAlertAction
          confirmAlertAction:confirmAlertAction];
}


#pragma mark - private

- (void)fy_alertActionWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler
{
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:style handler:handler];
    [self fy_showTitle:title
                     message:message
           cancelAlertAction:nil
          confirmAlertAction:confirmAction];
    
}


- (void)fy_showTitle:(NSString *)title
                   message:(NSString *)message
        confirmAlertAction:(UIAlertAction *)confirmAlertAction{
    [self fy_showTitle:title
                     message:message
           cancelAlertAction:nil
          confirmAlertAction:confirmAlertAction];
}


/**
 *  弹出框控制器
 *
 *  @param title              标题
 *  @param message            提示信息
 *  @param cancelAlertAction  取消事件
 *  @param confirmAlertAction 确定事件
 */
- (void)fy_showTitle:(NSString *)title
                   message:(NSString *)message
         cancelAlertAction:(UIAlertAction *)cancelAlertAction
        confirmAlertAction:(UIAlertAction *)confirmAlertAction{
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelAlertAction) {
        [alert addAction:cancelAlertAction];
    }
    
    if (confirmAlertAction) {
        [alert addAction:confirmAlertAction];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
