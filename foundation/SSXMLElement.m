//
//  SSXMLElement.m
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import "SSXMLElement.h"
#import "SSXMLUtilities.h"
#import "SSXMLNode+SSPrivate.h"
#import "NSArray+SSAdditions.h"

@implementation SSXMLElement

- (nullable instancetype)initWithXMLString:(NSString *)string error:(NSError **)error {
    const char *utf8Str = string.UTF8String;
    xmlDocPtr document = NULL;
    if (!(document = xmlReadMemory(utf8Str, (int)strlen(utf8Str), NULL, NULL, XML_PARSE_NOWARNING|XML_PARSE_NOERROR|XML_PARSE_NOCDATA|XML_PARSE_NOBLANKS))) {
        document = htmlReadMemory(utf8Str, (int)strlen(utf8Str), NULL, NULL, HTML_PARSE_NOWARNING|HTML_PARSE_NOERROR|HTML_PARSE_NOBLANKS);
    }
    
    if (!document) {
        if (error) {
            *error = [NSError errorWithDomain:@"SSFoundation" code:-1 userInfo:nil];
        }
        return nil;
    }
    
    xmlNodePtr root = xmlDocGetRootElement(document);
    if (!root) {
        if (error) {
            *error = [NSError errorWithDomain:@"SSFoundation" code:-1 userInfo:nil];
        }
        xmlFreeDoc(document);
        return nil;
    }
    
    self = [super init];
    if (self) {
        _reserved = (__bridge id)xmlCopyNode(root, 1);
        _freeXMLNode = YES;
        xmlFreeDoc(document);
    }
    return self;
}

- (void)releaseCachedValues {
    [super releaseCachedValues];
    
    [_attributes release];
    _attributes = nil;
}

- (NSArray *)namespaces {
    
    NSMutableArray *array = nil;
    
    if (_reserved != NULL && ((xmlNodePtr)_reserved)->nsDef != NULL) {
        
        xmlNsPtr currNS = ((xmlNodePtr)_reserved)->nsDef;
        while (currNS != NULL) {
            
            // add this prefix/URI to the list, unless it's the implicit xml prefix
            if (!xmlStrEqual(currNS->prefix, (const xmlChar *) "xml")) {
                SSXMLNode *node = [SSXMLNode nodeWithConsumingXMLNode:(xmlNodePtr)currNS];
                if (array == nil) {
                    array = [NSMutableArray arrayWithObject:node];
                } else {
                    [array addObject:node];
                }
            }
            
            currNS = currNS->next;
        }
    }
    return array;
}

- (void)setNamespaces:(NSArray *)namespaces {
    
    if (_reserved != NULL) {
        
        [self releaseCachedValues];
        
        // remove previous namespaces
        if (((xmlNodePtr)_reserved)->nsDef) {
            xmlFreeNsList(((xmlNodePtr)_reserved)->nsDef);
            ((xmlNodePtr)_reserved)->nsDef = NULL;
        }
        
        // add a namespace for each object in the array
        NSEnumerator *enumerator = [namespaces objectEnumerator];
        SSXMLNode *namespaceNode;
        while ((namespaceNode = [enumerator nextObject]) != nil) {
            
            xmlNsPtr ns = (xmlNsPtr) [namespaceNode XMLNode];
            if (ns) {
                (void)xmlNewNs(((xmlNodePtr)_reserved), ns->href, ns->prefix);
            }
        }
        
        // we may need to fix this node's own name; the graft point is where
        // the namespace search starts, so that points to this node too
        [[self class] fixUpNamespacesForNode:((xmlNodePtr)_reserved) graftingToTreeNode:((xmlNodePtr)_reserved)];
    }
}

