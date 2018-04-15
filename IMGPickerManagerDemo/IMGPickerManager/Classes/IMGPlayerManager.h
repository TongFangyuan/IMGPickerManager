//
//  IMGPlayerManager.h
//  IMGPickerManagerDemo
//
//  Created by 童方园 on 2018/4/15.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AVPlayerItem;
@class AVPlayer;
@class PHLivePhoto;
@class IMGPlayerManager;

@protocol IMGPlayerDelegate <NSObject>

@optional
- (void)playerDidPlayToEndTime:(IMGPlayerManager *)player;
- (void)playerDidPlayWithError:(NSError *)error;

@end

@interface IMGPlayerManager : NSObject

@property (nonatomic,weak) id<IMGPlayerDelegate> delegate;
+ (instancetype)shareManager;

#pragma mark - play video
- (void)playWithItem:(AVPlayerItem *)playItem contentView:(UIView *)contentView;
- (void)pause;
- (void)stop;


#pragma mark - play LivePhoto
- (void)playLivePhoto:(PHLivePhoto *)livePhoto contentView:(UIView *)contentView;
- (void)stopPlayLivePhoto;

@end
