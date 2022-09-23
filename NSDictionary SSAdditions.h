//
//  NSDictionary+SSAdditions.h
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

@interface NSDictionary<KeyType, ObjectType> (SSAdditions)

- (nullable ObjectType)objectForCaseInsensitiveKey:(KeyType)aKey;
- (instancetype)mapUsingBlock:(id __nullable (NS_NOESCAPE^)(KeyType key, ObjectType obj))block NS_SWIFT_NAME(map(transform:)) NS_AVAILABLE(10_6, 4_0);

@end

@interface __GENERICS(NSDictionary, KeyType, ObjectType) (GTMAddtions)

@property (readonly, copy) NSString *HTTPArgumentsString;

@end

NS_ASSUME_NONNULL_END
