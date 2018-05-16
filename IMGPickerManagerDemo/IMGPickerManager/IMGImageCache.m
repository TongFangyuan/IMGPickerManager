//
//  IMGImageCache.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "IMGImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "IMGWebImageCodersManager.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

FOUNDATION_STATIC_INLINE NSUInteger IMGCacheCostForImage(UIImage *image) {
    return image.size.height * image.size.width * image.scale * image.scale;
}

// A memory cache which auto purge the cache on memory warning and support weak cache.
@interface IMGMemoryCache <KeyType, ObjectType> : NSCache <KeyType, ObjectType>

@end

// Private
@interface IMGMemoryCache <KeyType, ObjectType> ()

@property (nonatomic, strong, nonnull) NSMapTable<KeyType, ObjectType> *weakCache; // strong-weak cache
@property (nonatomic, strong, nonnull) dispatch_semaphore_t weakCacheLock; // a lock to keep the access to `weakCache` thread-safe

@end

@implementation IMGMemoryCache

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Use a strong-weak maptable storing the secondary cache. Follow the doc that NSCache does not copy keys
        // This is useful when the memory warning, the cache was purged. However, the image instance can be retained by other instance such as imageViews and alive.
        // At this case, we can sync weak cache back and do not need to load from disk cache
        self.weakCache = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        self.weakCacheLock = dispatch_semaphore_create(1);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    // Only remove cache, but keep weak cache
    [super removeAllObjects];
}

// `setObject:forKey:` just call this with 0 cost. Override this is enough
- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
    [super setObject:obj forKey:key cost:g];
    if (key && !obj) {
        // Store weak cache
        LOCK(self.weakCacheLock);
        [self.weakCache setObject:obj forKey:key];
        UNLOCK(self.weakCacheLock);
    }
}

- (id)objectForKey:(id)key {
    id obj = [super objectForKey:key];
    if (key && !obj) {
        // Check weak cache
        LOCK(self.weakCacheLock);
        obj = [self.weakCache objectForKey:key];
        UNLOCK(self.weakCacheLock);
        if (obj) {
            // Sync cache
            NSUInteger cost = 0;
            if ([obj isKindOfClass:[UIImage class]]) {
                cost = IMGCacheCostForImage(obj);
            }
            [super setObject:obj forKey:key cost:cost];
        }
    }
    return obj;
}

- (void)removeAllObjects {
    [super removeAllObjects];
    // Manually remove should also remove weak cache
    LOCK(self.weakCacheLock);
    [self.weakCache removeAllObjects];
    UNLOCK(self.weakCacheLock);
}

@end

@interface IMGImageCache ()

#pragma mark - Properties
@property (strong, nonatomic, nonnull) IMGMemoryCache                *memCache;
@property (strong, nonatomic, nonnull) NSString                      *diskCachePath;
@property (strong, nonatomic, nonnull) NSMutableArray<NSString *>    *customPaths;
@property (strong, nonatomic, nullable) dispatch_queue_t             ioQueue;
@property (strong, nonatomic, nonnull) NSFileManager                 *fileManager;

@end


@implementation IMGImageCache

#pragma mark - Singleton, init dealloc

+ (nonnull instancetype)shareImageCache {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithNamespace:@"default"];
}

- (instancetype)initWithNamespace:(NSString *)ns {
    NSString *path = [self makeDiskCachePath:ns];
    return [self initWithNamespace:ns diskCacheDirectory:path];
}

- (instancetype)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory {
    if ((self = [super init])) {
        NSString *fullNamespace = [@"com.tongfy.IMGImageCache." stringByAppendingString:ns];
        
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.tongfy.IMGImageCache", DISPATCH_QUEUE_SERIAL);
        
        _config = [[IMGImageCacheConfig alloc] init];
        
        // Init the memory cache
        _memCache = [[IMGMemoryCache alloc] init];
        _memCache.name = fullNamespace;
        
        // Init the disk cache
        if (directory != nil) {
            _diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
        } else {
            NSString *path = [self makeDiskCachePath:ns];
            _diskCachePath = path;
        }
        
        dispatch_sync(_ioQueue, ^{
            self.fileManager = [NSFileManager new];
        });
        
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deleteOldFiles) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundDeleteOldFiles) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Cache paths

