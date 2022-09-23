//
//  SSTimeFormatter.m
//  SSFoundation
//
//  Created by Dante Sabatier on 13/04/16.
//
//

#import "SSTimeFormatter.h"
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

@implementation SSTimeFormatter

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;
{
    if (interval) {
        NSTimeInterval intervalInSeconds = FABS(interval);
        double intervalInMinutes = ROUND(intervalInSeconds/60.0);
        if ((intervalInMinutes >= 0) && (intervalInMinutes <= 1)) {
            if ((intervalInSeconds >= 0) && (intervalInSeconds <= 4)) {
                return NSLocalizedString(@"Less than 5 seconds", @"time format");
            } else if ((intervalInSeconds >= 5) && (intervalInSeconds <= 9)) {
                return NSLocalizedString(@"Less than 10 seconds", @"time format");
            } else if ((intervalInSeconds >= 10) && (intervalInSeconds <= 19)) {
                return NSLocalizedString(@"Less than 20 seconds", @"time format");
            } else if ((intervalInSeconds >= 20) && (intervalInSeconds <= 39)) {
                return NSLocalizedString(@"Half a minute", @"time format");
            } else if ((intervalInSeconds >= 40) && (intervalInSeconds <= 59)) {
                return NSLocalizedString(@"Less than a minute", @"time format");
            } else {
                return NSLocalizedString(@"1 minute", @"time format");
            }
        } else if ((intervalInMinutes >= 2) && (intervalInMinutes <= 44)) {
            return [NSString stringWithFormat:NSLocalizedString(@"%.0f minutes", @"time format"), intervalInMinutes];
        } else if ((intervalInMinutes >= 45) && (intervalInMinutes <= 89)) {
            return NSLocalizedString(@"About 1 hour", @"time format");
        } else if ((intervalInMinutes >= 90) && (intervalInMinutes <= 1439)) {
            return [NSString stringWithFormat:NSLocalizedString(@"About %.0f hours", @"time format"), ROUND(intervalInMinutes/60.0)];
        } else if ((intervalInMinutes >= 1440) && (intervalInMinutes <= 2879)) {
            return NSLocalizedString(@"1 day", @"time format");
        } else if ((intervalInMinutes >= 2880) && (intervalInMinutes <= 43199)) {
            return [NSString stringWithFormat:NSLocalizedString(@"%.0f days", @"time format"), ROUND(intervalInMinutes/1440.0)];
        } else if ((intervalInMinutes >= 43200) && (intervalInMinutes <= 86399)) {
            return NSLocalizedString(@"About 1 month", @"time format");
        } else if ((intervalInMinutes >= 86400) && (intervalInMinutes <= 525599)) {
            return [NSString stringWithFormat:NSLocalizedString(@"%.0f months", @"time format"), ROUND(intervalInMinutes/43200.0)];
        } else if ((intervalInMinutes >= 525600) && (intervalInMinutes <= 1051199)) {
            return NSLocalizedString(@"About 1 year", @"time format");
        } else {
            return [NSString stringWithFormat:NSLocalizedString(@"Over %.0f years", @"time format"), ROUND(intervalInMinutes/525600.0)];
        }
    }
    return NSLocalizedString(@"0 seconds", @"time format");
}

- (nullable NSString *)stringForObjectValue:(id)obj;
{
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [self stringFromTimeInterval:((NSNumber *)obj).doubleValue];
    }
    return nil;
}

- (nullable NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(nullable NSDictionary<NSString *, id> *)attrs;
{
    NSString *string = [self stringForObjectValue:obj];
    if (string) {
        return [[[NSAttributedString alloc] initWithString:string attributes:attrs] autorelease];
    }
    return nil;
}

@end
