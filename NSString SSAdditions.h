//
//  NSString+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SSAdditions)

@property (nullable, readonly, copy) NSString *languageCode;
+ (instancetype)UUIDString;
+ (nullable instancetype)stringWithOSType:(OSType)type NS_AVAILABLE(10_5, NA);
@property (readonly, strong) NSString *stringByTrimmingWhiteSpaces;
- (BOOL)isCaseInsensitiveEqualToString:(NSString *)string;
#if (!TARGET_OS_IPHONE && !defined(__MAC_10_10)) || (TARGET_OS_IPHONE && !defined(__IPHONE_8_0))
- (BOOL)containsString:(NSString *)string;
- (BOOL)localizedCaseInsensitiveContainsString:(NSString *)string;
#endif
- (BOOL)caseInsensitiveContainsString:(NSString *)string;
- (BOOL)hasCaseInsensitivePrefix:(NSString *)string;
- (BOOL)hasCaseInsensitiveSuffix:(NSString *)string;
@property (readonly) BOOL containsDigits;
@property (readonly) BOOL containsOnlyDigits;
@property (nullable, readonly, copy) NSString *stringByDeletingAllButDigits;
- (instancetype)stringByAppendingElipsisAfterCharacters:(NSUInteger)count;
- (instancetype)stringByAddingPercentEscapesWithCharactersInString:(NSString *)charactersToBeEscaped;
@property (readonly, strong) NSString *stringByAddingURLPercentEscapes;
@property (readonly, strong) NSString *stringByStrippingHTMLTags;
- (instancetype)stringByReplacingOccurrencesOfStrings:(NSArray <NSString *>*)strings withString:(NSString *)replacement;
- (instancetype)stringByDeletingOccurrencesOfStrings:(NSArray <NSString *>*)strings;
- (instancetype)stringByReplacingCharactersInString:(NSString *)charactersString withString:(NSString *)replacement;
- (instancetype)stringByDeletingCharactersInString:(NSString *)charactersString;
- (instancetype)stringByReplacingOccurrencesOfKeysWithValuesInDictionary:(NSDictionary <NSString *, NSString *> *)dictionary;
@property (nullable, readonly, strong) NSString *firstString;
@property (nullable, readonly, strong) NSString *lastString;
@property (nullable, readonly, strong) NSString *lowercaseFirst;
@property (nullable, readonly, strong) NSString *uppercaseFirst;
@property (readonly) CGFloat CGFloatValue;
@property (readonly) NSTimeInterval timeIntervalValue;
- (instancetype)stringByGettingNonexistentCharactersInString:(NSString *)string;
- (NSArray <NSString *>*)charactersAsComponentsWithCharacterInSet:(nullable NSCharacterSet *)characterSet;
- (NSArray <NSString *>*)lettersAsComponentsWithSpecialComponents:(nullable NSArray <NSString *>*)specialComponents;
@property (readonly, copy) NSArray <NSString *>*charactersAsComponents;
@property (readonly, copy) NSArray <NSString *>*lettersAsComponents;
@property (getter=isVowel, readonly) BOOL vowel;

@end

@interface NSString (SSEncodingAdditions)

@property (readonly, strong) NSString *ASCIIString;
@property (readonly, strong) NSString *MD5String;

@end

@interface NSString (SSPathAdditions)

@property (nullable, readonly, strong) NSString *absoluteURLString;

@end

@interface NSString (TSVAdditions)

@property (readonly, copy) NSArray <NSArray <NSString *>*> *TSVComponents;
@property (readonly, copy) NSArray <NSArray <NSString *>*> *CSVComponents;

@end

NS_ASSUME_NONNULL_END
