//
//  SSImageProvider.m
//  SSFoundation
//
//  Created by Dante Sabatier on 24/07/13.
//
//

#import "SSImageProvider.h"
#import "SSImageDownloader.h"
#import "SSImageProviderWorker.h"
#import "SSImageProviderObserver.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIApplication.h>
#endif
#import "NSArray+SSAdditions.h"

@interface SSImageProvider () <SSDownloaderDelegate>

@end

@implementation SSImageProvider

static BOOL sharedImageProviderCanBeDestroyed = NO;
static SSImageProvider *sharedImageProvider = nil;

+ (instancetype)sharedImageProvider {
#if (!TARGET_OS_IPHONE && defined(__MAC_10_6)) || (TARGET_OS_IPHONE && defined(__IPHONE_4_0))
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id observedObject = nil;
        NSString *notificationName = nil;
#if TARGET_OS_IPHONE
        observedObject = [UIApplication sharedApplication];
        notificationName = UIApplicationWillTerminateNotification;
#else
        observedObject = NSApp;
        notificationName = NSApplicationWillTerminateNotification;
#endif
        sharedImageProvider = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:observedObject queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            
            sharedImageProviderCanBeDestroyed = YES;
            
            [sharedImageProvider release];
        }];
    });
#endif
    
    return sharedImageProvider;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _workers = [[NSMutableArray alloc] init];
        _observers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    if ((self == sharedImageProvider) && !sharedImageProviderCanBeDestroyed) {
        return;
    }
    
    [self cancelAllRequests];
    
    [_workers release];
    [_observers release];
    
    [super ss_dealloc];
}

- (void)provideCGImageAsynchronouslyForURL:(NSURL *)URL completionHandler:(void (^)(CGImageRef __nullable image, NSData * __nullable imageData, NSDictionary <NSString*, id>* __nullable imageProperties, SSImageProviderResult result,  NSError * __nullable error))handler {
    NSParameterAssert(URL != nil);
    NSParameterAssert(handler != nil);
    
    SSImageProviderWorker *worker = [[[SSImageProviderWorker alloc] initWithURL:URL] autorelease];
    worker.delegate = self;
    worker.block = handler;
    [worker start];
    
    [_workers addObject:worker];
}

- (id <NSObject>)addImageProviderObserverForURL:(NSURL *)URL queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(CGImageRef __nullable image, CGSize imageSize, SSImageProviderState state, long long loadedImageLength, long long expectedImageLength))block {
    NSParameterAssert(URL != nil);
    NSParameterAssert(block != nil);
    
    SSImageProviderObserver *observer = [[[SSImageProviderObserver alloc] init] autorelease];
    observer.URL = URL;
    observer.queue = queue;
    observer.block = block;
    
    [_observers addObject:observer];
    
    return [_observers lastObject];
}

- (void)removeImageProviderObserver:(id <NSObject>)observer {
    [_observers removeObject:observer];
}

- (void)cancelRequestForURL:(NSURL *)URL {
    [[(NSArray <SSImageProviderWorker *>*)_workers firstObjectPassingTest:^BOOL(SSImageProviderWorker * _Nonnull obj) {
        return [obj.URL isEqual:URL];
    }] cancel];
}

- (void)cancelAllRequests {
    [_workers makeObjectsPerformSelector:@selector(cancel)];
    [_observers removeAllObjects];
}

#pragma mark SSImageLoaderDelegate

- (void)downloaderDidStartLoading:(NSNotification *)notification {
    SSImageProviderWorker *worker = (SSImageProviderWorker *)notification.object;
    __ss_weak __typeof((NSMutableArray<SSImageProviderObserver*>*)_observers) observers = (NSMutableArray<SSImageProviderObserver*>*)_observers;
    for (SSImageProviderObserver *observer in observers) {
        if ([observer.URL isEqual:worker.URL]) {
            [observer.queue addOperationWithBlock:^{
                observer.block(worker.image, worker.imageSize, SSImageProviderStateBegin, worker.currentContentLength, worker.expectedContentLength);
            }];
        }
    }
}

- (void)downloaderDidUpdate:(NSNotification *)notification {
    SSImageProviderWorker *worker = (SSImageProviderWorker *)notification.object;
    __ss_weak __typeof((NSMutableArray<SSImageProviderObserver*>*)_observers) observers = (NSMutableArray<SSImageProviderObserver*>*)_observers;
    for (SSImageProviderObserver *observer in observers) {
        if ([observer.URL isEqual:worker.URL]) {
            [observer.queue addOperationWithBlock:^{
                observer.block(worker.image, worker.imageSize, SSImageProviderStateUpdate, worker.currentContentLength, worker.expectedContentLength);
            }];
        }
    }
}

- (void)downloaderDidFinishLoading:(NSNotification *)notification {
    SSImageProviderWorker *worker = (SSImageProviderWorker *)notification.object;
    __ss_weak __typeof((NSMutableArray<SSImageProviderObserver*>*)_observers) observers = (NSMutableArray<SSImageProviderObserver*>*)_observers;
    if ([observers isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *objs = [NSMutableArray arrayWithCapacity:observers.count];
        for (SSImageProviderObserver *observer in observers) {
            if ([observer.URL isEqual:worker.URL]) {
                [observer.queue addOperationWithBlock:^{
                    observer.block(worker.image, worker.imageSize, SSImageProviderStateEnd, worker.currentContentLength, worker.expectedContentLength);
                }];
            }
            [objs addObject:observer];
        }
        [observers removeObjectsInArray:objs];
    }
    
    worker.block(worker.image, worker.data, worker.imageProperties, worker.error ? SSImageProviderResultFailed : (worker.isCancelled ? SSImageProviderResultCancelled : SSImageProviderResultSucceeded), worker.error);
    
    __ss_weak __typeof(_workers) workers = _workers;
    [workers removeObject:worker];
}

#pragma mark getters & setters

- (NSArray <NSURL *> *)URLs {
    return [_workers valueForKey:@"URL"];
}

@end
