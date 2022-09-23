//
//  NSArray+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 8/8/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import "SSCollectionProtocol.h"
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface __GENERICS(NSArray, ObjectType) (SSAdditions)

#if (!TARGET_OS_IPHONE && !defined(__MAC_10_7)) || (TARGET_OS_IPHONE && !defined(__IPHONE_4_0))
@property (nullable, nonatomic, readonly) ObjectType firstObject;
#endif
@property (nullable, nonatomic, readonly) ObjectType anyObject;
- (BOOL)containsIndex:(NSInteger)index;
- (nullable ObjectType)safeObjectAtIndex:(NSInteger)index;
#if NS_BLOCKS_AVAILABLE
- (nullable ObjectType)firstObjectPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj))predicate NS_SWIFT_NAME(firstObject(where:)) NS_AVAILABLE(10_6, 4_0);
- (nullable ObjectType)lastObjectPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj))predicate NS_SWIFT_NAME(lastObject(where:)) NS_AVAILABLE(10_6, 4_0);
- (NSArray<ObjectType> *)objectsPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, NSInteger idx, BOOL *stop))predicate NS_SWIFT_NAME(objects(where:)) NS_AVAILABLE(10_6, 4_0);
- (NSArray *)mapObjectsUsingBlock:(id __nullable (NS_NOESCAPE^)(ObjectType obj))block NS_SWIFT_NAME(map(transform:)) NS_AVAILABLE(10_6, 4_0);
- (nullable instancetype)makeObjectsPerformSelector:(SEL)selector withObject:(nullable id)object predicate:(BOOL (NS_NOESCAPE ^ __nullable)(ObjectType obj, NSInteger idx, BOOL *stop))predicate NS_SWIFT_NAME(makeObjectsPerform(selector:with:where:)) NS_AVAILABLE(10_6, 4_0);
- (nullable instancetype)makeObjectsPerformSelector:(SEL)selector predicate:(BOOL (NS_NOESCAPE ^ __nullable)(ObjectType obj, NSInteger idx, BOOL *stop))predicate NS_SWIFT_NAME(makeObjectsPerform(selector:where:)) NS_AVAILABLE(10_6, 4_0);
#endif

@end

@interface __GENERICS(NSMutableArray, ObjectType) (SSAdditions)

- (void)moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSInteger)destinationIndex NS_AVAILABLE(10_7, 5_0);
- (BOOL)addObjectIfNeeded:(nullable ObjectType)object;
- (void)addObjects:(ObjectType)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (void)shuffle NS_AVAILABLE(10_7, 4_3);

@end

NS_ASSUME_NONNULL_END
