//
//  SSPixelsToMeasureValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 20/01/13.
//
//

#import <TargetConditionals.h>
#import "SSPixelsToMeasureValueTransformer.h"
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

@implementation SSPixelsToMeasureValueTransformer

+ (void)load {
    @autoreleasepool {
        SSPixelsToMeasureValueTransformer *transformer = [[[SSPixelsToMeasureValueTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:transformer forName:NSStringFromClass(self.class)];
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
        NSString *symbol = @"ʺ";
        CGFloat measure = ((NSNumber *)value).floatValue/(CGFloat)72.0;
        if (((NSNumber *)CFLocaleGetValue(SSAutorelease(CFLocaleCopyCurrent()), kCFLocaleUsesMetricSystem)).boolValue) {
            measure *= 2.54;
            symbol = @"cm";
        }
        return [NSString stringWithFormat:@"%.2f %@", measure, symbol];
    }
	return nil;
}

- (id)reverseTransformedValue:(id)value {
	if ([value respondsToSelector:@selector(floatValue)]) {
        CGFloat pixels = ((NSNumber *)value).floatValue*(CGFloat)72.0;
        if (((NSNumber *)CFLocaleGetValue(SSAutorelease(CFLocaleCopyCurrent()), kCFLocaleUsesMetricSystem)).boolValue)
            pixels /= 2.54;
        return @(pixels);
    }
	return nil;
}

@end
