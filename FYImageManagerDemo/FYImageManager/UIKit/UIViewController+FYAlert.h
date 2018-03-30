//
//  UIViewController+FYAlert.h
//  FYCategoryExample
//
//  Created by 童方园 on 16/4/22.
//  Copyright © 2016年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FYAlert)

/**
 *  普通弹窗提示
 *
 *  @param title   标题
 *  @param message 提示信息
 */
- (void)fy_showTitle:(NSString *)title message:(NSString *)message;

/**
 *  弹窗提示,有回调
 *
 *  @param title   标题
 *  @param message 提示信息
 *  @param confirmHandler 确认按钮回调
 */
- (void)fy_showTitle:(NSString *)title message:(NSString *)message confirmHandler:(void(^)(void))confirmHandler;
/**
 *  弹窗提示,有点击确定和取消的回调
 *
 *  @param title          标题
 *  @param message        提示信息
 *  @param confirmHandler 确认按钮回调
 *  @param cancelHandler  删除按钮回调
 */
- (void)fy_showTitle:(NSString *)title message:(NSString *)message confirmHandler:(void(^)(void))confirmHandler cancelHandler:(void(^)(void))cancelHandler;

@end
