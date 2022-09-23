//
//  NSUndoManager+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 03/10/14.
//
//

#import "NSUndoManager+SSAdditions.h"

@implementation NSUndoManager (SSAdditions)

- (void)registerUndoWithValue:(id)oldValue forKey:(NSString *)aKey ofObject:(id)object {
    // We can't use -prepareWithInvocationTarget: in the normal way here because it'll attempt to set a value on the NSUndoManager instead of creating an invocation.
    
    // clang complains if we pass strong pointers to -setArgument:atIndex: in ARC mode
    __unsafe_unretained id valueArgument = oldValue;
    __unsafe_unretained NSString *keyArgument = aKey;
    
    NSInvocation *resetInvocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:@selector(setValue:forKey:)]];
    [resetInvocation retainArguments]; // Do this before setting the argument so it gets captured in ARC mode
    resetInvocation.selector = @selector(setValue:forKey:);
    [resetInvocation setArgument:(void *)&valueArgument atIndex:2];
    [resetInvocation setArgument:(void *)&keyArgument atIndex:3];
    [[self prepareWithInvocationTarget:object] forwardInvocation:resetInvocation];
}

@end