- (void)addReadOnlyCachePath:(nonnull NSString *)path {
    if (!self.customPaths) {
        self.customPaths = [NSMutableArray new];
    }
    if (![self.customPaths containsObject:path]) {
        [self.customPaths addObject:path];
    }
}

- (nullable NSString *)cachePathForKey:(nullable NSString *)key inPath:(nonnull NSString *)path {
    NSString *fileName = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:fileName];
}

- (nullable NSString *)defaultCachePathForKey:(nullable NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

- (nullable NSString *)cachedFileNameForKey:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], ext.length == 0 ? @"" : [NSString stringWithFormat:@".%@", ext]];
    return filename;
}

- (nullable NSString *)makeDiskCachePath:(nonnull NSString *)fullNamespace {
    NSArray<NSString *> *pahts = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [pahts[0] stringByAppendingPathComponent:fullNamespace];
}

#pragma mark - Store Ops

- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key
        completion:(IMGPickerNoParamsBlock)completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:YES completion:completionBlock];
}

- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key
            toDisk:(BOOL)toDisk
        completion:(IMGPickerNoParamsBlock)completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:toDisk completion:completionBlock];
}

- (void)storeImage:(UIImage *)image
         imageData:(NSData *)imageData
            forKey:(NSString *)key
            toDisk:(BOOL)toDisk
        completion:(IMGPickerNoParamsBlock)completionBlock {
    if (!image || !key) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    // if memory cache is enableed
    if (self.config.shouldCacheImagesInMemory) {
        NSUInteger cost = IMGCacheCostForImage(image);
        [self.memCache setObject:image forKey:key cost:cost];
    }
    
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            @autoreleasepool {
                NSData *data = imageData;
                if (!data && image) {
                    // If we do not have any data to detect image format, check whether it contains alpha channel to use PNG or JPEG format
                    IMGImageFormat format;
                    if (IMGCGImageRefContainsAlpha(image.CGImage)) {
                        format = IMGImageFormatPNG;
                    } else {
                        format = IMGImageFormatJPEG;
                    }
                    data = [[IMGWebImageCodersManager shareInstance] encodedDataWithImage:image format:format];
                }
                [self _storeImageDataToDisk:data forKey:key];
            }
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
            }
        });
    } else {
        if (completionBlock) completionBlock();
    }
}

- (void)storeImageDataToDisk:(NSData *)imageData forKey:(NSString *)key {
    if (!imageData || !key) return;
    
    dispatch_async(self.ioQueue, ^{
        [self _storeImageDataToDisk:imageData forKey:key];
    });
}

