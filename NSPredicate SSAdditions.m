//
//  NSPredicate+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSPredicate+SSAdditions.h"
#import "NSString+SSAdditions.h"

@implementation NSPredicate(SSAdditions)

- (instancetype)predicateByReplacingStringsWithConstants:(NSArray *)constants {
	NSString *predicateFormat = self.predicateFormat;
	for (NSString *constant in constants) {
        if ([predicateFormat rangeOfString:constant].location != NSNotFound) {
            predicateFormat = [predicateFormat stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", constant] withString:constant];
        } 
	}
	return [NSPredicate predicateWithFormat:predicateFormat];
}

@end
