//
//  SSMainThreadProxy.h
//  SSTaskKit
//
//  Created by Dante Sabatier on 5/5/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol SSMainThreadProxy <NSObject>

@property (readonly, strong) id mainThreadProxy;
@property (readonly, strong) id copyMainThreadProxy;

@end

@interface SSMainThreadProxy : NSObject <SSMainThreadProxy> {
    __ss_weak id _target;
}

- (instancetype)initWithTarget:(id)target;
@property (readonly, ss_weak) id target;

@end

@interface NSObject(SSMainThreadProxyAdditions) <SSMainThreadProxy>

@end

NS_ASSUME_NONNULL_END
