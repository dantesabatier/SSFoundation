//
//  SSXMLNode+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//
//

#import "SSXMLNode+SSAdditions.h"
#import "NSArray+SSAdditions.h"
#import "NSString+SSAdditions.h"

@implementation SSXMLNode (SSAdditions)

- (NSArray <__kindof SSXMLNode*> *)childrenNamed:(NSString *)name {
    return [self.children objectsPassingTest:^BOOL(__kindof SSXMLNode * _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isCaseInsensitiveEqualToString:name];
    }];
}

- (nullable __kindof SSXMLNode *)childNamed:(NSString *)name {
    return [self.children firstObjectPassingTest:^BOOL(__kindof SSXMLNode * _Nonnull obj) {
        return [obj.name isCaseInsensitiveEqualToString:name];
    }];
}

@end
