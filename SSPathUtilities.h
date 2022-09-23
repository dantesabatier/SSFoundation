//
//  SSPathUtilities.h
//  SSFoundation
//
//  Created by Dante Sabatier on 24/11/12.
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

extern NSURL *__nullable SSUserDesktopDirectoryURL(void);
extern NSURL *__nullable SSUserLibraryDirectoryURL(void);
extern NSURL *__nullable SSApplicationSupportDirectoryURL(void);
extern NSURL *__nullable SSApplicationMetadataDirectoryURL(void);
extern NSURL *__nullable SSApplicationDocumentsDirectoryURL(void);
extern NSURL *__nullable SSApplicationScriptsDirectoryURL(void);
extern NSURL *__nullable SSApplicationPreferencesDirectoryURL(void);
extern NSURL *__nullable SSApplicationTemporaryDirectoryURL(void);
extern NSURL *__nullable SSApplicationCachesDirectoryURL(void);
extern NSString *__nullable SSUserDesktopDirectory(void);
extern NSString *__nullable SSUserLibraryDirectory(void);
extern NSString *__nullable SSUserTrashDirectory(void);
extern NSString *__nullable SSApplicationMetadataDirectory(void);
extern NSString *__nullable SSApplicationSupportDirectory(void);
extern NSString *__nullable SSApplicationDocumentsDirectory(void);
extern NSString *__nullable SSApplicationPreferencesDirectory(void);
extern NSString *__nullable SSApplicationScriptsDirectory(void);
extern NSString *__nullable SSApplicationTemporaryDirectory(void);
extern NSString *__nullable SSApplicationCachesDirectory(void);
extern NSArray <NSString*>*SSApplicationPluginDirectories(void);
extern NSArray <NSString*>*SSApplicationTemplateDirectories(void);
extern NSArray <NSString*>*SSApplicationThemeDirectories(void);
extern NSString *__nullable SSTemporaryDirectoryForObject(id <NSObject> obj);
extern NSString *SSGetValidFileName(NSString *basename);
extern NSString *SSGetUniqueFileName(NSString *dirpath, NSString *basename, NSString *__nullable extension);
extern NSArray <NSString*>*__nullable SSCopyItemsIfNeeded(NSArray <NSString*>*srcPaths, NSString *dstPath, NSArray <NSString*>*directoriesToCompare, NSError **__nullable error);
extern NSArray <NSString*>*__nullable SSCopyItems(NSArray <NSString*>*srcPaths, NSString *dstPath, NSError *__nullable *__nullable error);
extern NSArray <NSString*>*__nullable SSMoveItems(NSArray <NSString*>*srcPaths, NSString *dstPath, NSError *__nullable *__nullable error);
extern BOOL SSCreateDirectoryIfNeeded(NSString *directory, NSError *__nullable *__nullable error);

NS_ASSUME_NONNULL_END
