//
//  SSXMLNode+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//
//

#import "SSXMLNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSXMLNode (SSAdditions)

- (NSArray <__kindof SSXMLNode *>*)childrenNamed:(NSString *)name;
- (nullable __kindof SSXMLNode *)childNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
