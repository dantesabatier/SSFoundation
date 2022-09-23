//
//  NSXMLNode+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <Foundation/NSXMLNode.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSXMLNode(SSAdditions)

- (NSArray <__kindof NSXMLNode*> *)childrenNamed:(NSString *)name;
- (nullable __kindof NSXMLNode *)childNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
