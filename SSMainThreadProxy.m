//
//  SSMainThreadProxy.m
//  SSTaskKit
//
//  Created by Dante Sabatier on 5/5/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSMainThreadProxy.h"

@interface SSMainThreadProxy ()

@end

@implementation SSMainThreadProxy

- (instancetype)initWithTarget:(id)target {
	self = [super init];
	if (self) {
		_target = target;
	}
	return self;
}

- (void)dealloc {
	_target = nil;

	[super ss_dealloc];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	return ([super respondsToSelector:aSelector] || [_target respondsToSelector:aSelector]);
}

- (id)performSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        [super performSelector:aSelector];
    }
	
    if (![_target respondsToSelector:aSelector]) {
        [self doesNotRecognizeSelector:aSelector];
    }
    
	[_target ss_retain];
	[_target performSelectorOnMainThread:aSelector withObject:nil waitUntilDone:YES];
	[_target release];
	
	return nil;
}

- (id)performSelector:(SEL)aSelector withObject:(id)object {
    if ([super respondsToSelector:aSelector]) {
        [super performSelector:aSelector withObject:object];
    }
	
    if (![_target respondsToSelector:aSelector]) {
        [self doesNotRecognizeSelector:aSelector];
    }
    
	[_target ss_retain];
	[object ss_retain];
	[_target performSelectorOnMainThread:aSelector withObject:object waitUntilDone:YES];
	[object release];
	[_target release];
	
	return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	SEL aSelector = anInvocation.selector;
	if ([_target respondsToSelector:aSelector]) {
		[anInvocation retainArguments];
		[_target ss_retain];
		[anInvocation performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:_target waitUntilDone:YES];
		[_target release];
    } else {
        [self doesNotRecognizeSelector:aSelector];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	NSMethodSignature *ms = [super methodSignatureForSelector:aSelector];
    if (ms) {
        return ms;
    }
	return [_target methodSignatureForSelector:aSelector];
}

- (id)target {
    return _target;
}

- (id)mainThreadProxy {
	return self;
}

- (id)copyMainThreadProxy {
	return [self ss_retain];
}

@end


@implementation NSObject(SSMainThreadProxyAdditions)

- (id)mainThreadProxy {
	return [[[SSMainThreadProxy alloc] initWithTarget:self] autorelease];
}

- (id)copyMainThreadProxy {
	return [[SSMainThreadProxy alloc] initWithTarget:self];
}

@end
