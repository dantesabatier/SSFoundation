//
//  NSString+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSString+SSAdditions.h"
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(SSAdditions)

+ (instancetype)UUIDString {
	return (__bridge NSString *)SSAutorelease(CFUUIDCreateString(kCFAllocatorDefault, SSAutorelease(CFUUIDCreate(kCFAllocatorDefault))));
}

- (instancetype)languageCode {
    return (__bridge NSString *)SSAutorelease(CFStringTokenizerCopyBestStringLanguage((__bridge CFStringRef)self, CFRangeMake(0, self.length)));
}

+ (instancetype)stringWithOSType:(OSType)type {
#if TARGET_OS_IPHONE
    return nil;
#else
#if 0
    size_t len = sizeof(OSType);
    long addr = (unsigned long)&type;
    char cstring[5];
    
    len = (type >> 24) == 0 ? len - 1 : len;
    len = (type >> 16) == 0 ? len - 1 : len;
    len = (type >>  8) == 0 ? len - 1 : len;
    len = (type >>  0) == 0 ? len - 1 : len;
    
    addr += (4 - len);
    
    type = EndianU32_NtoB(type);      // strings are big endian
    
    strncpy(cstring, (char *)addr, len);
    cstring[len] = 0;
    
    return [NSString stringWithCString:(char *)cstring encoding:NSMacOSRomanStringEncoding];
#else
    return (__bridge NSString *)SSAutorelease(UTCreateStringForOSType(type));
#endif
#endif
}

- (instancetype)stringByTrimmingWhiteSpaces {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)isCaseInsensitiveEqualToString:(NSString *)string {
	return ([self caseInsensitiveCompare:string] == NSOrderedSame);
}

#if ((!TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED)) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_10)) || (TARGET_OS_IPHONE && defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0))

- (BOOL)containsString:(NSString *)string {
	return !self.length ? NO : ([self rangeOfString:string].location != NSNotFound);
}

- (BOOL)localizedCaseInsensitiveContainsString:(NSString *)string {
    return [self rangeOfString:string options:NSCaseInsensitiveSearch range:(NSRange){0, string.length} locale:[NSLocale autoupdatingCurrentLocale]].location != NSNotFound;
}

#endif

- (BOOL)caseInsensitiveContainsString:(NSString *)string {
    return [self rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound;
}

- (BOOL)hasCaseInsensitivePrefix:(NSString *)string {
    return [self rangeOfString:string options:NSCaseInsensitiveSearch|NSAnchoredSearch].location != NSNotFound;
}

- (BOOL)hasCaseInsensitiveSuffix:(NSString *)string {
    return [self rangeOfString:string options:NSCaseInsensitiveSearch|NSBackwardsSearch|NSAnchoredSearch].location != NSNotFound;
}

- (BOOL)containsDigits {
    return ([self rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound);
}

- (BOOL)containsOnlyDigits {
    BOOL containsOnlyDigits = YES;
    for (NSUInteger characterIndex = 0; characterIndex < self.length; characterIndex++) {
        containsOnlyDigits &= [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[self characterAtIndex:characterIndex]];
        if (!containsOnlyDigits) {
            break;
        }
    }
    return containsOnlyDigits;
}

- (instancetype)stringByDeletingAllButDigits {
    return [[self componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

- (instancetype)stringByAppendingElipsisAfterCharacters:(NSUInteger)count {
    return (self.length <= count) ? self : [[self substringToIndex:count] stringByAppendingString:@"..."];
}

- (instancetype)stringByAddingPercentEscapesWithCharactersInString:(NSString *)charactersToBeEscaped {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_9)) || (TARGET_OS_IPHONE && defined(__IPHONE_7_0)))
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:charactersToBeEscaped] invertedSet]];
#else
    return (__bridge NSString *)SSAutorelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, (__bridge CFStringRef) charactersToBeEscaped, kCFStringEncodingUTF8));
#endif
}

