//
//  SSXMLDocument+SSPrivate.h
//  SSFoundation
//
//  Created by Dante Sabatier on 06/05/17.
//
//

#import "SSXMLDocument.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/xmlstring.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

@interface SSXMLDocument (SSPrivate)

- (instancetype)initWithXMLDocument:(xmlDoc *)document;
@property (readonly) xmlDoc *xmlDocument;

@end
