//
//  NSAttributedString+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 13/01/13.
//
//

#import "NSAttributedString+SSAdditions.h"

@implementation NSAttributedString (SSAdditions)

- (instancetype)attributedStringByReplacingOccurrencesOfStrings:(NSArray <NSString *> *)targets withStrings:(NSArray <NSString *> *)replacements options:(NSUInteger)searchOption {
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:self];
	NSString *string = result.string;
    [targets enumerateObjectsUsingBlock:^(id target, NSUInteger idx, BOOL *stop) {
        id replacement = replacements[idx];
		if ([target isKindOfClass:[NSString class]] && [replacement isKindOfClass:[NSString class]]) {
            NSRange replaceRange = NSMakeRange(0, string.length);
            NSRange firstOccurence = [string rangeOfString:target options:searchOption range:replaceRange];
            if (firstOccurence.length) {
                NSRange rangeInOriginalString = replaceRange = NSUnionRange(firstOccurence, [string rangeOfString:target options:(NSBackwardsSearch|searchOption) range:replaceRange]);
                NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] init];
                [temp beginEditing];
                
                while (rangeInOriginalString.length > 0) {
                    @autoreleasepool {
                        NSRange foundRange = [string rangeOfString:target options:searchOption range:rangeInOriginalString];
                        NSRange rangeToCopy = NSMakeRange(rangeInOriginalString.location, foundRange.location - rangeInOriginalString.location + 1);
                        [temp appendAttributedString:[result attributedSubstringFromRange:rangeToCopy]];
                        [temp replaceCharactersInRange:NSMakeRange(temp.length - 1, 1) withString:replacement];
                        
                        rangeInOriginalString.length -= NSMaxRange(foundRange) - rangeInOriginalString.location;
                        rangeInOriginalString.location = NSMaxRange(foundRange);
                    }
                }
                
                [temp endEditing];
                
                [result replaceCharactersInRange:replaceRange withAttributedString:temp];
                [temp release];
            }
        }
    }];
    
	return [result autorelease];
}

- (instancetype)attributedStringByReplacingKeysWithValuesInDictionary:(NSDictionary <NSString *, NSString *> *)dictionary options:(NSUInteger)searchOption {
	return [self attributedStringByReplacingOccurrencesOfStrings:dictionary.allKeys withStrings:dictionary.allValues options:searchOption];
}

- (instancetype)attributedStringByReplacingKeysWithValuesInDictionary:(NSDictionary <NSString *, NSString *> *)dictionary {
	return [self attributedStringByReplacingKeysWithValuesInDictionary:dictionary options:NSLiteralSearch];
}

@end
