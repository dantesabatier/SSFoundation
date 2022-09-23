//
//  SSNumberToStringValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 12/3/15.
//
//

#import "SSNumberToStringValueTransformer.h"

@implementation SSNumberToStringValueTransformer

+ (void)load {
    @autoreleasepool {
        [NSValueTransformer setValueTransformer:[[[SSNumberToStringValueTransformer alloc] init] autorelease] forName:@"SSNumberToStringValueTransformer"];
    }
}

+ (Class)transformedValueClass {
    return NSString.class;
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)value).stringValue;
    }
    return nil;
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return @(((NSString *)value).integerValue);
    }
    return nil;
}

@end