- (void)addNamespace:(SSXMLNode *)aNamespace {
    
    if (_reserved != NULL) {
        
        [self releaseCachedValues];
        
        xmlNsPtr ns = (xmlNsPtr) [aNamespace XMLNode];
        if (ns) {
            (void)xmlNewNs(((xmlNodePtr)_reserved), ns->href, ns->prefix);
            
            // we may need to fix this node's own name; the graft point is where
            // the namespace search starts, so that points to this node too
            [[self class] fixUpNamespacesForNode:((xmlNodePtr)_reserved) graftingToTreeNode:((xmlNodePtr)_reserved)];
        }
    }
}

- (void)addChild:(SSXMLNode *)child {
    if ([child kind] == SSXMLAttributeKind) {
        [self addAttribute:child];
        return;
    }
    
    if (_reserved != NULL) {
        
        [self releaseCachedValues];
        
        xmlNodePtr childNodeCopy = [child XMLNodeCopy];
        if (childNodeCopy) {
            
            xmlNodePtr resultNode = xmlAddChild(((xmlNodePtr)_reserved), childNodeCopy);
            if (resultNode == NULL) {
                
                // failed to add
                xmlFreeNode(childNodeCopy);
                
            } else {
                // added this child subtree successfully; see if it has
                // previously-unresolved namespace prefixes that can now be fixed up
                [[self class] fixUpNamespacesForNode:childNodeCopy graftingToTreeNode:((xmlNodePtr)_reserved)];
            }
        }
    }
}

- (void)removeChild:(SSXMLNode *)child {
    // this is safe for attributes too
    if (_reserved != NULL) {
        
        [self releaseCachedValues];
        
        xmlNodePtr node = child.XMLNode;
        xmlUnlinkNode(node);
        
        // if the child node was borrowing its xmlNodePtr, then we need to
        // explicitly free it, since there is probably no owning object that will
        // free it on dealloc
        if (!child.freeXMLNode) {
            xmlFreeNode(node);
        }
    }
}

- (NSArray *)elementsForName:(NSString *)name {
    
    NSString *desiredName = name;
    
    if (_reserved != NULL) {
        
        NSString *prefix = [[self class] prefixForName:desiredName];
        if (prefix) {
            
            xmlChar* desiredPrefix = (xmlChar *)prefix.UTF8String;
            xmlNsPtr foundNS = xmlSearchNs(((xmlNodePtr)_reserved)->doc, ((xmlNodePtr)_reserved), desiredPrefix);
            if (foundNS) {
                
                // we found a namespace; fall back on elementsForLocalName:URI:
                // to get the elements
                NSString *desiredURI = [self stringFromXMLString:(foundNS->href)];
                NSString *localName = [[self class] localNameForName:desiredName];
                
                NSArray *nsArray = [self elementsForLocalName:localName URI:desiredURI];
                return nsArray;
            }
        }
        
        // no namespace found for the node's prefix; try an exact match
        // for the name argument, including any prefix
        NSMutableArray *array = nil;
        
        // walk our list of cached child nodes
        NSArray *children = [self children];
        
        for (SSXMLNode *child in children) {
            
            xmlNodePtr currNode = [child XMLNode];
            
            // find all children which are elements with the desired name
            if (currNode->type == XML_ELEMENT_NODE) {
                
                NSString *qName = [child name];
                if ([qName isEqual:name]) {
                    
                    if (array == nil) {
                        array = [NSMutableArray arrayWithObject:child];
                    } else {
                        [array addObject:child];
                    }
                }
            }
        }
        return array;
    }
    return nil;
}

- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI {
    
    NSMutableArray *array = nil;
    
    if (_reserved != NULL && ((xmlNodePtr)_reserved)->children != NULL) {
        
        xmlChar* desiredNSHref = (xmlChar *)URI.UTF8String;
        xmlChar* requestedLocalName = (xmlChar *)localName.UTF8String;
        xmlChar* expectedLocalName = requestedLocalName;
        
        // resolve the URI at the parent level, since usually children won't
        // have their own namespace definitions, and we don't want to try to
        // resolve it once for every child
        xmlNsPtr foundParentNS = xmlSearchNsByHref(((xmlNodePtr)_reserved)->doc, ((xmlNodePtr)_reserved), desiredNSHref);
        if (foundParentNS == NULL) {
            NSString *fakeQName = SSFakeQNameForURIAndName(URI, localName);
            expectedLocalName =  (xmlChar *)fakeQName.UTF8String;
        }
        
        NSArray *children = [self children];
        
        for (SSXMLNode *child in children) {
            
            xmlNodePtr currChildPtr = [child XMLNode];
            
            // find all children which are elements with the desired name and
            // namespace, or with the prefixed name and a null namespace
            if (currChildPtr->type == XML_ELEMENT_NODE) {
                
                // normally, we can assume the resolution done for the parent will apply
                // to the child, as most children do not define their own namespaces
                xmlNsPtr childLocalNS = foundParentNS;
                xmlChar* childDesiredLocalName = expectedLocalName;
                
                if (currChildPtr->nsDef != NULL) {
                    // this child has its own namespace definitons; do a fresh resolve
                    // of the namespace starting from the child, and see if it differs
                    // from the resolve done starting from the parent.  If the resolve
                    // finds a different namespace, then override the desired local
                    // name just for this child.
                    childLocalNS = xmlSearchNsByHref(((xmlNodePtr)_reserved)->doc, currChildPtr, desiredNSHref);
                    if (childLocalNS != foundParentNS) {
                        
                        // this child does indeed have a different namespace resolution
                        // result than was found for its parent
                        if (childLocalNS == NULL) {
                            // no namespace found
                            NSString *fakeQName = SSFakeQNameForURIAndName(URI, localName);
                            childDesiredLocalName = (xmlChar *)fakeQName.UTF8String;
                        } else {
                            // a namespace was found; use the original local name requested,
                            // not a faked one expected from resolving the parent
                            childDesiredLocalName = requestedLocalName;
                        }
                    }
                }
                
                // check if this child's namespace and local name are what we're
                // seeking
                if (currChildPtr->ns == childLocalNS
                    && currChildPtr->name != NULL
                    && xmlStrEqual(currChildPtr->name, childDesiredLocalName)) {
                    
                    if (array == nil) {
                        array = [NSMutableArray arrayWithObject:child];
                    } else {
                        [array addObject:child];
                    }
                }
            }
        }
        // we return nil, not an empty array, according to docs
    }
    return array;
}

- (void)addAttribute:(SSXMLNode *)attribute {
    
    if (_reserved != NULL) {
        
        [self releaseCachedValues];
        
        xmlAttrPtr attrPtr = (xmlAttrPtr) [attribute XMLNode];
        if (attrPtr) {
            
            // ignore this if an attribute with the name is already present,
            // similar to NSXMLNode's addAttribute
            xmlAttrPtr oldAttr;
            
            if (attrPtr->ns == NULL) {
                oldAttr = xmlHasProp(((xmlNodePtr)_reserved), attrPtr->name);
            } else {
                oldAttr = xmlHasNsProp(((xmlNodePtr)_reserved), attrPtr->name, attrPtr->ns->href);
            }
            
            if (oldAttr == NULL) {
                
                xmlNsPtr newPropNS = NULL;
                
                // if this attribute has a namespace, search for a matching namespace
                // on the node we're adding to
                if (attrPtr->ns != NULL) {
                    
                    newPropNS = xmlSearchNsByHref(((xmlNodePtr)_reserved)->doc, ((xmlNodePtr)_reserved), attrPtr->ns->href);
                    if (newPropNS == NULL) {
                        // make a new namespace on the parent node, and use that for the
                        // new attribute
                        newPropNS = xmlNewNs(((xmlNodePtr)_reserved), attrPtr->ns->href, attrPtr->ns->prefix);
                    }
                }
                
                // copy the attribute onto this node
                xmlChar *value = xmlNodeGetContent((xmlNodePtr) attrPtr);
                xmlAttrPtr newProp = xmlNewNsProp(((xmlNodePtr)_reserved), newPropNS, attrPtr->name, value);
                if (newProp != NULL) {
                    // we made the property, so clean up the property's namespace
                    
                    [[self class] fixUpNamespacesForNode:(xmlNodePtr)newProp
                                      graftingToTreeNode:((xmlNodePtr)_reserved)];
                }
                
                if (value != NULL) {
                    xmlFree(value);
                }
            }
        }
    }
}

