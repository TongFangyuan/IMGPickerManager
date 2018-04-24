//
//  IMGPikcerHeader.h
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/4/24.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#ifndef IMGPikcerHeader_h
#define IMGPikcerHeader_h

#ifdef DEBUG
    #define NSLog(format, ...) do {                                             \
    fprintf(stderr, "<%s : %d> %s\n",                                           \
    [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
    __LINE__, __func__);                                                        \
    (NSLog)((format), ##__VA_ARGS__);                                           \
    fprintf(stderr, "-------\n");                                               \
    } while (0)
#endif


#import <Masonry/Masonry.h>
#import "IMGRotateProtocol.h"
#import "UIView+SuitableSize.h"
#import "UIImage+animatedGIF.h"

#endif /* IMGPikcerHeader_h */
