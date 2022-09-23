//
//  SSXMLNode.m
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//  Copyright © 2017 Dante Sabatier. All rights _reserved.
//

#import "SSXMLNode.h"
#import "SSXMLNode+SSPrivate.h"
#import "SSXMLElement.h"
#import "SSXMLDocument.h"
#import "SSXMLUtilities.h"
#import "NSArray+SSAdditions.h"
#import "NSString+SSAdditions.h"

@implementation SSXMLNode

+ (void)load {
    xmlInitParser();
}

// Note on convenience methods for making stand-alone element and
// attribute nodes:
//
// Since we're making a node from scratch, we don't
// have any namespace info.  So the namespace prefix, if
// any, will just be slammed into the node name.
// We'll rely on the -addChild method below to remove
// the namespace prefix and replace it with a proper ns
// pointer.

+ (SSXMLElement *)elementWithName:(NSString *)name {
    xmlNodePtr theNewNode = xmlNewNode(NULL, (xmlChar *)name.UTF8String);
    return theNewNode ? [self.class nodeWithConsumingXMLNode:theNewNode] : nil;
}

+ (SSXMLElement *)elementWithName:(NSString *)name stringValue:(NSString *)value {
    xmlNodePtr theNewNode = xmlNewNode(NULL, (xmlChar *)name.UTF8String);
    if (theNewNode) {
        xmlNodePtr textNode = xmlNewText((xmlChar *)value.UTF8String);
        if (textNode) {
            xmlNodePtr temp = xmlAddChild(theNewNode, textNode);
            if (temp) {
                return [self.class nodeWithConsumingXMLNode:theNewNode];
            }
        }
        xmlFreeNode(theNewNode);
    }
    return nil;
}

+ (SSXMLElement *)elementWithName:(NSString *)name URI:(NSString *)theURI {
    NSString *fakeQName = SSFakeQNameForURIAndName(theURI, name);
    xmlNodePtr theNewNode = xmlNewNode(NULL, (xmlChar *)fakeQName.UTF8String);
    return theNewNode ? [self.class nodeWithConsumingXMLNode:(xmlNodePtr)theNewNode] : nil;
}

+ (id)attributeWithName:(NSString *)name stringValue:(NSString *)value {
    xmlChar *xmlName = (xmlChar *)name.UTF8String;
    xmlChar *xmlValue = (xmlChar *)value.UTF8String;
    xmlAttrPtr theNewAttr = xmlNewProp(NULL, xmlName, xmlValue);
    return theNewAttr ? [self.class nodeWithConsumingXMLNode:(xmlNodePtr)theNewAttr] : nil;
}

+ (id)attributeWithName:(NSString *)name URI:(NSString *)attributeURI stringValue:(NSString *)value {
    NSString *fakeQName = SSFakeQNameForURIAndName(attributeURI, name);
    xmlChar *xmlName = (xmlChar *)fakeQName.UTF8String;
    xmlChar *xmlValue = (xmlChar *)name.UTF8String;
    xmlAttrPtr theNewAttr = xmlNewProp(NULL, xmlName, xmlValue);
    return theNewAttr ? [self.class nodeWithConsumingXMLNode:(xmlNodePtr)theNewAttr] : nil;
}

+ (id)textWithStringValue:(NSString *)value {
    xmlNodePtr theNewText = xmlNewText((xmlChar *)value.UTF8String);
    if (theNewText) {
        return [self.class nodeWithConsumingXMLNode:theNewText];
    }
    return nil;
}