- (NSArray <__kindof SSXMLNode *> *)attributes {
    if (_attributes != nil) {
        return _attributes;
    }
    
    NSMutableArray *array = nil;
    xmlNodePtr node = self.XMLNode;
    if (node) {
        xmlAttrPtr prop = node->properties;
        if (prop) {
            while (prop != NULL) {
                SSXMLNode *node = [SSXMLNode nodeWithBorrowingXMLNode:(xmlNodePtr)prop];
                if (array == nil) {
                    array = [NSMutableArray arrayWithObject:node];
                } else {
                    [array addObject:node];
                }
                
                prop = prop->next;
            }
            
            _attributes = [array copy];
        }
        
    }
    return array;
}

- (nullable SSXMLNode *)attributeForXMLNode:(xmlAttrPtr)node {
    return [self.attributes firstObjectPassingTest:^BOOL(__kindof SSXMLNode * _Nonnull obj) {
        return ((xmlAttrPtr)obj.XMLNode == node);
    }];
}

- (nullable SSXMLNode *)attributeForName:(NSString *)name {
    xmlNodePtr node = self.XMLNode;
    if (node) {
        xmlAttrPtr attr = node->properties;
        if (attr) {
            xmlChar *attributeName = (xmlChar *)name.UTF8String;
            do {
                if (attr->ns && attr->ns->prefix) {
                    if (xmlStrQEqual(attr->ns->prefix, attr->name, attributeName)) {
                        return [SSXMLNode nodeWithBorrowingXMLNode:(xmlNodePtr)attr];
                    }
                } else {
                    if (xmlStrEqual(attr->name, attributeName)) {
                        return [SSXMLNode nodeWithBorrowingXMLNode:(xmlNodePtr)attr];
                    }
                }
                
                attr = attr->next;
            } while (attr);
        }
    }
    return nil;
}

- (nullable SSXMLNode *)attributeForLocalName:(NSString *)localName URI:(NSString *)attributeURI {
    xmlNodePtr node = self.XMLNode;
    if (node) {
        const xmlChar* name = (xmlChar *)localName.UTF8String;
        const xmlChar* nsURI = (xmlChar *)attributeURI.UTF8String;
        xmlAttrPtr attrPtr = xmlHasNsProp(node, name, nsURI);
        
        if (attrPtr == NULL) {
            NSString *fakeQName = SSFakeQNameForURIAndName(attributeURI, localName);
            const xmlChar* xmlFakeQName = (xmlChar *)fakeQName.UTF8String;
            attrPtr = xmlHasProp(node, xmlFakeQName);
        }
        
        if (attrPtr) {
            return [self attributeForXMLNode:attrPtr];
        }
    }
    return nil;
}

