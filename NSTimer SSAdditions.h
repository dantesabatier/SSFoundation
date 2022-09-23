//
//  NSTimer+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 16/01/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (SSAdditions)

#if NS_BLOCKS_AVAILABLE
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval validation:(BOOL (^)(void))validation NS_AVAILABLE(10_6, 4_0);
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval duration:(NSTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void (^ __nullable)(void))completion NS_AVAILABLE(10_6, 4_0);
+ (instancetype)timerWithDuration:(NSTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void (^ __nullable)(void))completion NS_AVAILABLE(10_6, 4_0);
+ (instancetype)timerWithDuration:(NSTimeInterval)duration execution:(void (^)(CGFloat progress))execution;
+ (instancetype)timerWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion NS_AVAILABLE(10_6, 4_0);
#endif

@end

NS_ASSUME_NONNULL_END
