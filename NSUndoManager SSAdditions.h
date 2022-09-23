//
//  NSUndoManager+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 03/10/14.
//
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSUndoManager (SSAdditions)

- (void)registerUndoWithValue:(id)oldValue forKey:(NSString *)aKey ofObject:(id)object;

@end

NS_ASSUME_NONNULL_END