- (instancetype)stringByAddingURLPercentEscapes {
    return [self stringByAddingPercentEscapesWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
}

- (instancetype)stringByStrippingHTMLTags {
    NSString *string = [NSString stringWithString:self];
	NSString *text = nil;
	NSScanner *scanner = [NSScanner scannerWithString:string];
	while (!scanner.isAtEnd) {
		[scanner scanUpToString:@"<" intoString:NULL];
		[scanner scanUpToString:@">" intoString:&text];
		
		string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
	}
	return string;
}

- (instancetype)stringByReplacingOccurrencesOfStrings:(NSArray <NSString *>*)strings withString:(NSString *)replacement {
    NSMutableString *result = [[NSMutableString alloc] initWithString:self];
    for (NSString *string in strings) {
        [result replaceOccurrencesOfString:string withString:replacement options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    }
    return [result autorelease];
}

- (instancetype)stringByDeletingOccurrencesOfStrings:(NSArray <NSString *>*)strings {
    return [self stringByReplacingOccurrencesOfStrings:strings withString:@""];
}

- (instancetype)stringByReplacingCharactersInString:(NSString *)charactersString withString:(NSString *)replacement {
    NSMutableString *string = [[NSMutableString alloc] initWithString:self];
    for (NSUInteger i = 0; i < charactersString.length; i++) {
        const unichar character = [charactersString characterAtIndex:i];
        NSString *wantedString = [NSString stringWithCharacters:&character length:1];
        [string replaceOccurrencesOfString:wantedString withString:replacement options:NSLiteralSearch range:NSMakeRange(0, string.length)];
    }
	return [string autorelease];
}

- (instancetype)stringByDeletingCharactersInString:(NSString *)charactersString {
    return [self stringByReplacingCharactersInString:charactersString withString:@""];
}

- (instancetype)stringByReplacingOccurrencesOfKeysWithValuesInDictionary:(NSDictionary *)dictionary {
	NSMutableString *string = [[NSMutableString alloc] initWithString:self];
    for (id key in dictionary) {
        [string replaceOccurrencesOfString:key withString:dictionary[key] options:NSLiteralSearch range:NSMakeRange(0, string.length)];
    }
	return [string autorelease];
}

- (instancetype)lowercaseFirst {
    return [self.firstString.lowercaseString stringByAppendingString:[self substringFromIndex:1]];
}

- (instancetype)uppercaseFirst {
    return [self.firstString.uppercaseString stringByAppendingString:[self substringFromIndex:1]];
}

- (instancetype)firstString {
    return [self substringToIndex:1];
}

- (instancetype)lastString {
    return nil;
}

- (CGFloat)CGFloatValue {
#if CGFLOAT_IS_DOUBLE
    return self.doubleValue;
#else
    return self.floatValue;
#endif
}

- (NSTimeInterval)timeIntervalValue {
    NSTimeInterval interval = 0;
    NSArray <NSString *>*components = [self componentsSeparatedByString:@":"];
    switch (components.count) {
        case 1: {
            NSString *temp = [self stringByReplacingOccurrencesOfString:@"," withString:@"."];
            if (temp.containsOnlyDigits) {
                interval = temp.doubleValue;
            }
        }
            break;
        case 2:
            interval = ((components[0].doubleValue * 60.0) + [components[1] stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue);
            break;
        case 3:
            interval = ((components[0].doubleValue * 3600.0) + (components[1].doubleValue * 60.0) + [components[2] stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue);
            break;
        default:
            break;
    }
    return interval;
}

- (instancetype)stringByGettingNonexistentCharactersInString:(NSString *)string {
    if (!self.length) {
         return self;
    }
    
    if ([self isEqualToString:string]) {
        return self;
    }
    
	NSMutableString *workingString = [NSMutableString stringWithCapacity:self.length];
    for (NSUInteger i = 0; i < self.length; i++) {
        @autoreleasepool {
            NSString *wantedString = [self substringWithRange:NSMakeRange(i, 1)];
            if (i >= string.length) {
                [workingString appendString:wantedString];
                break;
            }
            
            NSString *comparisionSubstring = [string substringWithRange:NSMakeRange(i, 1)];
            
            [workingString appendString:wantedString];
            
            if (![wantedString isEqualToString:comparisionSubstring])
                break;
        }
    }
	
	return workingString;
}

- (NSArray <NSString *>*)charactersAsComponentsWithCharacterInSet:(NSCharacterSet *)characterSet {
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:self.length];
    for (NSUInteger i = 0; i < self.length; i++) {
        NSString *component = nil;
        const unichar character = [self characterAtIndex:i];
        if (characterSet && [characterSet characterIsMember:character]) {
            component = [NSString stringWithCharacters:&character length:1];
        } else {
            component = [NSString stringWithCharacters:&character length:1];
        }
        
        if (component) {
            [components addObject:component];
        }
    }
    return components;
}

- (NSArray <NSString *>*)charactersAsComponents {
    return [self charactersAsComponentsWithCharacterInSet:nil];
}

- (NSArray <NSString *>*)lettersAsComponentsWithSpecialComponents:(NSArray <NSString *>*)specialComponents {
    NSMutableArray *components = [[self charactersAsComponentsWithCharacterInSet:[NSCharacterSet letterCharacterSet]] mutableCopy];
    if (specialComponents.count) {
        BOOL ok = YES;
        NSString *string = [components componentsJoinedByString:@""];
        for (NSString *specialComponent in specialComponents) {
            if ([string caseInsensitiveContainsString:specialComponent]) {
                ok = NO;
                break;
            }
        }
        
        if (!ok) {
            [components removeAllObjects];
            
            NSUInteger index = 0;
            NSUInteger length = string.length;
            NSRange range = NSMakeRange(0, length);
            while (index < length) {
                unichar character = [string characterAtIndex:index];
                NSString *component = [NSString stringWithCharacters:&character length:1];
                NSUInteger nextIndex = index + 1;
                if (!NSLocationInRange(nextIndex, range)) {
                    [components addObject:component];
                } else {
                    unichar nextCharacter = [string characterAtIndex:nextIndex];
                    NSString *nextComponent = [NSString stringWithCharacters:&nextCharacter length:1];
                    NSString *specialComponent = [component stringByAppendingString:nextComponent];
                    if (![specialComponents containsObject:specialComponent]) {
                        [components addObject:component];
                    } else {
                        [components addObject:specialComponent];
                        
                        index += 1;
                    }
                }
                
                index ++;
            }
        }
    }
    
    return [components autorelease];
}

- (NSArray <NSString *>*)lettersAsComponents {
    return [self lettersAsComponentsWithSpecialComponents:nil];
}

- (BOOL)isVowel {
    if (self.length == 1) {
        static NSArray *vowels = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
#if !TARGET_OS_WATCH
            id obj = nil;
            NSString *notificationName = nil;
#if TARGET_OS_IPHONE
            obj = [UIApplication sharedApplication];
            notificationName = UIApplicationWillTerminateNotification;
#else
            obj = NSApp;
            notificationName = NSApplicationWillTerminateNotification;
#endif
            __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:obj queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [vowels release];
                vowels = nil;
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
            }];
#endif
            vowels = [@[@"a", @"e", @"i", @"o", @"u"] copy];
        });
        return [vowels containsObject:self.ASCIIString.lowercaseString];
    }
    return NO;
}

