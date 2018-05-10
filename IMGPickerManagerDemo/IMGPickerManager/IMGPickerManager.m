//
//  IMGPickerTool.m
//  FYImageManagerDemo
//
//  Created by tongfangyuan on 2018/3/28.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//


#import "IMGPickerManager.h"
#import <UIKit/UIKit.h>

typedef void(^IMGCompleteBlock)(NSArray<PHAsset *> *results,NSError *error);

static IMGPickerManager *_shareManager = nil;

@interface IMGPickerManager()

@property (nonatomic,copy) IMGCompleteBlock completeBlock;

@end


@implementation IMGPickerManager

+ (void)startChoose:(IMGCompleteBlock)completeBlock {
    [self startChooseForType:[IMGConfigManager shareManager].targetMediaType block:completeBlock];
}

+ (void)startChooseForType:(IMGAssetMediaType)type block:(void(^)(NSArray<PHAsset *> *results,NSError *error))completeBlock {
    [IMGConfigManager shareManager].targetMediaType = type;
    [IMGPickerManager shareManager].completeBlock = completeBlock;
    
    UIViewController *rootCtr = [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:NSClassFromString(@"IMGPickerController").new];
    [navController setNavigationBarHidden:YES animated:NO];
    [rootCtr presentViewController:navController animated:YES completion:nil];
}

#pragma mark - private
+ (instancetype)shareManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [[[self class] alloc] init];
    });
    return _shareManager;
}

- (instancetype)init{
    if (self=[super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willPickedCompleteNotification:) name:IMGPickerManagerWillPickCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelPickNotification:) name:IMGPickerManagerCancelPickNotification object:nil];
    }
    return self;
}

#pragma mark notification
- (void)willPickedCompleteNotification:(NSNotification *)sender{
    if (self.completeBlock) {
        NSArray<PHAsset *> *assets = [sender.userInfo objectForKey:@"data"];
        self.completeBlock(assets, nil);
    }
    
    UIViewController *rootCtr = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootCtr.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelPickNotification:(NSNotification *)sender{
    
    if (self.completeBlock) {
        NSError *error = [sender.userInfo objectForKey:@"error"];
        self.completeBlock(nil, error);
    }
    
    UIViewController *rootCtr = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootCtr.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end



NSNotificationName const IMGPickerManagerWillPickCompleteNotification = @"IMGPickerManagerWillPickCompleteNotification";
NSNotificationName const IMGPickerManagerCancelPickNotification = @"IMGPickerManagerCancelPickNotification";
