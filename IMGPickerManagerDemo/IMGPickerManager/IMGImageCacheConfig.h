//
//  IMGImageCacheConfig.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGPickerCompat.h"

@interface IMGImageCacheConfig : NSObject

/**
 * Decompressing images that are downloaded and cached can improve preformance but can consume lot of memory.
 * Defaults to YES. Set this to NO if you are experiencing a creash due to excessive memory consunption.
 */
@property (nonatomic, assign) BOOL shouldDecompressImages;


/**
 * disable iCloud bakup [defaults is YES]
 */
@property (nonatomic, assign) BOOL shouldDisableiCloud;

/**
 * use memory cache [defaults is YES
 */
@property (nonatomic, assign) BOOL shouldCacheImagesInMemory;

/**
 * The reading options while reading cache from disk.
 * Defaults to 0. You can set this to `NSDataReadingMappedIfSafe` to improve performance.
 */
@property (assign, nonatomic) NSDataReadingOptions diskCacheReadingOptions;

/**
 * The writing options while writing cache to disk.
 * Defaults to `NSDataWritingAtomic`. You can set this to `NSDataWritingWithoutOverwriting` to prevent overwriting an existing file.
 */
@property (assign, nonatomic) NSDataWritingOptions diskCacheWritingOptions;

/**
 * The maximum length of time to keep an image in the cache, in seconds.
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) NSUInteger maxCacheSize;

@end
