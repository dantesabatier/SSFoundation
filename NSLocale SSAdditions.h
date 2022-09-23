//
//  NSLocale+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 29/09/13.
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

@interface NSLocale (SSAdditions)

+ (nullable NSArray <NSString *>*)countryCodesForLanguageCode:(NSString *)languageCode;
+ (nullable NSString *)proposedCountryCodeForLanguageCode:(NSString *)languageCode;
+ (nullable NSArray <NSString *>*)languageCodesForCountryCode:(NSString *)countryCode;
+ (nullable NSString *)proposedLanguageCodeForCountryCode:(NSString *)countryCode;

@end

NS_ASSUME_NONNULL_END
