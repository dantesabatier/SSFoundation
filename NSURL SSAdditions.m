//
//  NSURL+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 25/09/13.
//
//

#import "NSURL+SSAdditions.h"
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@implementation NSURL (SSAdditions)

#if NS_BLOCKS_AVAILABLE

- (void)accessSecurityScopedResourceUsingBlock:(void(^)(BOOL accessingSecurityScopedResource))block {
    BOOL accessingSecurityScopedResource = NO;
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_8_0)))
    if ([self respondsToSelector:@selector(startAccessingSecurityScopedResource)]) {
        accessingSecurityScopedResource = [self startAccessingSecurityScopedResource];
    }
#endif
    
    block(accessingSecurityScopedResource);
    
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_8_0)))
    if ([self respondsToSelector:@selector(stopAccessingSecurityScopedResource)] && accessingSecurityScopedResource) {
        [self stopAccessingSecurityScopedResource];
    }
#endif
}

#endif

@end

BOOL SSURLGetFinderLabel(NSURL *self, NSInteger *label, NSError **error) {
    BOOL ok = NO;
#if ((!TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED)) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9))
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5) {
        NSNumber *number = nil;
        ok = [self getResourceValue:&number forKey:NSURLLabelNumberKey error:error];
        if (number) {
            *label = number.integerValue;
        }
    } else {
        OSStatus status = noErr;
        FSRef fileRef;
        NSInteger flag = 0;
        if (self.isFileURL && CFURLGetFSRef((__bridge CFURLRef)self, &fileRef)) {
            FSCatalogInfo catalogInfo;
            status = FSGetCatalogInfo(&fileRef, kFSCatInfoNodeFlags | kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL);
            if (noErr == status) {
                if ((catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) != 0) {
                    FolderInfo *fInfo = (FolderInfo *)&catalogInfo.finderInfo;
                    flag = fInfo->finderFlags & kColor;
                } else {
                    FileInfo *fInfo = (FileInfo *)&catalogInfo.finderInfo;
                    flag = fInfo->finderFlags & kColor;
                }
            }
        }
        
        if (status == noErr) {
            ok = YES;
            *label = (flag >> 1L);
        } else {
            if (error) {
                *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            }   
        }
    }
#endif
    return ok;
}

BOOL SSURLSetFinderLabel(NSURL *self, NSInteger label, NSError **error) {
    BOOL ok = NO;
#if (!TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9))
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5) {
         ok = [self setResourceValue:@(label) forKey:NSURLLabelNumberKey error:error];
    } else {
        OSStatus status = noErr;
        FSRef fileRef;
        if (self.isFileURL && CFURLGetFSRef((__bridge CFURLRef)self, &fileRef)) {
            FSCatalogInfo catalogInfo;
            if ((status = FSGetCatalogInfo(&fileRef, kFSCatInfoNodeFlags | kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL)) == noErr) {
                label = (label << 1L);
                
                if ((catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) != 0) {
                    FolderInfo *fInfo = (FolderInfo *)&catalogInfo.finderInfo;
                    fInfo->finderFlags &= ~kColor;
                    fInfo->finderFlags |= (label & kColor);
                } else {
                    FileInfo *fInfo = (FileInfo *)&catalogInfo.finderInfo;
                    fInfo->finderFlags &= ~kColor;
                    fInfo->finderFlags |= (label & kColor);
                }
                FSSetCatalogInfo(&fileRef, kFSCatInfoFinderInfo, &catalogInfo);
            }
        }
        
        if (status == noErr) {
            ok = YES;
        } else {
            if (error) {
                *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            }
        }
    }
#endif
    return ok;
}
