//
//  SSArrayToStringValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 20/01/13.
//
//

#import "SSArrayToStringValueTransformer.h"

@implementation SSArrayToStringValueTransformer

+ (void)load {
	@autoreleasepool {
        SSArrayToStringValueTransformer *transformer = [[[SSArrayToStringValueTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:transformer forName:@"SSArrayToStringValueTransformer"];
    }
}

+ (Class)transformedValueClass {
	return NSArray.class;
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSArray class]])
        return [value componentsJoinedByString:@","];
	return nil;
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]] && [value length])
        return [value componentsSeparatedByString:@","];
	return nil;
}

@end
