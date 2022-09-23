//
//  NSTimer+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 16/01/14.
//
//

#import "NSTimer+SSAdditions.h"

static const NSTimeInterval frameRate = 0.01666666666667;

@implementation NSTimer (SSAdditions)

#if NS_BLOCKS_AVAILABLE

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval validation:(BOOL (^)(void))validation {
    void *copy = Block_copy((__bridge void *)validation);
    NSTimer *timer = [self timerWithTimeInterval:timeInterval target:self selector:@selector(handleBlockTimer:) userInfo:@{@"block" : (__bridge id)copy} repeats:YES];
    Block_release(copy);
    return timer;
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval duration:(NSTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void (^ __nullable)(void))completion {
    __block CGFloat progress = 0.0;
    return [NSTimer timerWithTimeInterval:timeInterval validation:^BOOL{
        progress += timeInterval/duration;
        execution(progress);
        if (progress >= 1.0) {
            if (completion) {
                completion();
            }
            return NO;
        }
        return YES;
    }];
}

+ (instancetype)timerWithDuration:(NSTimeInterval)duration execution:(void (^)(CGFloat progress))execution completion:(void (^ __nullable)(void))completion {
    return [NSTimer timerWithTimeInterval:frameRate duration:duration execution:execution completion:completion];
}

+ (instancetype)timerWithDuration:(NSTimeInterval)duration execution:(void (^)(CGFloat progress))execution {
    return [NSTimer timerWithDuration:duration execution:execution completion:nil];
}

+ (instancetype)timerWithDuration:(NSTimeInterval)timeInterval completion:(void (^)(void))completion {
    return [NSTimer timerWithTimeInterval:timeInterval validation:^BOOL{
        if (completion) {
            completion();
        }
        return NO;
    }];
}

+ (void)handleBlockTimer:(NSTimer *)timer {
    if (timer.isValid) {
        NSDictionary *dictionary = timer.userInfo;
        if (dictionary) {
            BOOL (^block)(void) = (BOOL (^)(void))(dictionary[@"block"]);
            if (!block()) {
                [timer invalidate];
            }
        }
    }
}

#endif

@end
