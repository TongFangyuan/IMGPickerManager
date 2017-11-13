//
//  FYAsset.h
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/13.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface FYAsset : NSObject

@property (nonatomic,strong) PHAsset *asset;
@property (nonatomic,assign) BOOL select;

@end
