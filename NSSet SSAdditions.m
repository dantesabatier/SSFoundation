//
//  NSSet+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSSet+SSAdditions.h"
#import <objc/message.h>

@implementation NSSet(SSAdditions)

- (instancetype)objectValuesForProperty:(SEL)property {
	NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];
	for (id object in self) {
		id value = ((id(*)(id, SEL, id))objc_msgSend)(object, property, nil);
		if (value) {
			[result addObject:value];
		}
	}
	return result;
}

- (instancetype)coalescedValuesForProperty:(SEL)property {
	NSInteger count = 0;
	for (id object in self) {
		count += [((id(*)(id, SEL, id))objc_msgSend)(object, property, nil) count];
	}
    
	NSMutableSet *result = [NSMutableSet setWithCapacity:count];
	for (id object in self) {
		id value = ((id(*)(id, SEL, id))objc_msgSend)(object, property, nil);
		if (value) {
			[result unionSet:value];
		}
	}
	return result;
}

#if NS_BLOCKS_AVAILABLE

- (id)anyObjectPassingTest:(BOOL (NS_NOESCAPE ^)(id obj))predicate {
    for (id obj in self) {
        if (predicate(obj)) {
            return obj;
        }   
    }
    return nil;
}

#endif

@end

@implementation NSMutableSet (SSAdditions)

- (BOOL)addObjectIfNeeded:(id)object {
    if ([object isKindOfClass:[NSObject class]] && ![self containsObject:object]) {
        [self addObject:object];
        return YES;
    }
    return NO;
}

- (void)addObjects:(id)firstObject, ... {
    if (firstObject == nil) {
         return;
    }
    
    [self addObject:firstObject];
    
    id object;
    va_list argList;
    
    va_start(argList, firstObject);
    while ((object = va_arg(argList, id)) != nil) {
        [self addObject:object];
    }
    va_end(argList);
}

@end
