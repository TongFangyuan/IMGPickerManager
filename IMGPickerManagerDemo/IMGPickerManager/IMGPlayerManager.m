//
//  IMGPlayerManager.m
//  IMGPickerManagerDemo
//
//  Created by 童方园 on 2018/4/15.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "IMGConfigManager.h"

static IMGPlayerManager *_shareManager = nil;

@interface IMGPlayerManager()
<
PHLivePhotoViewDelegate
>

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_1
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (nonatomic,strong) PHLivePhotoView *livePhotoView;

#pragma clang diagnostic pop
#endif

@end

@implementation IMGPlayerManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [[[self class] alloc] init];
    });
    return _shareManager;
}

- (instancetype)init{
    if (self=[super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}
- (void)playWithItem:(AVPlayerItem *)playItem contentView:(UIView *)contentView
{
    
    if (self.player) {
        [self stop];
    }
    
    if (!playItem) {
        if ([self.delegate respondsToSelector:@selector(playerDidPlayWithError:)]) {
            [self.delegate playerDidPlayWithError:[NSError errorWithDomain:@"playItem error" code:404 userInfo:nil]];
        }
        NSLog(@"error: playItem is nil");
        return;
    }
    
    self.player = [AVPlayer playerWithPlayerItem:playItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer = playerLayer;
    playerLayer.frame = contentView.layer.bounds;
    [contentView.layer addSublayer:playerLayer];
    
    [self.player play];
}

- (void)pause
{
    if (self.player) {
        [self.player pause];
    }
}

- (void)resume
{
    if (self.player) {
        [self.player play];
    }
}

- (void)stop
{
    
    if (self.player) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
        [self.player pause];
        self.player = nil;
    }
    
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
}

- (void)playerItemDidPlayToEndTime:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(playerDidPlayToEndTime:)]) {
        [self.delegate playerDidPlayToEndTime:self];
    }
    [self stop];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

#pragma mark - play livePhoto
- (void)playLivePhoto:(PHLivePhoto *)livePhoto contentView:(UIView *)contentView{
    if (![IMGConfigManager shareManager].allowLivePhoto) {
        return;
    }
    
    if (self.livePhotoView) {
        [self stopPlayLivePhoto];
    }
    
    if (!livePhoto) {
        NSLog(@"play livephoto error: livePhoto is nil");
        return;
    }
    
    
    self.livePhotoView = [[PHLivePhotoView alloc] initWithFrame:contentView.bounds];
    [contentView addSubview:self.livePhotoView];
    self.livePhotoView.livePhoto = livePhoto;
    self.livePhotoView.delegate = self;
    self.livePhotoView.muted = YES;
    self.livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
}

- (void)stopPlayLivePhoto{
    if (self.livePhotoView) {
        [self.livePhotoView stopPlayback];
        [self.livePhotoView removeFromSuperview];
        self.livePhotoView.livePhoto = nil;
        self.livePhotoView=nil;
    }
}

#pragma mark - PHLivePhotoViewDelegate
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle{
    [self stopPlayLivePhoto];
}

#pragma clang diagnostic pop

@end