+ (id)namespaceWithName:(NSString *)name stringValue:(NSString *)value {
    xmlChar *href = (xmlChar *)value.UTF8String;
    xmlChar *prefix;
    if ([name length] > 0) {
        prefix = (xmlChar *)name.UTF8String;
    } else {
        prefix = nil;
    }
    
    xmlNsPtr theNewNs = xmlNewNs(NULL, href, prefix);
    if (theNewNs) {
       return [self.class nodeWithConsumingXMLNode:(xmlNodePtr)theNewNs];
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    xmlNodePtr nodeCopy = self.XMLNodeCopy;
    if (nodeCopy) {
        return [[self.class alloc] initWithXMLNode:nodeCopy freeWhenDone:YES];
    }
    return nil;
}

- (void)dealloc {
    if (((xmlNodePtr)_reserved) && _freeXMLNode) {
        xmlFreeNode(((xmlNodePtr)_reserved));
        _reserved = nil;
    }
    
    [self releaseCachedValues];
    [super ss_dealloc];
}


- (nullable NSArray <__kindof SSXMLNode *>*)nodesForXPath:(NSString *)xpath namespaces:(nullable NSDictionary <NSString *, id>*)namespaces error:(NSError *__nullable * __nullable)error {
    NSMutableArray *array = nil;
    NSInteger errorCode = -1;
    NSDictionary *errorInfo = nil;
    
    // xmlXPathNewContext requires a doc for its context, but if our elements
    // are created from GDataXMLElement's initWithXMLString there may not be
    // a document. (We may later decide that we want to stuff the doc used
    // there into a GDataXMLDocument and retain it, but we don't do that now.)
    //
    // We'll temporarily make a document to use for the xpath context.
    
    xmlDocPtr tempDoc = NULL;
    xmlNodePtr topParent = NULL;
    xmlNodePtr node = self.XMLNode;
    if (!node) {
        tempDoc = xmlNewDoc(NULL);
        if (tempDoc) {
            // find the topmost node of the current tree to make the root of
            // our temporary document
            topParent = node;
            while (topParent->parent != NULL) {
                topParent = topParent->parent;
            }
            xmlDocSetRootElement(tempDoc, topParent);
        }
    }
    
    if (node && node->doc != NULL) {
        
        xmlXPathContextPtr xpathCtx = xmlXPathNewContext(node->doc);
        if (xpathCtx) {
            // anchor at our current node
            xpathCtx->node = node;
            
            // if a namespace dictionary was provided, register its contents
            if (namespaces) {
                // the dictionary keys are prefixes; the values are URIs
                for (NSString *prefix in namespaces) {
                    NSString *uri = [namespaces objectForKey:prefix];
                    
                    xmlChar *prefixChars = (xmlChar *) [prefix UTF8String];
                    xmlChar *uriChars = (xmlChar *) [uri UTF8String];
                    int result = xmlXPathRegisterNs(xpathCtx, prefixChars, uriChars);
                    if (result != 0) {
#if DEBUG
                        NSCAssert1(result == 0, @"GDataXMLNode XPath namespace %@ issue", prefix);
#endif
                    }
                }
            } else {
                // no namespace dictionary was provided
                //
                // register the namespaces of this node, if it's an element, or of
                // this node's root element, if it's a document
                xmlNodePtr nsNodePtr = node;
                if (node->type == XML_DOCUMENT_NODE) {
                    nsNodePtr = xmlDocGetRootElement((xmlDocPtr) node);
                }
                
                // step through the namespaces, if any, and register each with the
                // xpath context
                if (nsNodePtr != NULL) {
                    for (xmlNsPtr nsPtr = nsNodePtr->ns; nsPtr != NULL; nsPtr = nsPtr->next) {
                        
                        // default namespace is nil in the tree, but there's no way to
                        // register a default namespace, so we'll register a fake one,
                        // _def_ns
                        const xmlChar* prefix = nsPtr->prefix;
                        if (prefix == NULL) {
                            prefix = (xmlChar*) kSSXMLXPathDefaultNamespacePrefix;
                        }
                        
                        int result = xmlXPathRegisterNs(xpathCtx, prefix, nsPtr->href);
                        if (result != 0) {
#if DEBUG
                            NSCAssert1(result == 0, @"SSXMLNode XPath namespace %s issue", prefix);
#endif
                        }
                    }
                }
            }
            
            // now evaluate the path
            xmlXPathObjectPtr xpathObj;
            xpathObj = xmlXPathEval((xmlChar *)xpath.UTF8String, xpathCtx);
            if (xpathObj) {
                
                // we have some result from the search
                array = [NSMutableArray array];
                
                xmlNodeSetPtr nodeSet = xpathObj->nodesetval;
                if (nodeSet) {
                    // add each node in the result set to our array
                    for (int index = 0; index < nodeSet->nodeNr; index++) {
                        xmlNodePtr currNode = nodeSet->nodeTab[index];
                        SSXMLNode *node = [SSXMLNode nodeWithBorrowingXMLNode:currNode];
                        if (node) {
                            [array addObject:node];
                        }
                    }
                }
                xmlXPathFreeObject(xpathObj);
            } else {
                // provide an error for failed evaluation
                const char *msg = xpathCtx->lastError.str1;
                errorCode = xpathCtx->lastError.code;
                if (msg) {
                    errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:msg] forKey:@"error"];
                }
            }
            
            xmlXPathFreeContext(xpathCtx);
        }
    } else {
        // not a valid node for using XPath
        errorInfo = [NSDictionary dictionaryWithObject:@"invalid node" forKey:@"error"];
    }
    
    if (array == nil && error != nil) {
        *error = [NSError errorWithDomain:@"SSFoundation" code:errorCode userInfo:errorInfo];
    }
    
    if (tempDoc != NULL) {
        xmlUnlinkNode(topParent);
        xmlSetTreeDoc(topParent, NULL);
        xmlFreeDoc(tempDoc);
    }
    return array;
}

