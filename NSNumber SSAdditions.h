//
//  NSNumber+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 30/10/14.
//
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreGraphics/CGBase.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (SSAdditions)

@property (readonly) CGFloat CGFloatValue;
- (NSString *)positionalTimeIntervalStringValueUsingMiliseconds:(BOOL)useMiliseconds;

@end

NS_ASSUME_NONNULL_END
