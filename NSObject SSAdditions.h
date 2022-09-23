//
//  NSObject+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 7/31/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <AppKit/NSKeyValueBinding.h>
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

SS_EXTERN NSString *const SSObjectAssociatedObjectKey;

@protocol SSObject <NSObject>

- (nullable id)nonControllerMarkerValueForKey:(NSString *)key;
- (nullable id)nonControllerMarkerValueForKeyPath:(NSString *)keyPath;
+ (BOOL)implementsRequiredMethodsInProtocol:(Protocol *)protocol;
- (BOOL)implementsRequiredMethodsInProtocol:(Protocol *)protocol;

@end

@interface NSObject (SSAdditions) <SSObject>

@property (nullable, strong) id associatedObject;
- (nullable id)associatedValueForKey:(NSString *)key;
- (void)setAssociatedValue:(nullable id)value forKey:(NSString *)key;
- (void)setAtomicRetainedAssociatedValue:(nullable id)value forKey:(NSString *)key;
- (void)setNonAtomicRetainedAssociatedValue:(nullable id)value forKey:(NSString *)key;
- (void)setAtomicCopiedAssociatedValue:(nullable id)value forKey:(NSString *)key;
- (void)setNonAtomicCopiedAssociatedValue:(nullable id)value forKey:(NSString *)key;
- (void)setWeakAssociatedValue:(nullable id)value forKey:(NSString *)key;
- (nullable id)nonControllerMarkerValueForKey:(NSString *)key;
- (nullable id)nonControllerMarkerValueForKeyPath:(NSString *)keyPath;
+ (BOOL)implementsRequiredMethodsInProtocol:(Protocol *)protocol;
- (BOOL)implementsRequiredMethodsInProtocol:(Protocol *)protocol;
- (void)performLatestRequestOfSelector:(SEL)selector withObject:(nullable id)object afterDelay:(NSTimeInterval)delay inModes:(NSArray <NSRunLoopMode> *)modes;
- (void)performLatestRequestOfSelector:(SEL)selector withObject:(nullable id)object afterDelay:(NSTimeInterval)delay;
- (id)performSelector:(SEL)selector withObjects:(id)firstObj,... NS_REQUIRES_NIL_TERMINATION;
- (void)performSelector:(SEL)selector onThread:(NSThread *)thr withObjects:(id)firstObj,... NS_REQUIRES_NIL_TERMINATION;
- (void)synchronized:(void (^)(void))execute;

@end

SS_EXTERN BOOL SSClassImplementsMethodsInProtocol(Class class, Protocol *protocol, BOOL isRequiredMethod, BOOL isInstanceMethod);
SS_EXTERN BOOL SSClassImplementsRequiredMethodsInProtocol(Class class, Protocol *protocol);
SS_EXTERN BOOL SSObjectImplementsRequiredMethodsInProtocol(id self, Protocol *protocol);
SS_EXTERN __nullable IMP SSObjectGetMethodImplementationOfSelector(id self, SEL selector);
SS_EXTERN __nullable IMP SSObjectPerformSupersequentMethodImplementation(id self, SEL selector, IMP methodImplementation);

NS_ASSUME_NONNULL_END
