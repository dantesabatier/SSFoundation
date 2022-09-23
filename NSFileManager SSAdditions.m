//
//  NSFileManager+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSFileManager+SSAdditions.h"
#import "NSBundle+SSAdditions.h"
#import "NSArray+SSAdditions.h"
#import "NSObject+SSAdditions.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <AppKit/NSWorkspace.h>
#endif

NSString *const SSFileManagerAssociatedEnumeratorStoppedValueKey = @"SSFileManagerAssociatedEnumeratorStoppedValue";

@implementation NSFileManager(SSAdditions)

- (BOOL)trashItemAtPath:(NSString *)path {
#if !TARGET_OS_IPHONE
#if defined(__MAC_10_8)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_7) {
        return [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:path] resultingItemURL:NULL error:NULL];
    }
#endif
    return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:path.stringByDeletingLastPathComponent destination:@"" files:@[path.lastPathComponent] tag:NULL];
#endif
    return NO;
}

- (BOOL)isHiddenFileAtPath:(NSString *)path {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_6)) || (TARGET_OS_IPHONE && defined(__IPHONE_4_0)))
    NSURL *URL = [NSURL fileURLWithPath:path];
    if ([URL respondsToSelector:@selector(getResourceValue:forKey:error:)]) {
        NSNumber *number = nil;
        [URL getResourceValue:&number forKey:NSURLIsHiddenKey error:NULL];
        return number.boolValue;
    }
#endif
#if TARGET_OS_IPHONE
    return [path.lastPathComponent hasPrefix:@"."];
#else
    LSItemInfoRecord itemInfo;
    return ((LSCopyItemInfoForURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], kLSRequestBasicFlagsOnly, &itemInfo) == noErr) && (itemInfo.flags & kLSItemInfoIsInvisible));
#endif
}

#if NS_BLOCKS_AVAILABLE

- (void)enumerateContentsOfURL:(NSURL *)baseURL includingResourceValuesForKeys:(NSArray *)keys usingBlock:(BOOL (NS_NOESCAPE ^)(NSURL *URL, NSDictionary <NSString*, id>*resourceValues, NSError *error, BOOL *stop))block {
    BOOL isDirectory;
    BOOL isStopped = NO;
    if ([self fileExistsAtPath:baseURL.path isDirectory:&isDirectory]) {
        NSError *error = nil;
        NSDictionary *resourceValues = [baseURL resourceValuesForKeys:keys error:&error];
        if (isDirectory) {
            if (block(baseURL, resourceValues, error, &isStopped) && !isStopped) {
                NSArray *contents = [self contentsOfDirectoryAtPath:baseURL.path error:&error];
                for (NSString *component in contents) {
                    [self enumerateContentsOfURL:[baseURL URLByAppendingPathComponent:component] includingResourceValuesForKeys:keys usingBlock:block];
                    if ([[self associatedValueForKey:SSFileManagerAssociatedEnumeratorStoppedValueKey] boolValue]) {
                        break;
                    }
                }
                [self setAssociatedValue:nil forKey:SSFileManagerAssociatedEnumeratorStoppedValueKey];
            }
        } else {
            block(baseURL, resourceValues, error, &isStopped);
            [self setAssociatedValue:@(isStopped) forKey:SSFileManagerAssociatedEnumeratorStoppedValueKey];
        }
    }
}

#endif

@end

BOOL SSFileManagerCreateDirectoryIfNeeded(NSFileManager *self, NSString *directory, NSError **error) {
	NSCParameterAssert(directory);
	
	BOOL isDirectory = NO;
    if ([self fileExistsAtPath:directory isDirectory:&isDirectory] && isDirectory) {
        return YES;
    }
	return [self createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:error];
}