- (nullable NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI {
    
    if (((xmlNodePtr)_reserved) != NULL) {
        
        xmlChar* desiredNSHref = (xmlChar *)namespaceURI.UTF8String;
        
        xmlNsPtr foundNS = xmlSearchNsByHref(((xmlNodePtr)_reserved)->doc, ((xmlNodePtr)_reserved), desiredNSHref);
        if (foundNS) {
            
            // we found the namespace
            if (foundNS->prefix != NULL) {
                NSString *prefix = [self stringFromXMLString:(foundNS->prefix)];
                return prefix;
            } else {
                // empty prefix is default namespace
                return @"";
            }
        }
    }
    return nil;
}

#pragma mark Namespace fixup routines

+ (void)deleteNamespacePtr:(xmlNsPtr)namespaceToDelete
               fromXMLNode:(xmlNodePtr)node {
    
    // utilty routine to remove a namespace pointer from an element's
    // namespace definition list.  This is just removing the nsPtr
    // from the singly-linked list, the node's namespace definitions.
    xmlNsPtr currNS = node->nsDef;
    xmlNsPtr prevNS = NULL;
    
    while (currNS != NULL) {
        xmlNsPtr nextNS = currNS->next;
        
        if (namespaceToDelete == currNS) {
            
            // found it; delete it from the head of the node's ns definition list
            // or from the next field of the previous namespace
            
            if (prevNS != NULL) prevNS->next = nextNS;
            else node->nsDef = nextNS;
            
            xmlFreeNs(currNS);
            return;
        }
        prevNS = currNS;
        currNS = nextNS;
    }
}

+ (void)fixQualifiedNamesForNode:(xmlNodePtr)nodeToFix
              graftingToTreeNode:(xmlNodePtr)graftPointNode {
    
    // Replace prefix-in-name with proper namespace pointers
    //
    // This is an inner routine for fixUpNamespacesForNode:
    //
    // see if this node's name lacks a namespace and is qualified, and if so,
    // see if we can resolve the prefix against the parent
    //
    // The prefix may either be normal, "gd:foo", or a URI
    // "{http://blah.com/}:foo"
    
    if (nodeToFix->ns == NULL) {
        xmlNsPtr foundNS = NULL;
        
        xmlChar* prefix = NULL;
        xmlChar* localName = SplitQNameReverse(nodeToFix->name, &prefix);
        if (localName != NULL) {
            if (prefix != NULL) {
                
                // if the prefix is wrapped by { and } then it's a URI
                int prefixLen = xmlStrlen(prefix);
                if (prefixLen > 2
                    && prefix[0] == '{'
                    && prefix[prefixLen - 1] == '}') {
                    
                    // search for the namespace by URI
                    xmlChar* uri = xmlStrsub(prefix, 1, prefixLen - 2);
                    
                    if (uri != NULL) {
                        foundNS = xmlSearchNsByHref(graftPointNode->doc, graftPointNode, uri);
                        
                        xmlFree(uri);
                    }
                }
            }
            
            if (foundNS == NULL) {
                // search for the namespace by prefix, even if the prefix is nil
                // (nil prefix means to search for the default namespace)
                foundNS = xmlSearchNs(graftPointNode->doc, graftPointNode, prefix);
            }
            
            if (foundNS != NULL) {
                // we found a namespace, so fix the ns pointer and the local name
                xmlSetNs(nodeToFix, foundNS);
                xmlNodeSetName(nodeToFix, localName);
            }
            
            if (prefix != NULL) {
                xmlFree(prefix);
                prefix = NULL;
            }
            
            xmlFree(localName);
        }
    }
}

+ (void)fixDuplicateNamespacesForNode:(xmlNodePtr)nodeToFix
                   graftingToTreeNode:(xmlNodePtr)graftPointNode
             namespaceSubstitutionMap:(NSMutableDictionary *)nsMap {
    
    // Duplicate namespace removal
    //
    // This is an inner routine for fixUpNamespacesForNode:
    //
    // If any of this node's namespaces are already defined at the graft point
    // level, add that namespace to the map of namespace substitutions
    // so it will be replaced in the children below the nodeToFix, and
    // delete the namespace record
    
    if (nodeToFix->type == XML_ELEMENT_NODE) {
        
        // step through the namespaces defined on this node
        xmlNsPtr definedNS = nodeToFix->nsDef;
        while (definedNS != NULL) {
            
            // see if this namespace is already defined higher in the tree,
            // with both the same URI and the same prefix; if so, add a mapping for
            // it
            xmlNsPtr foundNS = xmlSearchNsByHref(graftPointNode->doc, graftPointNode,
                                                 definedNS->href);
            if (foundNS != NULL
                && foundNS != definedNS
                && xmlStrEqual(definedNS->prefix, foundNS->prefix)) {
                
                // store a mapping from this defined nsPtr to the one found higher
                // in the tree
                [nsMap setObject:[NSValue valueWithPointer:foundNS]
                          forKey:[NSValue valueWithPointer:definedNS]];
                
                // remove this namespace from the ns definition list of this node;
                // all child elements and attributes referencing this namespace
                // now have a dangling pointer and must be updated (that is done later
                // in this method)
                //
                // before we delete this namespace, move our pointer to the
                // next one
                xmlNsPtr nsToDelete = definedNS;
                definedNS = definedNS->next;
                
                [self deleteNamespacePtr:nsToDelete fromXMLNode:nodeToFix];
                
            } else {
                // this namespace wasn't a duplicate; move to the next
                definedNS = definedNS->next;
            }
        }
    }
    
    // if this node's namespace is one we deleted, update it to point
    // to someplace better
    if (nodeToFix->ns != NULL) {
        
        NSValue *currNS = [NSValue valueWithPointer:nodeToFix->ns];
        NSValue *replacementNS = [nsMap objectForKey:currNS];
        
        if (replacementNS != nil) {
            xmlNsPtr replaceNSPtr = (xmlNsPtr)[replacementNS pointerValue];
            
            xmlSetNs(nodeToFix, replaceNSPtr);
        }
    }
}



+ (void)fixUpNamespacesForNode:(xmlNodePtr)nodeToFix
            graftingToTreeNode:(xmlNodePtr)graftPointNode
      namespaceSubstitutionMap:(NSMutableDictionary *)nsMap {
    
    // This is the inner routine for fixUpNamespacesForNode:graftingToTreeNode:
    //
    // This routine fixes two issues:
    //
    // Because we can create nodes with qualified names before adding
    // them to the tree that declares the namespace for the prefix,
    // we need to set the node namespaces after adding them to the tree.
    //
    // Because libxml adds namespaces to nodes when it copies them,
    // we want to remove redundant namespaces after adding them to
    // a tree.
    //
    // If only the Mac's libxml had xmlDOMWrapReconcileNamespaces, it could do
    // namespace cleanup for us
    
    // We only care about fixing names of elements and attributes
    if (nodeToFix->type != XML_ELEMENT_NODE
        && nodeToFix->type != XML_ATTRIBUTE_NODE) return;
    
    // Do the fixes
    [self fixQualifiedNamesForNode:nodeToFix
                graftingToTreeNode:graftPointNode];
    
    [self fixDuplicateNamespacesForNode:nodeToFix
                     graftingToTreeNode:graftPointNode
               namespaceSubstitutionMap:nsMap];
    
    if (nodeToFix->type == XML_ELEMENT_NODE) {
        
        // when fixing element nodes, recurse for each child element and
        // for each attribute
        xmlNodePtr currChild = nodeToFix->children;
        while (currChild != NULL) {
            [self fixUpNamespacesForNode:currChild
                      graftingToTreeNode:graftPointNode
                namespaceSubstitutionMap:nsMap];
            currChild = currChild->next;
        }
        
        xmlAttrPtr currProp = nodeToFix->properties;
        while (currProp != NULL) {
            [self fixUpNamespacesForNode:(xmlNodePtr)currProp
                      graftingToTreeNode:graftPointNode
                namespaceSubstitutionMap:nsMap];
            currProp = currProp->next;
        }
    }
}

+ (void)fixUpNamespacesForNode:(xmlNodePtr)nodeToFix
            graftingToTreeNode:(xmlNodePtr)graftPointNode {
    
    // allocate the namespace map that will be passed
    // down on recursive calls
    NSMutableDictionary *nsMap = [NSMutableDictionary dictionary];
    
    [self fixUpNamespacesForNode:nodeToFix
              graftingToTreeNode:graftPointNode
        namespaceSubstitutionMap:nsMap];
}

@end
