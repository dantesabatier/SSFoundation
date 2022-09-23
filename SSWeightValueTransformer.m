//
//  SSWeightValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 20/01/13.
//
//

#import <TargetConditionals.h>
#import "SSWeightValueTransformer.h"
#if TARGET_OS_IPHONE
#import <CoreGraphics/CGGeometry.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

@implementation SSWeightValueTransformer

+ (void)load {
	@autoreleasepool {
        SSWeightValueTransformer *transformer = [[[SSWeightValueTransformer alloc] init] autorelease];
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
        NSString *symbol = SSLocalizedString(@"pounds", @"unit of weight");
        CGFloat weight = (CGFloat)((NSNumber *)value).floatValue;
        if (((NSNumber *)CFLocaleGetValue(SSAutorelease(CFLocaleCopyCurrent()), kCFLocaleUsesMetricSystem)).boolValue) {
            weight *= (CGFloat)0.4536;
            symbol = SSLocalizedString(@"kilograms", @"unit of weight");
        }
        return [NSString stringWithFormat:@"%.2f %@", weight, symbol];
    }
	return nil;
}

- (id)reverseTransformedValue:(id)value {
	if ([value respondsToSelector:@selector(floatValue)]) {
        CGFloat weight = ((NSNumber *)value).floatValue;
        if (((NSNumber *)CFLocaleGetValue(SSAutorelease(CFLocaleCopyCurrent()), kCFLocaleUsesMetricSystem)).boolValue)
            weight /= 0.4536;
        return @(weight);
    }
	return nil;
}

@end
