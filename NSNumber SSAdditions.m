//
//  NSNumber+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 30/10/14.
//
//

#import "NSNumber+SSAdditions.h"

@implementation NSNumber (SSAdditions)

- (CGFloat)CGFloatValue {
#if defined(__LP64__) && __LP64__
    return (CGFloat)self.doubleValue;
#else
    return (CGFloat)self.floatValue;
#endif
}

- (NSString *)positionalTimeIntervalStringValueUsingMiliseconds:(BOOL)useMiliseconds {
    NSTimeInterval interval = self.doubleValue;
    int32_t hours = (int32_t)FLOOR(((interval / 60.0) / 60.0));
    int32_t hourComponent = (int32_t)(hours % 24);
    int32_t minutes = (int32_t)FLOOR(interval / 60.0);
    int32_t minuteComponent = (int32_t)(minutes - (hours * 60));
    int32_t seconds = (int32_t)FLOOR(interval);
    int32_t secondComponent = (int32_t)(seconds - (minutes * 60));
    NSString *hoursStr = (hourComponent < 10) ? [NSString stringWithFormat:@"0%@", @(hourComponent).stringValue] : @(hourComponent).stringValue;
    NSString *minutesStr = (minuteComponent < 10) ? [NSString stringWithFormat:@"0%@", @(minuteComponent).stringValue] : @(minuteComponent).stringValue;
    NSString *secondsStr = (secondComponent < 10) ? [NSString stringWithFormat:@"0%@", @(secondComponent).stringValue] : @(secondComponent).stringValue;
    NSString *counter = [NSString stringWithFormat:@"%@:%@:%@", hoursStr, minutesStr, secondsStr];
    if (useMiliseconds) {
        double intpart;
        int32_t milisecondComponent = (int32_t)(modf(interval, &intpart)*1000);
        //int64_t miliseconds = (int64_t)((seconds * 1000) + milisecondComponent);
        counter = [counter stringByAppendingFormat:@",%@", (milisecondComponent < 10) ? [NSString stringWithFormat:@"0%@", @(milisecondComponent).stringValue] : @(milisecondComponent).stringValue];
    }
    return counter;
}

@end
