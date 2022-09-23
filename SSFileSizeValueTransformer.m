//
//  SSFileSizeValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 20/01/13.
//
//

#import "SSFileSizeValueTransformer.h"
#import "NSString+SSAdditions.h"

@implementation SSFileSizeValueTransformer

+ (void)load {
	@autoreleasepool {
        SSFileSizeValueTransformer *transformer = [[[SSFileSizeValueTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:transformer forName:@"SSFileSizeValueTransformer"];
    }
}

+ (Class)transformedValueClass {
	return NSNumber.class;
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        CGFloat bytes = (CGFloat)((NSNumber *)value).floatValue;
        if (bytes) {
            NSString *symbol = nil;
            if (bytes < 1024.0) {
                symbol = @"bytes";
            } else if (bytes < (1024.0 * 1024.0)) {
                symbol = @"KB";
                bytes = bytes/1024.0;
            } else if (bytes < (1024.0 * 1024.0 * 1024.0)) {
                symbol = @"MB";
                bytes = bytes/1024.0/1024.0;
            } else {
                symbol = @"GB";
                bytes = bytes/1024.0/1024.0/1024.0;
            }
            
            NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
            formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            formatter.decimalSeparator = @",";
#if TARGET_OS_IPHONE
            
#else
            formatter.format = @"#,###.##;0.00;(#,##0.00)";
#endif
            
            return [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:@(bytes)], symbol ? [NSString stringWithFormat:@" %@", symbol] : @""];
        }
    }
	return nil;
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        CGFloat bytes = (CGFloat)[value stringByReplacingOccurrencesOfString:@"," withString:@"."].floatValue;
        if ([value localizedCaseInsensitiveContainsString:@"KB"]) {
            bytes *= 1024.0;
        } else if ([value localizedCaseInsensitiveContainsString:@"MB"]) {
            bytes = bytes*1024.0*1024.0;
        } else if ([value localizedCaseInsensitiveContainsString:@"GB"]) {
            bytes = bytes*1024.0*1024.0*1024.0;
        }
            
        return @(bytes);
    }
    return nil;
}

@end
