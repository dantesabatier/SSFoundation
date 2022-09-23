//
//  SSXMLNode+SSPrivate.h
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//
//

#import "SSXMLNode.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/xmlstring.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSXMLNode (SSPrivate)

- (instancetype)initWithXMLNode:(xmlNode *)node;
+ (__kindof SSXMLNode *)nodeWithXMLNode:(xmlNode *)node;
- (instancetype)initWithXMLNode:(xmlNodePtr)node freeWhenDone:(BOOL)flag;
+ (__kindof SSXMLNode *)nodeWithConsumingXMLNode:(xmlNodePtr)node;
+ (__kindof SSXMLNode *)nodeWithBorrowingXMLNode:(xmlNodePtr)node;
@property (readonly) xmlNodePtr XMLNode;
@property (readonly) xmlNodePtr XMLNodeCopy;
- (nullable NSString *)stringFromXMLString:(const xmlChar *)chars;
@property (readonly, assign) BOOL freeXMLNode;
- (void)releaseCachedValues;

@end

NS_ASSUME_NONNULL_END
