//
//  SSXMLElement.h
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import "SSXMLNode.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(XMLElement)
@interface SSXMLElement : SSXMLNode {
@package
    NSArray <__kindof SSXMLNode *> *_attributes;
}

- (nullable instancetype)initWithXMLString:(NSString *)string error:(NSError **)error;
@property (copy) NSArray<NSDictionary <NSString*, id>*>*namespaces;
- (void)addNamespace:(SSXMLNode *)namespace;
- (void)addChild:(SSXMLNode *)child;
- (void)removeChild:(SSXMLNode *)child;
- (NSArray <SSXMLElement *>*)elementsForName:(NSString *)name;
- (NSArray <SSXMLElement *>*)elementsForLocalName:(NSString *)localName URI:(NSString *)URI;
@property (nullable, readonly, copy) NSArray <__kindof SSXMLNode *> *attributes;
- (nullable SSXMLNode *)attributeForName:(NSString *)name;
- (nullable SSXMLNode *)attributeForLocalName:(NSString *)name URI:(NSString *)attributeURI;
- (void)addAttribute:(SSXMLNode *)attribute;
- (nullable NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI;

@end

NS_ASSUME_NONNULL_END
