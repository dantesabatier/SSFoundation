//
//  SSImageProvider.h
//  SSFoundation
//
//  Created by Dante Sabatier on 24/07/13.
//
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <graphics/SSImage.h>
#else
#import <SSGraphics/SSImage.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSImageProviderResult) {                 
    SSImageProviderResultSucceeded,
	SSImageProviderResultFailed,
	SSImageProviderResultCancelled,
} NS_SWIFT_NAME(SSImageProvider.ImageProviderResult);

typedef NS_ENUM(NSInteger, SSImageProviderState) {
    SSImageProviderStateBegin,
    SSImageProviderStateUpdate,
    SSImageProviderStateEnd,
} NS_SWIFT_NAME(SSImageProvider.ImageProviderState);

NS_CLASS_AVAILABLE(10_6, 4_0)
@interface SSImageProvider : NSObject {
@private
    NSMutableArray <NSObject *>*_workers;
    NSMutableArray <id<NSObject>>*_observers;
}

@property (class, nonatomic, readonly, ss_strong) SSImageProvider *sharedImageProvider SS_CONST;
@property (nonatomic, readonly, ss_strong) NSArray <NSURL*>*URLs;
#if NS_BLOCKS_AVAILABLE
- (void)provideCGImageAsynchronouslyForURL:(NSURL *)URL completionHandler:(void (^)(CGImageRef __nullable image, NSData * __nullable imageData, NSDictionary <NSString*, id>* __nullable imageProperties, SSImageProviderResult result, NSError * __nullable error))handler;
- (id <NSObject>)addImageProviderObserverForURL:(NSURL *)URL queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(CGImageRef __nullable image, CGSize imageSize, SSImageProviderState state, long long loadedImageLength, long long expectedImageLength))block;
#endif
- (void)removeImageProviderObserver:(id <NSObject>)observer;
- (void)cancelRequestForURL:(NSURL *)URL;
- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
