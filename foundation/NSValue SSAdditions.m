//
//  NSValue+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 6/12/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "NSValue+SSAdditions.h"

@implementation NSValue (SSAdditions)

- (CGSize)sizeValue {
    return self.CGSizeValue;
}

+ (instancetype)valueWithSize:(CGSize)size {
    return [self valueWithCGSize:size];
}

- (CGRect)rectValue {
    return self.CGRectValue;
}

+ (instancetype)valueWithRect:(CGRect)rect {
    return [self valueWithCGRect:rect];
}

- (CGPoint)pointValue {
    return self.CGPointValue;
}

+ (instancetype)valueWithPoint:(CGPoint)point {
    return [self valueWithCGPoint:point];
}

@end
