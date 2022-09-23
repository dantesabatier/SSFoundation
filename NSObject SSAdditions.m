//
//  NSObject+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/31/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSObject+SSAdditions.h"
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/objc-sync.h>

NSString *const SSObjectAssociatedObjectKey = @"SSObjectAssociatedObject";

@implementation NSObject(SSAdditions)

- (id)associatedObject {
    return [self associatedValueForKey:SSObjectAssociatedObjectKey];
}

- (void)setAssociatedObject:(id)associatedObject {
    [self setAssociatedValue:associatedObject forKey:SSObjectAssociatedObjectKey];
}

- (id)associatedValueForKey:(NSString *)key {
    return SSGetAssociatedValueForKey(key);
}

- (void)setAssociatedValue:(id)value forKey:(NSString *)key {
    SSSetAtomicRetainedAssociatedValueForKey(key, value);
}

- (void)setAtomicRetainedAssociatedValue:(id)value forKey:(NSString *)key {
    SSSetAtomicRetainedAssociatedValueForKey(key, value);
}

- (void)setNonAtomicRetainedAssociatedValue:(id)value forKey:(NSString *)key {
    SSSetNonAtomicRetainedAssociatedValueForKey(key, value);
}

- (void)setAtomicCopiedAssociatedValue:(id)value forKey:(NSString *)key {
    SSSetAtomicCopiedAssociatedValueForKey(key, value);
}

- (void)setNonAtomicCopiedAssociatedValue:(id)value forKey:(NSString *)key {
    SSSetNonAtomicCopiedAssociatedValueForKey(key, value);
}

- (void)setWeakAssociatedValue:(id)value forKey:(NSString *)key {
    SSSetWeakAssociatedValueForKey(key, value);
}

- (id)nonControllerMarkerValueForKey:(NSString *)key {
    id value = nil;
    if (key) {
        value = [self valueForKey:key];
#if !TARGET_OS_IPHONE
        if (NSIsControllerMarker(value)) {
            value = nil;
        }
#endif
    }
    return value;
}

- (id)nonControllerMarkerValueForKeyPath:(NSString *)keyPath {
    id value = nil;
    if (keyPath) {
        value = [self valueForKeyPath:keyPath];
#if !TARGET_OS_IPHONE
        if (NSIsControllerMarker(value)) {
            value = nil;
        }
#endif
    }
    return value;
}

+ (BOOL)implementsRequiredMethodsInProtocol:(Protocol *)protocol {
    return SSClassImplementsRequiredMethodsInProtocol(self, protocol);
}

- (BOOL)implementsRequiredMethodsInProtocol:(Protocol *)protocol {
    return SSObjectImplementsRequiredMethodsInProtocol(self, protocol);
}

- (void)performLatestRequestOfSelector:(SEL)selector withObject:(id)object afterDelay:(NSTimeInterval)delay inModes:(NSArray <NSRunLoopMode> *)modes {
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:selector object:object];
    [self performSelector:selector withObject:object afterDelay:delay inModes:modes];
}

- (void)performLatestRequestOfSelector:(SEL)selector withObject:(id)object afterDelay:(NSTimeInterval)delay {
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:selector object:object];
    [self performSelector:selector withObject:object afterDelay:delay];
}

- (id)performSelector:(SEL)selector withObjects:(id)firstObj,... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    invocation.target = self;
    invocation.selector = selector;
    
    NSInteger idx = 3;
    va_list vaList;
    
    __unsafe_unretained id obj;
    __unsafe_unretained id fObj = firstObj;
    
    if (firstObj) {
        [invocation setArgument:&fObj atIndex:2];
        va_start(vaList, firstObj);
        while ((obj = va_arg(vaList, id))) {
            [invocation setArgument:&obj atIndex:idx++];
        }
        va_end(vaList);
    }
    
    [invocation invoke];
    
    __unsafe_unretained id result = nil;
    [invocation getReturnValue:&result];
    return result;
}

