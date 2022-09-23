//
//  NSValue+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 6/12/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSValue (SSAdditions)

@property (readonly) CGSize sizeValue;
+ (instancetype)valueWithSize:(CGSize)size;
@property (readonly) CGRect rectValue;
+ (instancetype)valueWithRect:(CGRect)rect;
@property (readonly) CGPoint pointValue;
+ (instancetype)valueWithPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
