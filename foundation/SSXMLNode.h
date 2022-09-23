//
//  SSXMLNode.h
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif
#import "SSXMLNodeOptions.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSXMLNodeKind) {
    SSXMLInvalidKind = 0,
    SSXMLDocumentKind,
    SSXMLElementKind,
    SSXMLAttributeKind,
    SSXMLNamespaceKind,
    SSXMLProcessingInstructionKind,
    SSXMLCommentKind,
    SSXMLTextKind,
    SSXMLDTDKind,
    SSXMLEntityDeclarationKind,
    SSXMLAttributeDeclarationKind,
    SSXMLElementDeclarationKind,
    SSXMLNotationDeclarationKind
} NS_SWIFT_NAME(XMLNode.Kind);

@class SSXMLElement;

NS_SWIFT_NAME(XMLNode)
@interface SSXMLNode : NSObject <NSCopying> {
@package
    id _reserved;
    BOOL _freeXMLNode;
    NSString *_name;
    NSArray <__kindof SSXMLNode *> *_children;
}

+ (nullable SSXMLElement *)elementWithName:(NSString *)name;
+ (nullable SSXMLElement *)elementWithName:(NSString *)name stringValue:(NSString *)value;
+ (nullable SSXMLElement *)elementWithName:(NSString *)name URI:(NSString *)value;
+ (nullable __kindof SSXMLNode *)attributeWithName:(NSString *)name stringValue:(NSString *)value;
+ (nullable __kindof SSXMLNode *)attributeWithName:(NSString *)name URI:(NSString *)attributeURI stringValue:(NSString *)value;
+ (nullable __kindof SSXMLNode *)namespaceWithName:(NSString *)name stringValue:(NSString *)value;
+ (nullable __kindof SSXMLNode *)textWithStringValue:(NSString *)value;
@property (nullable, copy) NSString *stringValue;
@property (nullable, readonly) NSArray <__kindof SSXMLNode *>*children;
@property (readonly) NSUInteger childCount;
- (__kindof SSXMLNode *)childAtIndex:(unsigned)index;
@property (readonly, copy) NSString *localName;
@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *prefix;
@property (readonly, copy) NSString *URI;
@property (readonly) SSXMLNodeKind kind;
- (NSString *)XMLStringWithOptions:(SSXMLNodeOptions)options;
@property (readonly, copy) NSString *XMLString;
+ (NSString *)localNameForName:(NSString *)name;
+ (NSString *)prefixForName:(NSString *)name;
- (nullable NSArray <__kindof SSXMLNode *>*)nodesForXPath:(NSString *)xpath namespaces:(nullable NSDictionary <NSString *, id>*)namespaces error:(NSError *__nullable * __nullable)error;
- (nullable NSArray <__kindof SSXMLNode *>*)nodesForXPath:(NSString *)xpath error:(NSError *__nullable * __nullable)error;

@end

NS_ASSUME_NONNULL_END
