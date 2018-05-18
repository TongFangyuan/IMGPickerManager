//
//  IMGRequestOptions.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/17.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGRequestOptions.h"

@implementation IMGRequestOptions

- (instancetype)init {
    if (self=[super init]) {
        
        _imageOptions = [PHImageRequestOptions new];
        _imageOptions.synchronous = NO;
        _imageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        
        _videoOptions = [PHVideoRequestOptions new];
        
        if (@available(iOS 9.1, *)) {
            _livePhotoOptions = [PHLivePhotoRequestOptions new];
        }
    }
    return self;
}

@end