- (void)performSelector:(SEL)selector onThread:(NSThread *)thr withObjects:(id)firstObj,... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    invocation.target = self;
    invocation.selector = selector;
    
    NSInteger idx = 3;
    va_list vaList;
    
    __unsafe_unretained id obj;
    __unsafe_unretained id fObj = firstObj;
    
    if (firstObj) {
        [invocation setArgument:&fObj atIndex:2];
        va_start(vaList, firstObj);
        while ((obj = va_arg(vaList, id))) {
            [invocation setArgument:&obj atIndex:idx];
            idx++;
        }
        va_end(vaList);
    }
    
    [invocation performSelector:@selector(invoke) onThread:thr withObject:nil waitUntilDone:NO];
}

- (void)synchronized:(void (^)(void))execute {
    SSSynchronized(self, execute);
}

@end

BOOL SSClassImplementsMethodsInProtocol(Class class, Protocol *protocol, BOOL isRequiredMethod, BOOL isInstanceMethod) {
    BOOL ok = YES;
    unsigned int i, outCount;
    struct objc_method_description *mds = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &outCount);
    for (i = 0; i < outCount; i++) {
        struct objc_method_description md = mds[i];
        if (isInstanceMethod) {
            if (!class_getInstanceMethod(class, md.name)) {
                SSDebugLog(@"SSClassImplementsMethodsInProtocol(%@, %@), - %@ not implemented", NSStringFromClass(class), NSStringFromProtocol(protocol), NSStringFromSelector(md.name));
                ok = NO;
                break;
            }
        } else {
            if (!class_getClassMethod(class, md.name)) {
                SSDebugLog(@"SSClassImplementsMethodsInProtocol(%@, %@), + %@ not implemented", NSStringFromClass(class), NSStringFromProtocol(protocol), NSStringFromSelector(md.name));
                ok = NO;
                break;
            }
        }
    }
    
    if (mds) {
        free(mds);
    }
    
    return ok;
}

BOOL SSClassImplementsRequiredMethodsInProtocol(Class class, Protocol *protocol) {
    return SSClassImplementsMethodsInProtocol(class, protocol, YES, NO) ? SSClassImplementsMethodsInProtocol(class, protocol, YES, YES) : NO;
}

BOOL SSObjectImplementsRequiredMethodsInProtocol(id self, Protocol *protocol) {
    return SSClassImplementsRequiredMethodsInProtocol(object_getClass(self), protocol);
}

IMP SSObjectGetMethodImplementationOfSelector(id self, SEL selector) {
    NSUInteger returnAddress = (NSUInteger)__builtin_return_address(0);
    NSUInteger closest = 0;
    Class class = object_getClass(self);
    while (class) {
        unsigned int outCount;
        Method *methodList = class_copyMethodList(class, &outCount);
        unsigned int i;
        for (i = 0; i < outCount; i++) {
            if (method_getName(methodList[i]) != selector) {
                continue;
            }
            
            NSUInteger address = (NSUInteger)method_getImplementation(methodList[i]);
            if ((address < returnAddress) && (address > closest)) {
                closest = address;
            } 
        }
        free(methodList);
        class = class_getSuperclass(class);
    }
    
    return (IMP)closest;
}

IMP SSObjectPerformSupersequentMethodImplementation(id self, SEL selector, IMP methodImplementation) {
    BOOL found = NO;
    Class class = object_getClass(self);
    while (class) {
        unsigned int outCount;
        Method *methodList = class_copyMethodList(class, &outCount);
        unsigned int i;
        for (i = 0; i < outCount; i++) {
            if (method_getName(methodList[i]) != selector) {
                continue;
            }
            
            IMP implementation = method_getImplementation(methodList[i]);
            if (implementation == methodImplementation) {
                found = YES;
            } else if (found) {
                // Return the match.
                free(methodList);
                return implementation;
            }
        }
        // No match found. Traverse up through super class' methods.
        free(methodList);
        
        class = class_getSuperclass(class);
    }
    return nil;
}

