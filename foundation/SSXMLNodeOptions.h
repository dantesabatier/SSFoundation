//
//  SSXMLNodeOptions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//
//

#import <Foundation/NSObjCRuntime.h>

typedef NS_OPTIONS(NSUInteger, SSXMLNodeOptions) {
    SSXMLNodeOptionsNone = 0,
    
    // Init
    SSXMLNodeIsCDATA = 1UL << 0,
    SSXMLNodeExpandEmptyElement = 1UL << 1, // <a></a>
    SSXMLNodeCompactEmptyElement =  1UL << 2, // <a/>
    SSXMLNodeUseSingleQuotes = 1UL << 3,
    SSXMLNodeUseDoubleQuotes = 1UL << 4,
    SSXMLNodeNeverEscapeContents = 1UL << 5,
    
    // Tidy
    SSXMLDocumentTidyHTML = 1UL << 9,
    SSXMLDocumentTidyXML = 1UL << 10,
    
    // Validate
    SSXMLDocumentValidate = 1UL << 13,
    
    // External Entity Loading
    // Choose only zero or one option. Choosing none results in system-default behavior.
    SSXMLNodeLoadExternalEntitiesAlways = 1UL << 14,
    SSXMLNodeLoadExternalEntitiesSameOriginOnly = 1UL << 15,
    SSXMLNodeLoadExternalEntitiesNever = 1UL << 19,
    
    // Parse
    SSXMLDocumentXInclude = 1UL << 16,
    
    // Output
    SSXMLNodePrettyPrint = 1UL << 17,
    SSXMLDocumentIncludeContentTypeDeclaration = 1UL << 18,
    
    // Fidelity
    SSXMLNodePreserveNamespaceOrder = 1UL << 20,
    SSXMLNodePreserveAttributeOrder = 1UL << 21,
    SSXMLNodePreserveEntities = 1UL << 22,
    SSXMLNodePreservePrefixes = 1UL << 23,
    SSXMLNodePreserveCDATA = 1UL << 24,
    SSXMLNodePreserveWhitespace = 1UL << 25,
    SSXMLNodePreserveDTD = 1UL << 26,
    SSXMLNodePreserveCharacterReferences = 1UL << 27,
    SSXMLNodePromoteSignificantWhitespace = 1UL << 28,
    SSXMLNodePreserveEmptyElements =
    (SSXMLNodeExpandEmptyElement | SSXMLNodeCompactEmptyElement),
    SSXMLNodePreserveQuotes =
    (SSXMLNodeUseSingleQuotes | SSXMLNodeUseDoubleQuotes),
    SSXMLNodePreserveAll = (
                            SSXMLNodePreserveNamespaceOrder |
                            SSXMLNodePreserveAttributeOrder |
                            SSXMLNodePreserveEntities |
                            SSXMLNodePreservePrefixes |
                            SSXMLNodePreserveCDATA |
                            SSXMLNodePreserveEmptyElements |
                            SSXMLNodePreserveQuotes |
                            SSXMLNodePreserveWhitespace |
                            SSXMLNodePreserveDTD |
                            SSXMLNodePreserveCharacterReferences |
                            0xFFF00000) // high 12 bits
} NS_SWIFT_NAME(XMLNode.Options);
