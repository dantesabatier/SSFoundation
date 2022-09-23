//
//  SSSetToArrayValueTransformer.m
//  SSFoundation
//
//  Created by Dante Sabatier on 20/01/13.
//
//

#import "SSSetToArrayValueTransformer.h"

@implementation SSSetToArrayValueTransformer

+ (void)load {
	@autoreleasepool {
        SSSetToArrayValueTransformer *transformer = [[[SSSetToArrayValueTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:transformer forName:@"SSSetToArrayValueTransformer"];
    }
}

+ (Class)transformedValueClass {
	return [NSSet class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSSet class]])
        return [value allObjects];
	return nil;
}

- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSArray class]])
        return [NSSet setWithArray:value];
	return nil;
}

@end
