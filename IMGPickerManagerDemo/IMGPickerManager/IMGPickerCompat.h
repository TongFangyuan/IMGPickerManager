//
//  IMGPickerCompat.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import <TargetConditionals.h>
#import <UIKit/UIKit.h>

// iOS and tvOS are very similar, UIKit exists on both platforms
// Note: watchOS also has UIKit, but it's very limited
#if TARGET_OS_IOS || TARGET_OS_TV
#define IMG_UIKIT 1
#else
#define IMG_UIKIT 0
#endif

FOUNDATION_EXPORT UIImage *IMGScaledImageForKey(NSString *key, UIImage *image);

typedef void(^IMGPickerNoParamsBlock)(void);

#ifndef dispatch_queue_async_safe
#define dispatch_queue_async_safe(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
block();\
} else {\
dispatch_async(queue, block);\
}
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif
