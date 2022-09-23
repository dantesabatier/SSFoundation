//
//  NSArray+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 8/8/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSArray+SSAdditions.h"
#import <objc/message.h>

@implementation NSArray(SSAdditions)

#if ((!TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED)) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0))

- (id)firstObject {
    return self.count ? self[0] : nil;
}

#endif

- (id)anyObject {
    id obj = nil;
    switch (self.count) {
        case 0:
            break;
        case 1:
            obj = self[0];
            break;
        default: {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_4_3)))
            if ((&arc4random_uniform) != NULL) {
                obj = self[(NSUInteger)arc4random_uniform((u_int32_t)self.count)];
            }
#else
            obj = self[((NSUInteger)random() % self.count)];
#endif
        }
            break;
    }
    return obj;
}

- (BOOL)containsIndex:(NSInteger)index {
    return NSLocationInRange(index, (NSRange){0, self.count});
}

- (id)safeObjectAtIndex:(NSInteger)index {
    return [self containsIndex:index] ? self[index] : nil;
}

#if NS_BLOCKS_AVAILABLE

- (id)firstObjectPassingTest:(BOOL (NS_NOESCAPE ^)(id obj))predicate {
    for (id obj in self) {
        if (predicate(obj)) {
            return obj;
        }
    }
    return nil;
}

- (id)lastObjectPassingTest:(BOOL (NS_NOESCAPE ^)(id obj))predicate {
    for (id obj in self.reverseObjectEnumerator) {
        if (predicate(obj)) {
            return obj;
        }
    }
    return nil;
}

- (instancetype)objectsPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSInteger idx, BOOL *stop))predicate {
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger idx = 0;
    for (id obj in self) {
        BOOL stop = NO;
        if (predicate(obj, idx, &stop)) {
            [array addObject:obj];
        }
        if (stop) {
            break;
        }
        idx++;
    }
    return array;
}

- (NSArray *)mapObjectsUsingBlock:(id __nullable (NS_NOESCAPE^)(id obj))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        [array addObjectIfNeeded:block(obj)];
    }
    return array;
}

- (instancetype)makeObjectsPerformSelector:(SEL)selector withObject:(nullable id)object predicate:(BOOL (NS_NOESCAPE ^ __nullable)(id obj, NSInteger idx, BOOL *stop))predicate {
    if (!self.count) {
        return nil;
    }
    
    Class class = object_getClass(self[0]);
    Method method = class_getInstanceMethod(class, selector);
    
    char dst[256];
    method_getReturnType(method, dst, 256);
    NSString *returnType = @(dst);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    NSUInteger idx = 0;
    for (id obj in self) {
        id result = nil;
        if ([returnType isEqualToString:@"c"]) {
            result = @(((char(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"i"]) {
            result = @(((int(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"s"]) {
            result = @(((short(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"l"]) {
            result = @(((long(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"q"]) {
            result = @(((long long(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"C"]) {
            result = @(((unsigned char(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"I"]) {
            result = @(((unsigned int(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"S"]) {
            result = @(((unsigned short(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"L"]) {
            result = @(((unsigned long(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"Q"]) {
            result = @(((unsigned long long(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"f"]) {
            result = @(((float(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"d"]) {
            result = @(((double(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"B"]) {
            result = @(((bool(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"v"]) {
            ((void(*)(id, SEL, id))objc_msgSend)(obj, selector, object);
        } else if ([returnType isEqualToString:@"*"]) {
            result = @(((char *(*)(id, SEL, id))objc_msgSend)(obj, selector, object));
        } else if ([returnType isEqualToString:@"@"]) {
            result = ((NSObject*(*)(id, SEL, id))objc_msgSend)(obj, selector, object);
        } else if ([returnType isEqualToString:@"#"]) {
            result = ((Class(*)(id, SEL, id))objc_msgSend)(obj, selector, object);
        } else {
            // I don't know, everything else
            ((id(*)(id, SEL, id))objc_msgSend)(obj, selector, object);
        }
        
        BOOL stop = NO;
        if (predicate) {
            if (predicate(obj, idx, &stop) && result) {
                [array addObject:result];
            }
        } else {
            if (result) {
                [array addObject:result];
            }
        }
        
        if (stop) {
            break;
        }
        
        idx++;
    }
    return array;
}

- (instancetype)makeObjectsPerformSelector:(SEL)selector predicate:(BOOL (NS_NOESCAPE^ __nullable)(id obj, NSInteger idx, BOOL *stop))predicate {
    return [self makeObjectsPerformSelector:selector withObject:nil predicate:predicate];
}

#endif

@end

@implementation NSMutableArray (SSAdditions)

- (void)moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSInteger)destinationIndex {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_5_0)))
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] initWithArray:self];
    [set moveObjectsAtIndexes:indexes toIndex:destinationIndex];
    self.array = set.array;
#endif
}

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
    
    id obj;
    va_list argList;
    
    va_start(argList, firstObject);
    while ((obj = va_arg(argList, id)) != nil) {
        [self addObject:obj];
    }
        
    va_end(argList);
}

- (void)shuffle {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_4_3)))
    NSUInteger count = self.count;
    if (!count) {
        return;
    }
    for (NSUInteger i = 0; i < count - 1; ++i) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(NSUInteger)(i + arc4random_uniform((u_int32_t )(count - i)))];
    }
#endif
}

@end