- (nullable NSArray <__kindof SSXMLNode *>*)nodesForXPath:(NSString *)xpath error:(NSError *__nullable * __nullable)error {
    return [self nodesForXPath:xpath namespaces:nil error:error];
}

+ (NSString *)localNameForName:(NSString *)name {
    if (name) {
        NSRange range = [name rangeOfString:@":"];
        if (range.location != NSNotFound) {
            if (range.location + 1 < [name length]) {
                return [name substringFromIndex:(range.location + 1)];
            }
        }
    }
    return name;
}

+ (NSString *)prefixForName:(NSString *)name {
    if (name) {
        NSRange range = [name rangeOfString:@":"];
        if (range.location != NSNotFound) {
            return [name substringToIndex:(range.location)];
        }
    }
    return nil;
}

#pragma mark getters & setters

- (void)setStringValue:(NSString *)str {
    xmlNodePtr node = self.XMLNode;
    if (node != NULL && str != nil) {
        if (node->type == XML_NAMESPACE_DECL) {
            xmlNsPtr nsNode = (xmlNsPtr)node;
            if (nsNode->href != NULL) {
                xmlFree((char *)nsNode->href);
            }
            nsNode->href = xmlStrdup((xmlChar *)str.UTF8String);
        } else {
            xmlNodeSetContent(node, (xmlChar *)str.UTF8String);
        }
    }
}

- (NSString *)stringValue {
    NSString *str = nil;
    xmlNodePtr node = self.XMLNode;
    if (node) {
        xmlElementType type = node->type;
        switch (type) {
            case XML_NAMESPACE_DECL: {
                str = [self stringFromXMLString:(((xmlNsPtr)node)->href)];
            }
                break;
            default: {
                xmlChar *chars = xmlNodeGetContent(node);
                if (chars) {
                    str = [self stringFromXMLString:chars];
                    xmlFree(chars);
                }
            }
                break;
        }
    }
    return str;
}

