//
//  SSSecurityScopedResource.h
//  SSFoundation
//
//  Created by Dante Sabatier on 18/11/14.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSSecurityScopedResource <SSObject>

@optional
@property (nullable, nonatomic, readonly, strong) NSData *securityScopedURLBookmarkData;

@required
@property (nullable, nonatomic, readonly, strong) NSURL *securityScopedURL;

@end

@interface NSObject (SSSecurityScopedResourceAdditions) <SSSecurityScopedResource>

@property (nullable, nonatomic, readonly, strong) NSURL *securityScopedURL;
#if NS_BLOCKS_AVAILABLE
- (void)accessSecurityScopedURLUsingBlock:(void(^)(BOOL accessingSecurityScopedURL))block;
#endif
@property (nonatomic, readonly) BOOL startAccessingSecurityScopedURL;
- (void)stopAccessingSecurityScopedURL;

@end

@interface NSDictionary (SSSecurityScopedResourceAdditions) <SSSecurityScopedResource>

@property (nullable, nonatomic, readonly, strong) NSURL *securityScopedURL;

@end

extern NSData * __nullable SSSecurityScopedResourceGetBookmarkData(id <SSSecurityScopedResource> self);
extern NSURL * __nullable SSSecurityScopedResourceGetURL(id <SSSecurityScopedResource> self);

extern NSString *const SSSecurityScopedResourceBookmarkDataBinding;
extern NSString *const SSSecurityScopedResourceURLBinding;

NS_ASSUME_NONNULL_END
