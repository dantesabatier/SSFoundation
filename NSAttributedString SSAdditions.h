//
//  NSAttributedString+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 13/01/13.
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

@interface NSAttributedString (SSAdditions)

- (instancetype)attributedStringByReplacingOccurrencesOfStrings:(NSArray <NSString *> *)targets withStrings:(NSArray <NSString *> *)replacements options:(NSUInteger)searchOption;
- (instancetype)attributedStringByReplacingKeysWithValuesInDictionary:(NSDictionary <NSString *, NSString *> *)dictionary options:(NSUInteger)searchOption;
- (instancetype)attributedStringByReplacingKeysWithValuesInDictionary:(NSDictionary <NSString *, NSString *> *)dictionary;

@end

NS_ASSUME_NONNULL_END
