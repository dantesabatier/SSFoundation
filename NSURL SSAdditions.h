//
//  NSURL+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 25/09/13.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (SSAdditions)

#if NS_BLOCKS_AVAILABLE
- (void)accessSecurityScopedResourceUsingBlock:(void(^)(BOOL accessingSecurityScopedResource))block;
#endif

@end

extern BOOL SSURLGetFinderLabel(NSURL *self, NSInteger *label, NSError *__nullable *__nullable error) NS_AVAILABLE(10_5, NA);
extern BOOL SSURLSetFinderLabel(NSURL *self, NSInteger label, NSError *__nullable *__nullable error) NS_AVAILABLE(10_5, NA);

NS_ASSUME_NONNULL_END