// Make sure to call form io queue by caller
- (void)_storeImageDataToDisk:(nullable NSData *)imageData forKey:(nullable NSString *)key {
    if (!imageData || !key) return;
    
    if (![self.fileManager fileExistsAtPath:_diskCachePath]) {
        [self.fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    // get cache Path for image key
    NSString *cachePathForKey = [self defaultCachePathForKey:key];
    // transform to NSUrl
    NSURL *fileURL = [NSURL fileURLWithPath:cachePathForKey];
    
    [imageData writeToURL:fileURL options:self.config.diskCacheWritingOptions error:nil];
    
    // disable iCloud backup
    if (self.config.shouldDisableiCloud) {
        [fileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

#pragma mark - Query and Retrieve Ops

- (void)diskImageExistsWithKey:(NSString *)key completion:(IMGPickerCheckCacheCompletionBlcok)completionBlock {
    dispatch_async(self.ioQueue, ^{
        BOOL exists = [self _diskImageDataExistsWithKey:key];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

- (BOOL)diskImageDataExistsWithKey:(NSString *)key {
    if (!key) return NO;
    
    __block BOOL exists = NO;
    dispatch_sync(self.ioQueue, ^{
        exists = [self _diskImageDataExistsWithKey:key];
    });
    
    return exists;
}

// Make sure to call form io queue by caller
- (BOOL)_diskImageDataExistsWithKey:(nullable NSString *)key {
    if (!key) return NO;
    
    BOOL exists = [self.fileManager fileExistsAtPath:[self defaultCachePathForKey:key]];
    
    // checking the key with and without the extension
    if (!exists) {
        exists = [self.fileManager fileExistsAtPath:[self defaultCachePathForKey:key].stringByDeletingPathExtension];
    }
    return exists;
}

- (nullable UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
    return [self.memCache objectForKey:key];
}

- (nullable UIImage *)imageFromDiskCacheForKey:(NSString *)key {
    UIImage *diskImage = [self _diskImageForKey:key];
    if (diskImage && self.config.shouldCacheImagesInMemory) {
        NSUInteger cost = IMGCacheCostForImage(diskImage);
        [self.memCache setObject:diskImage forKey:key cost:cost];
    }
    return diskImage;
}

- (nullable UIImage *)imageFromCacheForKey:(NSString *)key {
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }
    // Second check the disk cache...
    image = [self imageFromDiskCacheForKey:key];
    return image;
}

- (nullable NSData *)_diskImageDataBySearchingAllPathsForKey:(nullable NSString *)key {
    if (!key) {
        return nil;
    }
    
    NSString *defaultPath = [self defaultCachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:defaultPath options:self.config.diskCacheReadingOptions error:nil];
    if (data) {
        return data;
    }
    
    // checking the key with and without the extension
    data = [NSData dataWithContentsOfFile:defaultPath.stringByDeletingPathExtension options:self.config.diskCacheReadingOptions error:nil];
    if (data) {
        return data;
    }
    
    NSArray<NSString *> *customPaths = [self.customPaths copy];
    for (NSString *path in customPaths) {
        NSString *filePath = [self cachePathForKey:key inPath:path];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath options:self.config.diskCacheReadingOptions error:nil];
        if (imageData) {
            return imageData;
        }
        
        // checking the key with and without the extension
        imageData = [NSData dataWithContentsOfFile:filePath.stringByDeletingPathExtension options:self.config.diskCacheReadingOptions error:nil];
        if (imageData) {
            return imageData;
        }
    }
    
    return nil;
}

- (nullable UIImage *)_diskImageForKey:(nullable NSString *)key {
    NSData *data = [self _diskImageDataBySearchingAllPathsForKey:key];
    return [self _diskImageForKey:key data:data];
}

- (nullable UIImage *)_diskImageForKey:(nullable NSString *)key data:(nullable NSData *)data {
    if (!data || !key) return nil;
    
    UIImage *image = [[IMGWebImageCodersManager shareInstance] decodedImageWithData:data];
    image = [self _scaleImageForKey:key image:image];
    if (self.config.shouldDecompressImages) {
        image = [[IMGWebImageCodersManager shareInstance] decompressedImageWithImage:image data:&data options:@{IMGWebImageCoderScaleDownLargeImagesKey: @(NO)}];
    }
    return image;
}

- (nullable UIImage *)_scaleImageForKey:(nullable NSString *)key image:(nullable UIImage *)image {
    return IMGScaledImageForKey(key, image);
}

- (nullable NSOperation *)queryCacheOperationForKey:(NSString *)key done:(IMGPickerQueryCompletedBlock)doneBlock{
    return [self queryCacheOperationForKey:key options:0 done:doneBlock];
}

- (nullable NSOperation *)queryCacheOperationForKey:(NSString *)key options:(IMGImageCacheOptions)options done:(IMGPickerQueryCompletedBlock)doneBlock {
    if (!key) {
        if (doneBlock) {
            doneBlock(nil, nil, IMGImageCacheTypeNone);
        }
        return nil;
    }
    
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    BOOL shouldQueryMemoryOnly = (image && !(options & IMGImageCacheQueryDataWhenInMemory));
    if (shouldQueryMemoryOnly) {
        if (doneBlock) {
            doneBlock(image, nil, IMGImageCacheTypeMemory);
        }
        return nil;
    }
    
    NSOperation *operation = [NSOperation new];
    void(^queryDiskBlock)(void) = ^{
        if (operation.isCancelled) {
            // do not call the completion if cancelled
            return ;
        }
        
        @autoreleasepool {
            NSData *diskData = [self _diskImageDataBySearchingAllPathsForKey:key];
            UIImage *diskImage;
            IMGImageCacheType cacheType = IMGImageCacheTypeDisk;
            if (image) {
                // the image is from in-memory cache
                diskImage = image;
                cacheType = IMGImageCacheTypeMemory;
            } else if (diskData) {
                // decode image data only of in-memory cache missed
                diskImage = [self _diskImageForKey:key data:diskData];
                if (diskImage && self.config.shouldCacheImagesInMemory) {
                    NSUInteger cost = IMGCacheCostForImage(diskImage);
                    [self.memCache setObject:diskData forKey:key cost:cost];
                }
            }
            
            if (doneBlock) {
                if (options & IMGImageCacheQueryDiskSync) {
                    doneBlock(diskImage, diskData, cacheType);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        doneBlock(diskImage, diskData, cacheType);
                    });
                }
            }
        }
    };
    
    if (options & IMGImageCacheQueryDiskSync) {
        queryDiskBlock();
    } else {
        dispatch_async(self.ioQueue, queryDiskBlock);
    }
    
    return operation;
}

#pragma mark - Remoce Ops

- (void)removeImageForKey:(NSString *)key withCompletion:(IMGPickerNoParamsBlock)completion {
    [self removeImageForKey:key fromDisk:YES withCompletion:completion];
}

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(IMGPickerNoParamsBlock)completion {
    if (!key) return;
    if (![key isKindOfClass:[NSString class]]) return;
    
    if (self.config.shouldCacheImagesInMemory) {
        [self.memCache removeObjectForKey:key];
    }
    
    if (fromDisk) {
        dispatch_async(self.ioQueue, ^{
            [self.fileManager removeItemAtPath:[self defaultCachePathForKey:key] error:nil];
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    } else if (completion) {
        completion();
    }
}

#pragma mark - Mem cache setting

- (void)setMaxMemoryCost:(NSUInteger)maxMemoryCost {
    self.memCache.totalCostLimit = maxMemoryCost;
}

- (NSUInteger)maxMemoryCost {
    return self.memCache.totalCostLimit;
}

- (NSUInteger)maxMemoryCountLimit {
    return self.memCache.countLimit;
}

- (void)setMaxMemoryCountLimit:(NSUInteger)maxCountLimit {
    self.memCache.countLimit = maxCountLimit;
}

#pragma mark - Cache clean Ops

- (void)clearMemory {
    [self.memCache removeAllObjects];
}

- (void)clearDiskOnCompletion:(IMGPickerNoParamsBlock)completion {
    dispatch_async(self.ioQueue, ^{
        [self.fileManager removeItemAtPath:self.diskCachePath error:nil];
        [self.fileManager createDirectoryAtPath:self.diskCachePath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:NULL];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)_deleteOldFiles {
    [self deleteOldFilesWithCompletionBlock:nil];
}

- (void)deleteOldFilesWithCompletionBlock:(IMGPickerNoParamsBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray<NSString *> *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        
        // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                       includingPropertiesForKeys:resourceKeys
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.config.maxCacheAge];
        NSMutableDictionary<NSURL *, NSDictionary<NSString *, id> *> *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        NSMutableArray<NSURL *> *urlsToDelete = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileEnumerator) {
            NSError *error;
            NSDictionary<NSString *, id> *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:&error];
            
            // Skip directories and errors.
            if (error || !resourceValues || [resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
            // Remove files that are older than the expiration date;
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            
            // Store a reference to this file and account for its total size.
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += totalAllocatedSize.unsignedIntegerValue;
            cacheFiles[fileURL] = resourceValues;
        }
        
        for (NSURL *fileURL in urlsToDelete) {
            [self.fileManager removeItemAtURL:fileURL error:nil];
        }
        
        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        if (self.config.maxCacheSize > 0 && currentCacheSize > self.config.maxCacheSize) {
            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = self.config.maxCacheSize / 2;
            
            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray<NSURL *> *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                                     usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                         return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                                     }];
            
            // Delete files until we fall below our desired cache size.
            for (NSURL *fileURL in sortedFiles) {
                if ([self.fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary<NSString *, id> *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= totalAllocatedSize.unsignedIntegerValue;
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }

    });
}

- (void)backgroundDeleteOldFiles {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    [self deleteOldFilesWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

#pragma mark - Cache Info

- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtPath:self.diskCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [self.fileManager attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}


- (NSUInteger)getDiskCount {
    __block NSUInteger count = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtPath:self.diskCachePath];
        count = fileEnumerator.allObjects.count;
    });
    return count;
}


- (void)calculateSizeWithCompletionBlock:(IMGPickerCalculateSizeBlock)completionBlock {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    
    dispatch_async(self.ioQueue, ^{
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                       includingPropertiesForKeys:@[NSFileSize]
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     errorHandler:NULL];
        
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += fileSize.unsignedIntegerValue;
            fileCount += 1;
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}














@end
