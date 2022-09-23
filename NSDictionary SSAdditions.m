//
//  NSDictionary+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSDictionary+SSAdditions.h"
#import "NSString+SSAdditions.h"
#import <Foundation/NSArray.h>

@implementation NSDictionary(SSAdditions)

- (id)objectForCaseInsensitiveKey:(NSString *)aKey {
    if (self[aKey]) {
        return self[aKey];
    }
	
	for (NSString *key in self.allKeys) {
        if ([key isCaseInsensitiveEqualToString:aKey]) {
            return self[key];
        }
	}
	return nil;
}

- (instancetype)mapUsingBlock:(id __nullable (NS_NOESCAPE^)(id key, id obj))block {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (NSString *key in self.allKeys) {
        id value = block(key, self[key]);
        if (value) {
            dictionary[key] = value;
        }
    }
    return dictionary;
}

@end

@implementation NSDictionary(GTMAddtions)

- (NSString *)HTTPArgumentsString {
	NSString *chars = @"!*'();:@&=+$,/?%#[]";
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:self.count];
	for (NSString *key in self) {
		[arguments addObject:[NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesWithCharactersInString:chars], [[self[key] description] stringByAddingPercentEscapesWithCharactersInString:chars]]];
	}
	return [arguments componentsJoinedByString:@"&"];
}

@end
