//
//  NSSortDescriptor+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 9/6/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSSortDescriptor+SSAdditions.h"

@implementation NSSortDescriptor (SSAdditions)

+ (NSArray *)ascendingDescriptorsForKeys:(NSString *)firstKey,... {
    NSMutableArray *descriptors = [[NSMutableArray alloc] init];
    if (firstKey) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:firstKey ascending:YES];
        [descriptors addObject: descriptor];
        [descriptor release];
        
        va_list keyList;
        va_start (keyList, firstKey);
        
        NSString *key = nil;
        while ((key = va_arg(keyList, NSString *))) {
            descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];                           
            [descriptors addObject:descriptor];
            [descriptor release];
        }
        
        va_end (keyList);
    }
    return [descriptors autorelease];
}

@end
