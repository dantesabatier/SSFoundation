//
//  SSStringToArrayValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 20/01/13.
//
//

#import "SSStringToArrayValueTransformer.h"

@implementation SSStringToArrayValueTransformer

+ (void)load {
	@autoreleasepool {
        SSStringToArrayValueTransformer *transformer = [[[SSStringToArrayValueTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:transformer forName:@"SSStringToArrayValueTransformer"];
    }
}

+ (Class)transformedValueClass {
	return NSString.class;
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSString class]] && [value length])
        return [value componentsSeparatedByString:@","];
	return nil;
}

- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSArray class]])
        return [value componentsJoinedByString:@","];
	return nil;
}

@end
