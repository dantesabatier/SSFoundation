//
//  SSSecurityScopedResource.m
//  SSFoundation
//
//  Created by Dante Sabatier on 18/11/14.
//
//

#import "SSSecurityScopedResource.h"
#import "NSObject+SSAdditions.h"
#import "NSURL+SSAdditions.h"
#import <objc/objc-sync.h>

NSString *const SSSecurityScopedResourceBookmarkDataBinding = @"securityScopedURLBookmarkData";
NSString *const SSSecurityScopedResourceURLBinding = @"securityScopedURL";

@implementation NSObject (SSSecurityScopedResourceAdditions)

- (NSData *)securityScopedURLBookmarkData {
    return nil;
}

- (NSURL *)securityScopedURL {
    NSURL *url = nil;
    NSData *securityScopedURLBookmarkData = self.securityScopedURLBookmarkData;
    if (securityScopedURLBookmarkData) {
        NSError *error = nil;
#if TARGET_OS_IPHONE
        url = [NSURL URLByResolvingBookmarkData:securityScopedURLBookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:&error];
#else
        url = [NSURL URLByResolvingBookmarkData:securityScopedURLBookmarkData options:NSURLBookmarkResolutionWithSecurityScope|NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:&error];
#endif
        if (error) {
            SSDebugLog(@"%@ %@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), error);
        }
    }
    return url;
}

#if NS_BLOCKS_AVAILABLE

- (void)accessSecurityScopedURLUsingBlock:(void(^)(BOOL accessingSecurityScopedURL))block {
    BOOL accessingSecurityScopedURL = self.startAccessingSecurityScopedURL;
    block(accessingSecurityScopedURL);
    [self stopAccessingSecurityScopedURL];
}

#endif

- (BOOL)startAccessingSecurityScopedURL {
    BOOL accessingSecurityScopedResource = NO;
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_8_0)))
    NSURL *securityScopedURL = SSSecurityScopedResourceGetURL((id)self);
    if (!securityScopedURL) {
        SSDebugLog(@"%@ %@, Warning! securityScopedURL cannot be nil", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
    if ([securityScopedURL respondsToSelector:@selector(startAccessingSecurityScopedResource)]) {
        accessingSecurityScopedResource = [securityScopedURL startAccessingSecurityScopedResource];
    }
#endif
    return accessingSecurityScopedResource;
}

- (void)stopAccessingSecurityScopedURL {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_8_0)))
    NSURL *securityScopedURL = SSSecurityScopedResourceGetURL((id)self);
    if ([securityScopedURL respondsToSelector:@selector(stopAccessingSecurityScopedResource)]) {
        [securityScopedURL stopAccessingSecurityScopedResource];
    }
#endif
}

@end

@implementation NSDictionary (SSSecurityScopedResourceAdditions)

- (NSURL *)securityScopedURL {
    if (self[SSSecurityScopedResourceURLBinding]) {
        return self[SSSecurityScopedResourceURLBinding];
    }
        
    if (self[SSSecurityScopedResourceBookmarkDataBinding]) {
#if TARGET_OS_IPHONE
        return [NSURL URLByResolvingBookmarkData:self[SSSecurityScopedResourceBookmarkDataBinding] options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:NULL];
#else
        return [NSURL URLByResolvingBookmarkData:self[SSSecurityScopedResourceBookmarkDataBinding] options:NSURLBookmarkResolutionWithSecurityScope|NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:NULL];
#endif
    }
    return nil;
}

@end

NSData *SSSecurityScopedResourceGetBookmarkData(id<SSSecurityScopedResource> self) {
    objc_sync_enter(self);
    NSData *securityScopedURLBookmarkData = nil;
    if ([self conformsToProtocol:@protocol(SSSecurityScopedResource)] && [self respondsToSelector:@selector(securityScopedURLBookmarkData)]) {
        securityScopedURLBookmarkData = self.securityScopedURLBookmarkData;
    } else {
        securityScopedURLBookmarkData = [(id)self nonControllerMarkerValueForKey:SSSecurityScopedResourceBookmarkDataBinding];
    }
    objc_sync_exit(self);
    return securityScopedURLBookmarkData;
}

NSURL *SSSecurityScopedResourceGetURL(id<SSSecurityScopedResource> self) {
    objc_sync_enter(self);
    NSURL *securityScopedURL = nil;
    if ([self conformsToProtocol:@protocol(SSSecurityScopedResource)]) {
        securityScopedURL = self.securityScopedURL;
    } else {
        securityScopedURL = [(id)self nonControllerMarkerValueForKey:SSSecurityScopedResourceURLBinding];
    } 
    objc_sync_exit(self);
    return securityScopedURL;
}

