//
//  SSXMLDocument.m
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import "SSXMLDocument.h"
#import "SSXMLUtilities.h"
#import "SSXMLDocument+SSPrivate.h"
#import "SSXMLNode+SSPrivate.h"

@implementation SSXMLDocument

- (nullable instancetype)initWithXMLString:(NSString *)string options:(SSXMLNodeOptions)mask error:(NSError *__nullable * __nullable)error {
    return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:mask error:error];
}

- (nullable instancetype)initWithContentsOfURL:(NSURL *)url options:(SSXMLNodeOptions)mask error:(NSError *__nullable * __nullable)error {
    return [self initWithData:[NSData dataWithContentsOfURL:url] options:mask error:error];
}

- (nullable instancetype)initWithData:(NSData *)data options:(SSXMLNodeOptions)mask error:(NSError *__nullable * __nullable)error {
    const char *baseURL = NULL;
    const char *encoding = NULL;
    
    xmlDocPtr document = NULL;
    if (!(document = xmlReadMemory((const char*)data.bytes, (int)data.length, baseURL, encoding, XML_PARSE_NOWARNING|XML_PARSE_NOERROR|XML_PARSE_NOCDATA|XML_PARSE_NOBLANKS))) {
        document = htmlReadMemory((const char*)data.bytes, (int)data.length, baseURL, encoding, HTML_PARSE_NOWARNING|HTML_PARSE_NOERROR);
    }
    
    if (!document) {
        if (error) {
            *error = [NSError errorWithDomain:@"SSFoundation" code:-1 userInfo:nil];
        }
        return nil;
    }
    
    return [self initWithXMLDocument:document];
}

- (instancetype)initWithRootElement:(nullable SSXMLElement *)element {
    xmlDoc *document = xmlNewDoc(NULL);
    (void)xmlDocSetRootElement(document, element.XMLNodeCopy);
    return [self initWithXMLDocument:document];
}

- (void)dealloc {
    xmlDoc *doc = self.xmlDocument;
    if (doc) {
        if (doc->_private) {
            CFRelease(doc->_private);
        }
        
        xmlFreeDoc(doc);
    }
    [super ss_dealloc];
}

- (nullable NSArray <__kindof SSXMLNode *> *)nodesForXPath:(NSString *)xpath namespaces:(NSDictionary<NSString *,id> *)namespaces error:(NSError * _Nullable *)error {
    xmlDoc *doc = self.xmlDocument;
    return doc ? [[SSXMLElement nodeWithBorrowingXMLNode:(xmlNodePtr)doc] nodesForXPath:xpath namespaces:namespaces error:error] : NULL;
}

#pragma mark getters & setters

- (SSXMLElement *)rootElement {
    xmlDoc *doc = self.xmlDocument;
    if (doc) {
        xmlNodePtr rootNode = xmlDocGetRootElement(doc);
        if (rootNode) {
            return [SSXMLElement nodeWithBorrowingXMLNode:rootNode];
        }
    }
    return nil;
}

- (void)setVersion:(NSString *)version {
    xmlDoc *doc = self.xmlDocument;
    if (doc) {
        if (doc->version) {
            xmlFree((char *) doc->version);
            doc->version = NULL;
        }
        
        if (version) {
            doc->version = xmlStrdup((xmlChar *)version.UTF8String);
        }
    }
}

- (void)setCharacterEncoding:(NSString *)encoding {
    xmlDoc *doc = self.xmlDocument;
    if (doc) {
        if (doc->encoding) {
            xmlFree((char *) doc->encoding);
            doc->encoding = NULL;
        }
        
        if (encoding) {
            doc->encoding = xmlStrdup((xmlChar *)encoding.UTF8String);
        }
    }
}

- (NSData *)XMLDataWithOptions:(SSXMLNodeOptions)options {
    return [[self XMLStringWithOptions:options] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)XMLData {
    return [self.XMLString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %p", [self class], self];
}

@end
