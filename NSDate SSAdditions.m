//
//  NSDate+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSDate+SSAdditions.h"
#import <Foundation/NSLocale.h>
#import <Foundation/NSTimeZone.h>

@implementation NSDate(SSAdditions)

+ (NSString *)UTCTimestamp {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)GMTTimestamp {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	return [dateFormatter stringFromDate:[NSDate date]];
}

- (NSString *)dateStringWithStyle:(NSDateFormatterStyle)style {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = style;
    return [dateFormatter stringFromDate:self];
}

+ (instancetype)dateWithToday {
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"yyyy-d-M";
	return [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
}

- (instancetype)dateAtMidnight {
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"yyyy-d-M";
	return [formatter dateFromString:[formatter stringFromDate:self]];
}

@end