- (NSString *)XMLStringWithOptions:(SSXMLNodeOptions)options {
    xmlNodePtr node = self.XMLNode;
    if (node) {
        xmlBufferPtr buff = xmlBufferCreate();
        if (buff) {
            xmlDocPtr doc = (node->type == XML_NAMESPACE_DECL) ? node->doc : NULL;
            int level = 0;
            int format = 0;
            if (options & SSXMLNodeCompactEmptyElement) {
                xmlSaveNoEmptyTags = 0;
            } else {
                xmlSaveNoEmptyTags = 1;
            }
            
            if (options & SSXMLNodePrettyPrint) {
                format = 1;
                xmlIndentTreeOutput = 1;
            }
            
            NSString *result = nil;
            int dump = xmlNodeDump(buff, doc, node, level, format);
            if (dump >= 0) {
                NSString *xmlString = [[[NSString alloc] initWithBytes:(xmlBufferContent(buff)) length:(NSUInteger)(xmlBufferLength(buff)) encoding:NSUTF8StringEncoding] autorelease];
                if (xmlString) {
                    NSString *string = [xmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    result = [[[NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:NULL] stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
            }
            
            xmlBufferFree(buff);
            
            if (result) {
                return result;
            }
        }
    }
    return @"";
}

- (NSString *)XMLString {
    return [self XMLStringWithOptions:0];
}

- (NSString *)localName {
    xmlNodePtr node = self.XMLNode;
    if (node) {
        const xmlChar *name = node->name;
        if (name) {
            return [[self class] localNameForName:[self stringFromXMLString:name]];
        }
    }
    return nil;
}

- (NSString *)prefix {
    xmlNodePtr node = self.XMLNode;
    if (node) {
        xmlNs *ns = node->ns;
        if (ns) {
            const xmlChar *prefix = ns->prefix;
            if (prefix) {
                return [self stringFromXMLString:prefix];
            }
        }
    }
    return nil;
}

- (NSString *)URI {
    xmlNodePtr node = self.XMLNode;
    if (node) {
        xmlNs *ns = node->ns;
        if (ns) {
            const xmlChar *href = ns->href;
            if (href) {
                return [self stringFromXMLString:href];
            }
        }
    }
    return nil;
}

- (NSString *)name {
    if (!_name) {
        xmlNodePtr node = self.XMLNode;
        if (node) {
            const xmlChar *name = node->name;
            if (name) {
                xmlElementType type = node->type;
                switch (type) {
                    case XML_NAMESPACE_DECL: {
                        xmlNsPtr nsNode = (xmlNsPtr)node;
                        const xmlChar *prefix = nsNode->prefix;
                        if (prefix) {
                            _name = [[self stringFromXMLString:prefix] copy];
                        } else {
                            _name = [[NSString alloc] init];
                        }
                    }
                        break;
                    case XML_ELEMENT_NODE:
                    case XML_PI_NODE:
                    case XML_COMMENT_NODE:
                    case XML_TEXT_NODE:
                    case XML_CDATA_SECTION_NODE: {
                        xmlNs *ns = node->ns;
                        if (ns) {
                            const xmlChar *prefix = ns->prefix;
                            if (prefix) {
                                char *qname;
                                if (asprintf(&qname, "%s:%s", (const char *)prefix, name) != -1) {
                                    _name = [[self stringFromXMLString:(const xmlChar *)qname] copy];
                                    free(qname);
                                }
                            } else {
                                _name = [[self stringFromXMLString:name] copy];
                            }
                        } else {
                            _name = [[self stringFromXMLString:name] copy];
                        }
                    }
                        break;
                    default:
                        _name = [[self stringFromXMLString:name] copy];
                        break;
                }
            }
        }
    }
    return _name;
}

- (NSUInteger)childCount {
    __block NSUInteger childCount = 0;
    if (_children != nil) {
        childCount = _children.count;
    }
    
    if (!childCount) {
        xmlNodePtr node = self.XMLNode;
        if (node) {
            unsigned int count = 0;
            xmlNodePtr child = node->children;
            while (child != NULL) {
                ++count;
                child = child->next;
            }
            childCount = count;
        }
    }
    return childCount;
}

- (NSArray *)children {
    if (!_children) {
        xmlNodePtr node = self.XMLNode;
        if (node) {
            xmlNodePtr child = node->children;
            NSMutableArray *array = [NSMutableArray array];
            while (child != NULL) {
                [array addObject:[SSXMLNode nodeWithBorrowingXMLNode:child]];
                child = child->next;
            }
            _children = [array copy];
        }
    }
    return _children;
}

- (SSXMLNode *)childAtIndex:(unsigned)index {
    return [self.children safeObjectAtIndex:index];
}

- (SSXMLNodeKind)kind {
    __block SSXMLNodeKind kind = SSXMLInvalidKind;
    xmlNodePtr node = self.XMLNode;
    if (node) {
        xmlElementType nodeType = node->type;
        switch (nodeType) {
            case XML_ELEMENT_NODE:
                kind = SSXMLElementKind;
                break;
            case XML_ATTRIBUTE_NODE:
                kind = SSXMLAttributeKind;
                break;
            case XML_TEXT_NODE:
                kind = SSXMLTextKind;
                break;
            case XML_CDATA_SECTION_NODE:
                kind = SSXMLTextKind;
                break;
            case XML_ENTITY_REF_NODE:
                kind = SSXMLEntityDeclarationKind;
                break;
            case XML_ENTITY_NODE:
                kind = SSXMLEntityDeclarationKind;
                break;
            case XML_PI_NODE:
                kind = SSXMLProcessingInstructionKind;
                break;
            case XML_COMMENT_NODE:
                kind = SSXMLCommentKind;
                break;
            case XML_DOCUMENT_NODE:
                kind = SSXMLDocumentKind;
                break;
            case XML_DOCUMENT_TYPE_NODE:
                kind = SSXMLDocumentKind;
                break;
            case XML_DOCUMENT_FRAG_NODE:
                kind = SSXMLDocumentKind;
                break;
            case XML_NOTATION_NODE:
                kind = SSXMLNotationDeclarationKind;
                break;
            case XML_HTML_DOCUMENT_NODE:
                kind = SSXMLDocumentKind;
                break;
            case XML_DTD_NODE:
                kind = SSXMLDTDKind;
                break;
            case XML_ELEMENT_DECL:
                kind = SSXMLElementDeclarationKind;
                break;
            case XML_ATTRIBUTE_DECL:
                kind = SSXMLAttributeDeclarationKind;
                break;
            case XML_ENTITY_DECL:
                kind = SSXMLEntityDeclarationKind;
                break;
            case XML_NAMESPACE_DECL:
                kind = SSXMLNamespaceKind;
                break;
            case XML_XINCLUDE_START:
                kind = SSXMLProcessingInstructionKind;
                break;
            case XML_XINCLUDE_END:
                kind = SSXMLProcessingInstructionKind;
                break;
            case XML_DOCB_DOCUMENT_NODE:
                kind = SSXMLDocumentKind;
                break;
        }
    }
    return kind;
}

- (NSUInteger)hash {
    return (NSUInteger)(void *)[SSXMLNode class];
}

- (NSString *)description {
    xmlNodePtr node = self.XMLNode;
    int nodeType = (node ? (int)node->type : -1);
    return [NSString stringWithFormat:@"%@ %p: {type:%d name:%@ xml:\"%@\"}", self.class, self, nodeType, self.name, self.XMLString];
}

- (BOOL)isEqual:(SSXMLNode *)other {
    if (self == other) {
        return YES;
    }
    
    if (![other isKindOfClass:[SSXMLNode class]]) {
        return NO;
    }
    return (self.XMLNode == other.XMLNode) || ((self.kind == other.kind) && AreEqualOrBothNilPrivate(self.name, other.name) && (self.children.count == other.children.count));
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [super methodSignatureForSelector:selector];
}

@end