@end

@implementation NSString (SSEncodingAdditions)

- (instancetype)ASCIIString {
    return [[[NSString alloc] initWithData:[self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding] autorelease];
}

- (instancetype)MD5String {
    const char *cStr = self.UTF8String;
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStr, (uint32_t)strlen(cStr), result);
	NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
		[string appendFormat:@"%02x", result[i]];
	}
	return string;
}

@end

@implementation NSString (SSPathAdditions)

- (NSString *)absoluteURLString {
    return [[NSFileManager defaultManager] fileExistsAtPath:self] ? [NSURL fileURLWithPath:self].absoluteString : nil;
}

@end

@implementation NSString (TSVAdditions)

- (NSArray *)TSVComponents {
    NSMutableArray *components = [NSMutableArray array];
    NSArray *lines = [self componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        @autoreleasepool {
            if (![line isEqualToString:@""] && ![line hasPrefix:@"#"]) {
                [components addObject:[line componentsSeparatedByString:@"\t"]];
            }
        }
    }
    return components;
}

- (NSArray *)CSVComponents {
    NSMutableArray *components = [NSMutableArray array];
    
    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet].invertedSet];
    
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = [NSMutableCharacterSet characterSetWithCharactersInString:@",\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
    
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    
    while (!scanner.isAtEnd) {
        @autoreleasepool {
            BOOL insideQuotes = NO;
            BOOL finishedRow = NO;
            NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
            NSMutableString *currentColumn = [NSMutableString string];
            while (!finishedRow) {
                NSString *tempString;
                if ([scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString]) {
                    [currentColumn appendString:tempString];
                }
                
                if (scanner.isAtEnd) {
                    if (![currentColumn isEqualToString:@""]) {
                        [columns addObject:currentColumn];
                    }
                        
                    finishedRow = YES;
                } else if ([scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString]) {
                    if (insideQuotes) {
                        // Add line break to column text
                        [currentColumn appendString:tempString];
                    } else {
                        // End of row
                        if (![currentColumn isEqualToString:@""])
                            [columns addObject:currentColumn];
                        finishedRow = YES;
                    }
                } else if ([scanner scanString:@"\"" intoString:NULL]) {
                    if (insideQuotes && [scanner scanString:@"\"" intoString:NULL]) {
                        // Replace double quotes with a single quote in the column string.
                        [currentColumn appendString:@"\""];
                    } else {
                        // Start or end of a quoted string.
                        insideQuotes = !insideQuotes;
                    }
                } else if ([scanner scanString:@"," intoString:NULL]) {
                    if (insideQuotes) {
                        [currentColumn appendString:@","];
                    } else {
                        // This is a column separating comma
                        [columns addObject:currentColumn];
                        currentColumn = [NSMutableString string];
                        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                    }
                }
            }
            
            if (columns.count) {
                [components addObject:columns];
            }
        }
    }
    
    return components;
}

@end

