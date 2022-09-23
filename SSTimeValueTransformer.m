//
//  SSTimeValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 20/01/13.
//
//

#import "SSTimeValueTransformer.h"

@implementation SSTimeValueTransformer

+ (void)load {
	@autoreleasepool {
        SSTimeValueTransformer *transformer = [[[SSTimeValueTransformer alloc] init] autorelease];
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
        NSInteger time = ((NSNumber *)value).integerValue;
        if (time) {
            return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)(time/3600), (long)((time/60)%60), (long)(time%60)];
        }
    }
	return nil;
}

- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSString class]]) {
        NSArray *components = [(NSString *)value componentsSeparatedByString:@":"];
        if (components.count == 3) {
            NSInteger hours = [components[0] integerValue];
            NSInteger minutes = [components[1] integerValue];
            NSInteger seconds = [components[2] integerValue];
            return @(seconds + 60 * (minutes + 60 * hours));
        }
    }
	return nil;
}

@end
