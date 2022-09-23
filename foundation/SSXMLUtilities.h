//
//  SSXMLUtilities.h
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
#import <libxml/HTMLparser.h>

extern const char *kSSXMLXPathDefaultNamespacePrefix;
extern BOOL AreEqualOrBothNilPrivate(id obj1, id obj2);
extern NSString *SSFakeQNameForURIAndName(NSString *theURI, NSString *name);
extern xmlChar *SplitQNameReverse(const xmlChar *qname, xmlChar **prefix);
