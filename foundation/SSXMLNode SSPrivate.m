//
//  SSXMLNode+SSPrivate.m
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//
//

#import "SSXMLNode+SSPrivate.h"
#import "SSXMLElement.h"
#import "NSString+SSAdditions.h"

@implementation SSXMLNode (SSPrivate)

- (instancetype)initWithXMLNode:(xmlNode *)node {
    if (!node) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _reserved = (__bridge id)xmlCopyNode(node, 1);
    }
    return self;
}

+ (__kindof SSXMLNode *)nodeWithXMLNode:(xmlNode *)node {
    Class theClass = (node->type == XML_ELEMENT_NODE) ? [SSXMLElement class] : [SSXMLNode class];
    return [[[theClass alloc] initWithXMLNode:node] autorelease];
}

- (instancetype)initWithXMLNode:(xmlNodePtr)node freeWhenDone:(BOOL)flag {
    self = [super init];
    if (self) {
        _reserved = (__bridge id)xmlCopyNode(node, 1);
        _freeXMLNode = flag;
    }
    return self;
}

+ (__kindof SSXMLNode *)nodeWithConsumingXMLNode:(xmlNodePtr)node {
    Class theClass = (node->type == XML_ELEMENT_NODE) ? [SSXMLElement class] : [SSXMLNode class];
    return [[[theClass alloc] initWithXMLNode:node freeWhenDone:YES] autorelease];
}

+ (__kindof SSXMLNode *)nodeWithBorrowingXMLNode:(xmlNodePtr)node {
    Class theClass = (node->type == XML_ELEMENT_NODE) ? [SSXMLElement class] : [SSXMLNode class];
    return [[[theClass alloc] initWithXMLNode:node freeWhenDone:NO] autorelease];
}

- (void)releaseCachedValues {
    
    [_name release];
    _name = nil;
    
    [_children release];
    _children = nil;
}

// convert xmlChar* to NSString*
//
// returns an autoreleased NSString*, from the current node's document strings
// cache if possible
- (NSString *)stringFromXMLString:(const xmlChar *)chars {
#if DEBUG
    NSCAssert(chars != NULL, @"SSXMLNode sees an unexpected empty string");
#endif
    if (chars == NULL) {
         return nil;
    }
    
    NSString *result = nil;
    CFMutableDictionaryRef cacheDict = NULL;
    xmlNodePtr node = (__bridge xmlNodePtr)_reserved;
    if (node) {
        xmlElementType type = node->type;
        switch (type) {
            case XML_ELEMENT_NODE:
            case XML_ATTRIBUTE_NODE:
            case XML_TEXT_NODE: {
                xmlDoc *doc = node->doc;
                if (doc) {
                    cacheDict = doc->_private;
                    if (cacheDict) {
                        result = (__bridge NSString *)CFDictionaryGetValue(cacheDict, chars);
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    
    if (!result) {
        NSString *string = [[NSString stringWithUTF8String:(const char *)chars] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        result = [[[NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:NULL] stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (cacheDict) {
            CFDictionarySetValue(cacheDict, chars, result);
        }
    }
    return result;
}

- (xmlNodePtr)XMLNodeCopy {
    return _reserved ? xmlCopyNode((__bridge xmlNodePtr)_reserved, 1) : NULL;
}

- (xmlNodePtr)XMLNode {
    return (__bridge xmlNodePtr)_reserved;
}

- (BOOL)freeXMLNode {
    return _freeXMLNode;
}

@end
