//
//  SSMeasureToPixelValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 24/01/13.
//
//

#import "SSMeasureToPixelValueTransformer.h"
#import <SSBase/SSDefines.h>

@implementation SSMeasureToPixelValueTransformer

+ (void)load {
    @autoreleasepool {
        [NSValueTransformer setValueTransformer:[[[SSMeasureToPixelValueTransformer alloc] init] autorelease] forName:@"SSMeasureToPixelValueTransformer"];
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
        CGFloat pixels = ((NSNumber *)value).floatValue*(CGFloat)72.0;
        if (((NSNumber *)CFLocaleGetValue(SSAutorelease(CFLocaleCopyCurrent()), kCFLocaleUsesMetricSystem)).boolValue)
            pixels /= 2.54;
        return @(pixels);
    }
	return nil;
}

- (id)reverseTransformedValue:(id)value {
	if ([value respondsToSelector:@selector(floatValue)]) {
        CGFloat measure = ((NSNumber *)value).floatValue/(CGFloat)72.0;
        if (((NSNumber *)CFLocaleGetValue(SSAutorelease(CFLocaleCopyCurrent()), kCFLocaleUsesMetricSystem)).boolValue)
            measure *= 2.54;
        return @(measure);
    }
	return nil;
}

@end
