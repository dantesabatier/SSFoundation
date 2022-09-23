//
//  NSLocale+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 29/09/13.
//
//

#import "NSLocale+SSAdditions.h"

@implementation NSLocale (SSAdditions)

+ (nullable NSArray <NSString *>*)countryCodesForLanguageCode:(NSString *)languageCode {
    if (languageCode.length) {
        NSMutableArray *countryCodes = [NSMutableArray array];
        NSArray *availableLocaleIdentifiers = [NSLocale availableLocaleIdentifiers];
        for (NSString *localeIdentifier in availableLocaleIdentifiers) {
            NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier] autorelease];
            if ([[locale objectForKey:NSLocaleLanguageCode] isEqualToString:languageCode] && [locale objectForKey:NSLocaleCountryCode]) {
                [countryCodes addObject:[locale objectForKey:NSLocaleCountryCode]];
            }
        }
        return countryCodes;
    }
    return nil;
}

+ (nullable NSString *)proposedCountryCodeForLanguageCode:(NSString *)languageCode {
    return [languageCode isEqualToString:@"en"] ? @"US" : [self countryCodesForLanguageCode:languageCode].firstObject;
}

+ (nullable NSArray <NSString *>*)languageCodesForCountryCode:(NSString *)countryCode {
    if (countryCode.length) {
        NSMutableArray *languageCodes = [NSMutableArray array];
        NSArray *availableLocaleIdentifiers = [NSLocale availableLocaleIdentifiers];
        for (NSString *localeIdentifier in availableLocaleIdentifiers) {
            NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier] autorelease];
            if ([[locale objectForKey:NSLocaleCountryCode] isEqualToString:countryCode] && [locale objectForKey:NSLocaleLanguageCode]) {
                [languageCodes addObject:[locale objectForKey:NSLocaleLanguageCode]];
            }
        }
        return languageCodes;
    }
    return nil;
}

+ (nullable NSString *)proposedLanguageCodeForCountryCode:(NSString *)countryCode {
    if ([countryCode isEqualToString:@"US"] || [countryCode isEqualToString:@"CA"]) {
        return @"en";
    }
    return [self languageCodesForCountryCode:countryCode].firstObject;
}

@end
