//
//  SSPathUtilities.m
//  SSFoundation
//
//  Created by Dante Sabatier on 24/11/12.
//
//

#import "SSPathUtilities.h"
#import "NSBundle+SSAdditions.h"
#import "NSFileManager+SSAdditions.h"

NSURL *SSUserDesktopDirectoryURL() {
    return SSFileManagerGetUserDesktopDirectoryURL([NSFileManager defaultManager]);
}

NSURL *SSUserLibraryDirectoryURL() {
    return SSFileManagerGetUserLibraryDirectoryURL([NSFileManager defaultManager]);
}

NSURL *SSApplicationSupportDirectoryURL() {
    return SSFileManagerGetApplicationSupportDirectoryURL([NSFileManager defaultManager]);
}

NSURL *SSApplicationMetadataDirectoryURL() {
    return SSFileManagerGetApplicationMetadataDirectoryURL([NSFileManager defaultManager]);
}

NSURL *SSApplicationDocumentsDirectoryURL() {
    return SSFileManagerGetApplicationDocumentsDirectoryURL([NSFileManager defaultManager]);
}

NSURL *SSApplicationScriptsDirectoryURL() {
    return [[SSUserLibraryDirectoryURL() URLByAppendingPathComponent:@"Scripts"] URLByAppendingPathComponent:@"Application Scripts"];
}

NSURL *SSApplicationPreferencesDirectoryURL() {
    return [SSUserLibraryDirectoryURL() URLByAppendingPathComponent:@"Preferences"];
}

NSURL *SSApplicationTemporaryDirectoryURL() {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier]];
}

NSURL *SSApplicationCachesDirectoryURL() {
    return SSFileManagerGetApplicationCachesDirectoryURL([NSFileManager defaultManager]);
}

NSString *SSUserDesktopDirectory() {
    return SSUserDesktopDirectoryURL().path;
}

NSString *SSUserLibraryDirectory() {
    return SSUserLibraryDirectoryURL().path;
}

NSString *SSApplicationMetadataDirectory() {
    return SSApplicationMetadataDirectoryURL().path;
}

NSString *SSApplicationSupportDirectory() {
    return SSApplicationSupportDirectoryURL().path;
}

NSString *SSApplicationDocumentsDirectory() {
    return SSApplicationDocumentsDirectoryURL().path;
}

NSString *SSApplicationScriptsDirectory() {
    return SSApplicationScriptsDirectoryURL().path;
}

NSString *SSApplicationPreferencesDirectory() {
    return SSApplicationPreferencesDirectoryURL().path;
}

NSString *SSApplicationTemporaryDirectory() {
	return SSApplicationTemporaryDirectoryURL().path;
}

NSString *SSApplicationCachesDirectory() {
    return SSApplicationCachesDirectoryURL().path;
}

NSArray *SSApplicationPluginDirectories() {
	NSMutableArray *directories = [NSMutableArray arrayWithCapacity:3];
	[directories addObject:[NSBundle mainBundle].builtInPlugInsPath];
	[directories addObject:[SSApplicationSupportDirectory() stringByAppendingPathComponent:@"Plugins"]];
    NSString *directory = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSLocalDomainMask, YES).firstObject stringByAppendingPathComponent:NSBundle.mainBundle.name] stringByAppendingPathComponent:@"Plugins"];
    if (directory) {
        [directories addObject:directory];
    }
	return directories;
}

NSArray *SSApplicationTemplateDirectories() {
	NSMutableArray *directories = [NSMutableArray arrayWithCapacity:3];
    NSString *directory = [[NSBundle mainBundle] pathForResource:@"Templates" ofType:@""];
    if (directory) {
        [directories addObject:directory];
    }
	[directories addObject:[SSApplicationSupportDirectory() stringByAppendingPathComponent:@"Templates"]];
    NSString *directory2 = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSLocalDomainMask, YES).firstObject stringByAppendingPathComponent:NSBundle.mainBundle.name] stringByAppendingPathComponent:@"Templates"];
    if (directory2) {
        [directories addObject:directory2];
    }
        
	return directories;
}

NSArray *SSApplicationThemeDirectories() {
    NSMutableArray *directories = [NSMutableArray arrayWithCapacity:3];
    NSString *directory = [[NSBundle mainBundle] pathForResource:@"Themes" ofType:@""];
    if (directory) {
        [directories addObject:directory];
    }
        
	[directories addObject:[SSApplicationSupportDirectory() stringByAppendingPathComponent:@"Themes"]];
    NSString *directory2 = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSLocalDomainMask, YES).firstObject stringByAppendingPathComponent:NSBundle.mainBundle.name] stringByAppendingPathComponent:@"Themes"];
    if (directory2) {
        [directories addObject:directory2];
    }
        
	return directories;
}

NSString *SSUserTrashDirectory() {
	return [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
}

NSString *SSTemporaryDirectoryForObject(id <NSObject> obj) {
	return [SSApplicationTemporaryDirectory() stringByAppendingPathComponent:NSStringFromClass(obj.class)];
}

NSString *SSGetValidFileName(NSString *basename) {
	return SSFileManagerGetValidFileName([NSFileManager defaultManager], basename);
}

NSString *SSGetUniqueFileName(NSString *dirpath, NSString *basename, NSString *__nullable extension) {
	return SSFileManagerGetUniqueFileName([NSFileManager defaultManager], dirpath, basename, extension);
}

NSArray *SSCopyItemsIfNeeded(NSArray *srcPaths, NSString *dstPath, NSArray *directoriesToCompare, NSError **error) {
	return SSFileManagerCopyItemsIfNeeded([NSFileManager defaultManager], srcPaths, dstPath, directoriesToCompare, error);
}

NSArray *SSCopyItems(NSArray *srcPaths, NSString *dstPath, NSError **error) {
    return SSFileManagerCopyItems([NSFileManager defaultManager], srcPaths, dstPath, error);
}

NSArray *SSMoveItems(NSArray *srcPaths, NSString *dstPath, NSError **error) {
    return SSFileManagerMoveItems([NSFileManager defaultManager], srcPaths, dstPath, error);
}

BOOL SSCreateDirectoryIfNeeded(NSString *directory, NSError **error) {
	return SSFileManagerCreateDirectoryIfNeeded([NSFileManager defaultManager], directory, error);
}
