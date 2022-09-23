//
//  NSSet+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import "SSCollectionProtocol.h"
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface __GENERICS(NSSet, ObjectType) (SSAdditions)

- (instancetype)objectValuesForProperty:(SEL)property;
- (instancetype)coalescedValuesForProperty:(SEL)property;
#if NS_BLOCKS_AVAILABLE
- (nullable ObjectType)anyObjectPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj))predicate NS_SWIFT_NAME(any(where:)) NS_AVAILABLE(10_6, 4_0);
#endif

@end


@interface __GENERICS(NSMutableSet, ObjectType) (SSAdditions)

- (BOOL)addObjectIfNeeded:(nullable ObjectType)object;
- (void)addObjects:(ObjectType)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