NSArray *SSFileManagerCopyItemsIfNeeded(NSFileManager *self, NSArray *srcPaths, NSString *dstPath, NSArray *directoriesToCompare, NSError **error) {
    if (!srcPaths.count || !SSFileManagerCreateDirectoryIfNeeded(self, dstPath, error)) {
        return nil;
    }
    
    if (!directoriesToCompare) {
        directoriesToCompare = @[dstPath];
    }
    
    if (![directoriesToCompare containsObject:dstPath]) {
        directoriesToCompare = [directoriesToCompare arrayByAddingObject:dstPath];
    }
	
	NSMutableArray *existingFilenames = [NSMutableArray array];
    for (NSString *directory in directoriesToCompare) {
        [existingFilenames addObjectsFromArray:[self contentsOfDirectoryAtPath:directory error:error]];
    }
    
    NSMutableArray *result = [NSMutableArray array];
	for (NSString *path in srcPaths) {
		NSString *filename = path.lastPathComponent;
        if ([existingFilenames containsObject:filename]) {
            continue;
        }
        
        NSString *newPath = [dstPath stringByAppendingPathComponent:filename];
        if ([self copyItemAtPath:path toPath:newPath error:error]) {
            [result addObject:newPath];
        }
	}
    
    return result;
}

NSArray *SSFileManagerCopyItems(NSFileManager *self, NSArray *srcPaths, NSString *dstPath, NSError **error) {
    if (!srcPaths.count || !SSFileManagerCreateDirectoryIfNeeded(self, dstPath, error)) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
	for (NSString *path in srcPaths) {
        NSString *newPath = [dstPath stringByAppendingPathComponent:path.lastPathComponent];
        [self removeItemAtPath:newPath error:NULL];
        if ([self copyItemAtPath:path toPath:newPath error:error]) {
            [result addObject:newPath];
        }
	}
    
    return result;
}

NSArray *SSFileManagerMoveItems(NSFileManager *self, NSArray *srcPaths, NSString *dstPath, NSError **error) {
    if (!srcPaths.count || !SSFileManagerCreateDirectoryIfNeeded(self, dstPath, error)) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
	for (NSString *path in srcPaths) {
        NSString *newPath = [dstPath stringByAppendingPathComponent:path.lastPathComponent];
        [self removeItemAtPath:newPath error:NULL];
        if ([self moveItemAtPath:path toPath:newPath error:error]) {
            [result addObject:newPath];
        }
	}
    
    return result;
}

NSString *SSFileManagerGetValidFileName(NSFileManager *self, NSString *basename) {
    NSString *fileName = [basename stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    return [self stringWithFileSystemRepresentation:fileName.UTF8String length:fileName.length];
}

NSString *SSFileManagerGetUniqueFileName(NSFileManager *self, NSString *dirpath, NSString *basename, NSString *__nullable extension) {
    NSString *validName = SSFileManagerGetValidFileName(self, basename);
	NSInteger uniqueNum = 0;
	NSString *filename = nil;
	while (!filename) {
        NSString *path = [NSString stringWithFormat:@"%@/%@%@%@", dirpath, validName, uniqueNum ? [NSString stringWithFormat:@"-%@", @(uniqueNum)] : @"", extension.length ? [NSString stringWithFormat:@".%@", extension] : @""];
        if ([self fileExistsAtPath:path]) {
            uniqueNum++;
        } else {
            filename = path.lastPathComponent;
        }
	}
	return filename;
}

NSURL *SSFileManagerGetUserDesktopDirectoryURL(NSFileManager *self) {
    return [self URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL];
}

NSURL *SSFileManagerGetUserLibraryDirectoryURL(NSFileManager *self) {
    return [self URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL];
}

NSURL *SSFileManagerGetApplicationSupportDirectoryURL(NSFileManager *self) {
    return [[self URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL] URLByAppendingPathComponent:NSBundle.mainBundle.name];
}

NSURL *SSFileManagerGetApplicationCachesDirectoryURL(NSFileManager *self) {
    return [[self URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL] URLByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier];
}

NSURL *SSFileManagerGetApplicationMetadataDirectoryURL(NSFileManager *self) {
    return [[[self URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL] URLByAppendingPathComponent:@"Metadata"] URLByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier];
}

NSURL *SSFileManagerGetApplicationDocumentsDirectoryURL(NSFileManager *self) {
    return [self URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
}
