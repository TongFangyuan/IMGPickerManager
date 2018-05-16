//
//  IMGWebImageCodersManager.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGWebImageCoder.h"

/**
 Global object holding the array of coders, so that we avoid passing them from object to object.
 Uses a priority queue behind scenes, which means the latest added coders have the highest priority.
 This is done so when encoding/decoding something, we go through the list and ask each coder if they can handle the current data.
 That way, users can add their custom coders while preserving our existing prebuilt ones
 
 Note: the `coders` getter will return the coders in their reversed order
 Example:
 - by default we internally set coders = `IOCoder`, `WebPCoder`. (`GIFCoder` is not recommended to add only if you want to get GIF support without `FLAnimatedImage`)
 - calling `coders` will return `@[WebPCoder, IOCoder]`
 - call `[addCoder:[MyCrazyCoder new]]`
 - calling `coders` now returns `@[MyCrazyCoder, WebPCoder, IOCoder]`
 
 Coders
 ------
 A coder must conform to the `IMGWebImageCoder` protocol or even to `IMGWebImageProgressiveCoder` if it supports progressive decoding
 Conformance is important because that way, they will implement `canDecodeFromData` or `canEncodeToFormat`
 Those methods are called on each coder in the array (using the priority order) until one of them returns YES.
 That means that coder can decode that data / encode to that format
 */
@interface IMGWebImageCodersManager : NSObject<IMGWebImageCoder>

/**
 Shared reusable instance
 */
+ (nonnull instancetype)shareInstance;

/**
 All coders in coders manager. The coders array is a priority queue, which means the later added coder will have the highest priority
 */
@property (nonatomic, strong, readwrite, nullable) NSArray<IMGWebImageCoder>* coders;

/**
 Add a new coder to the end of coders array. Which has the highest priority.
 
 @param coder coder
 */
- (void)addCoder:(nonnull id<IMGWebImageCoder>)coder;

/**
 Remove a coder in the coders array.
 
 @param coder coder
 */
- (void)removeCoder:(nonnull id<IMGWebImageCoder>)coder;


@end
