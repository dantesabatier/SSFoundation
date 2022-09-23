//
//  NSBundle+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 6/12/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIImage.h>
#import <base/SSDefines.h>
#else
#import <AppKit/NSImage.h>
#import <AppKit/NSSound.h>
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (SSAdditions)

#if (!TARGET_OS_IPHONE && !defined(__MAC_10_6)) || TARGET_OS_IPHONE
- (nullable NSURL *)URLForImageResource:(NSString *)name NS_AVAILABLE(10_5, 4_0);
#if (!TARGET_OS_IPHONE && !defined(__MAC_10_7)) || TARGET_OS_IPHONE
- (nullable NSString *)pathForImageResource:(NSString *)name NS_AVAILABLE(10_5, 4_0);
- (nullable NSString *)pathForSoundResource:(NSString *)name;
#if TARGET_OS_IPHONE
- (nullable UIImage *)imageForResource:(NSString *)name NS_AVAILABLE(NA, 4_0);
#else
- (nullable NSImage *)imageForResource:(NSString *)name NS_AVAILABLE(10_5, NA);
#endif
#endif
#endif
- (nullable NSURL *)URLForSoundResource:(NSString *)name;
#if TARGET_OS_IPHONE
- (nullable UIImage *)imageForInfoDictionaryKey:(NSString *)key;
@property (nullable, readonly, strong) UIImage *icon;
#else
- (nullable NSImage *)imageForInfoDictionaryKey:(NSString *)key;
@property (nullable, readonly, copy) NSImage *icon;
- (nullable NSSound *)soundForResource:(NSString *)name;
#endif
@property (nullable, readonly, copy) NSString *name;
@property (nullable, readonly, copy) NSString *localizedName;
@property (nullable, readonly, copy) NSString *version;
@property (nullable, readonly, copy) NSString *shortVersion;
@property (nullable, readonly, copy) NSString *appStoreReceiptPath;

@end

NS_ASSUME_NONNULL_END

