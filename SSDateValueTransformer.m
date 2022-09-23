//
//  SSDateValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 20/01/13.
//
//

#import <TargetConditionals.h>
#import "SSDateValueTransformer.h"
#import "NSString+SSAdditions.h"
#import "SSFoundationUtilities.h"
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

@implementation SSDateValueTransformer

+ (void)load {
	@autoreleasepool {
        SSDateValueTransformer *transformer = [[[SSDateValueTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:transformer forName:NSStringFromClass(self.class)];
    }
}

+ (Class)transformedValueClass {
	return NSDate.class;
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSDate class]]) {
        // Initialize the formatter.
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        formatter.dateStyle = NSDateFormatterLongStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        
        // Initialize the calendar and flags.
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_10)) || (TARGET_OS_IPHONE && defined(__IPHONE_8_0)))
        NSUInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday;
#else
        NSUInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
#endif
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        // Create reference date for supplied date.
        NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:value];
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        
        NSDate *suppliedDate = [calendar dateFromComponents:dateComponents];
        
        // Iterate through the eight days (tomorrow, today, and the last six).
        NSInteger i;
        for (i = -1; i < 7; i++) {
            // Initialize reference date.
            dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
            dateComponents.hour = 0;
            dateComponents.minute = 0;
            dateComponents.second = 0;
            dateComponents.day = dateComponents.day - i;
            
            NSDate *referenceDate = [calendar dateFromComponents:dateComponents];
            // Get week day (starts at 1).
            NSInteger weekday = [calendar components:unitFlags fromDate:referenceDate].weekday - 1;
            
            if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1) {
                return SSFoundationLocalizedString(@"Tomorrow", @"date format");
            } else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0) {
                formatter.dateStyle = NSDateFormatterNoStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
                return [NSString stringWithFormat:SSFoundationLocalizedString(@"Today at %@", @"date format"), [formatter stringFromDate:value]];
            } else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1) {
                formatter.dateStyle = NSDateFormatterNoStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
                return [NSString stringWithFormat:SSFoundationLocalizedString(@"Yesterday at %@", @"date format"), [formatter stringFromDate:value]];
            } else if ([suppliedDate compare:referenceDate] == NSOrderedSame) {
                // Day of the week
                NSString *weekDay = (formatter.weekdaySymbols)[weekday];
                formatter.dateStyle = NSDateFormatterNoStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
                return [NSString stringWithFormat:SSFoundationLocalizedString(@"%@ at %@", @"date format"), weekDay.capitalizedString, [formatter stringFromDate:value]];
            }
        }
        
        return [formatter stringFromDate:value];
    }
    return nil;
}

@end
