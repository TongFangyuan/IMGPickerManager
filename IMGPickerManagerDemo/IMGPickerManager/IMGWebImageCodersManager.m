//
//  IMGWebImageCodersManager.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGWebImageCodersManager.h"
#import "IMGWebImageGIFCoder.h"
#import "IMGWebImageImageIOCoder.h"

@interface IMGWebImageCodersManager ()

@property (nonatomic, strong, nonnull) NSMutableArray<IMGWebImageCoder> *mutableCoders;
@property (nonatomic, strong, nullable) dispatch_queue_t mutableCodersAccessQueue;

@end

@implementation IMGWebImageCodersManager

+ (nonnull instancetype)shareInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self =[super init]) {
        // initialize with default coders
        _mutableCoders = [@[[IMGWebImageImageIOCoder sharedCoder]] mutableCopy];
        _mutableCodersAccessQueue = dispatch_queue_create("com.tongfy.IMGImageCodersManager", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - Coder IO operations
- (void)addCoder:(id<IMGWebImageCoder>)coder {
    if ([coder conformsToProtocol:@protocol(IMGWebImageCoder)]) {
        dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
            [self.mutableCoders addObject:coder];
        });
    }
}

- (void)removeCoder:(id<IMGWebImageCoder>)coder {
    dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
        [self.mutableCoders removeObject:coder];
    });
}

- (NSArray<IMGWebImageCoder> *)coders {
    __block NSArray<IMGWebImageCoder> *sortedCoders = nil;
    dispatch_sync(self.mutableCodersAccessQueue, ^{
        sortedCoders = (NSArray<IMGWebImageCoder> *)[[[self.mutableCoders copy] reverseObjectEnumerator] allObjects];
    });
    return sortedCoders;
}

- (void)setCoders:(NSArray<IMGWebImageCoder> *)coders {
    dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
        self.mutableCoders = [coders mutableCopy];
    });
}

#pragma mark - IMGWebImageCoder

- (BOOL)canDecodeFromData:(NSData *)data {
    for (id<IMGWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:data]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)canEncodeToFormat:(IMGImageFormat)format {
    for (id<IMGWebImageCoder> coder in self.coders) {
        if ([coder canEncodeToFormat:format]) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)decodedImageWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    for (id<IMGWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:data]) {
            return [coder decodedImageWithData:data];
        }
    }
    return nil;
}

- (UIImage *)decompressedImageWithImage:(UIImage *)image
                                   data:(NSData *__autoreleasing  _Nullable *)data
                                options:(nullable NSDictionary<NSString*, NSObject*>*)optionsDict {
    if (!image) {
        return nil;
    }
    for (id<IMGWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:*data]) {
            return [coder decompressedImageWithImage:image data:data options:optionsDict];
        }
    }
    return nil;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(IMGImageFormat)format {
    if (!image) {
        return nil;
    }
    for (id<IMGWebImageCoder> coder in self.coders) {
        if ([coder canEncodeToFormat:format]) {
            return [coder encodedDataWithImage:image format:format];
        }
    }
    return nil;
}

@end
