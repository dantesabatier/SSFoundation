//
//  NSXMLNode+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSXMLNode+SSAdditions.h"
#import "NSArray+SSAdditions.h"
#import "NSString+SSAdditions.h"

@implementation NSXMLNode(SSAdditions)

- (NSArray <__kindof NSXMLNode*> *)childrenNamed:(NSString *)name {
    return [self.children objectsPassingTest:^BOOL(__kindof NSXMLNode * _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isCaseInsensitiveEqualToString:name];
    }];
}

- (nullable __kindof NSXMLNode *)childNamed:(NSString *)name {
    return [self.children firstObjectPassingTest:^BOOL(__kindof NSXMLNode * _Nonnull obj) {
        return [obj.name isCaseInsensitiveEqualToString:name];
    }];
}

@end
