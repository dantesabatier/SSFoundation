//
//  SSTimeFormatter.h
//  SSFoundation
//
//  Created by Dante Sabatier on 13/04/16.
//
//

#import <Foundation/Foundation.h>

@interface SSTimeFormatter : NSFormatter

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;

@end
