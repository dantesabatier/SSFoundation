//
//  NSData+SSAdditions.h
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

@interface NSData(Base64Additions)

@property (readonly, copy) NSString *encodeBase64;
- (NSString *)encodeBase64WithNewlines:(BOOL)encodeWithNewlines;

@end

@interface NSData(HMACAdditions)

- (instancetype)encodedHMACDataUsingSecretKey:(NSString *)secretKey;

@end

@interface NSData(AES256Additions)

- (nullable instancetype)AES256EncryptedDataWithKey:(NSString *)key;
- (nullable instancetype)AES256DecryptedDataWithKey:(NSString *)key;

@end

@interface NSData (SSAdditions)

+ (nullable instancetype)cachedDataWithContentsOfURL:(NSURL *)URL error:(NSError *__nullable *__nullable)error;
+ (nullable instancetype)cachedDataWithContentsOfURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
