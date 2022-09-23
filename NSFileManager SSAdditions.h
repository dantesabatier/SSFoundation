//
//  NSFileManager+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager(SSAdditions)

- (BOOL)trashItemAtPath:(NSString *)path NS_AVAILABLE(10_5, NA);
- (BOOL)isHiddenFileAtPath:(NSString *)path NS_AVAILABLE(10_5, 4_0);
#if NS_BLOCKS_AVAILABLE
- (void)enumerateContentsOfURL:(NSURL *)baseURL includingResourceValuesForKeys:(NSArray <NSString *> *)keys usingBlock:(BOOL (NS_NOESCAPE ^)(NSURL *URL, NSDictionary <NSString *, id>*__nullable resourceValues, NSError *__nullable error, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);
#endif

@end

extern BOOL SSFileManagerCreateDirectoryIfNeeded(NSFileManager *self, NSString *directory, NSError *__nullable *__nullable error);
extern NSArray <NSString*>*__nullable SSFileManagerCopyItemsIfNeeded(NSFileManager *self, NSArray <NSString*>*srcPaths, NSString *dstPath, NSArray <NSString*>*directoriesToCompare, NSError *__nullable *__nullable error);
extern NSArray <NSString*>* __nullable SSFileManagerCopyItems(NSFileManager *self, NSArray <NSString*>*srcPaths, NSString *dstPath, NSError *__nullable *__nullable error);
extern NSArray <NSString*>* __nullable SSFileManagerMoveItems(NSFileManager *self, NSArray <NSString*>*srcPaths, NSString *dstPath, NSError *__nullable *__nullable error);
extern NSString *SSFileManagerGetValidFileName(NSFileManager *self, NSString *basename);
extern NSString *SSFileManagerGetUniqueFileName(NSFileManager *self, NSString *dirpath, NSString *basename, NSString *__nullable extension);
extern NSURL *__nullable SSFileManagerGetUserDesktopDirectoryURL(NSFileManager *self) NS_AVAILABLE(10_6, 4_0);
extern NSURL *__nullable SSFileManagerGetUserLibraryDirectoryURL(NSFileManager *self) NS_AVAILABLE(10_6, 4_0);
extern NSURL *__nullable SSFileManagerGetApplicationSupportDirectoryURL(NSFileManager *self) NS_AVAILABLE(10_6, 4_0);
extern NSURL *__nullable SSFileManagerGetApplicationCachesDirectoryURL(NSFileManager *self) NS_AVAILABLE(10_6, 4_0);
extern NSURL *__nullable SSFileManagerGetApplicationMetadataDirectoryURL(NSFileManager *self) NS_AVAILABLE(10_6, 4_0);
extern NSURL *__nullable SSFileManagerGetApplicationDocumentsDirectoryURL(NSFileManager *self) NS_AVAILABLE(10_6, 4_0);

extern NSString *const SSFileManagerAssociatedEnumeratorStoppedValueKey;

NS_ASSUME_NONNULL_END
