//
//  NSDate+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSDate(SSAdditions)

+ (NSString *)UTCTimestamp;
+ (NSString *)GMTTimestamp;
- (NSString *)dateStringWithStyle:(NSDateFormatterStyle)style;
+ (instancetype)dateWithToday;
@property (readonly, ss_strong) NSDate *dateAtMidnight;

@end

NS_ASSUME_NONNULL_END
