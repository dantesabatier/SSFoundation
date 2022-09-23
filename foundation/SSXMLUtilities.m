//
//  SSXMLUtilities.m
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//
//

#import "SSXMLUtilities.h"

const char *kSSXMLXPathDefaultNamespacePrefix = "_def_ns";

BOOL AreEqualOrBothNilPrivate(id obj1, id obj2) {
    if (obj1 == obj2) {
        return YES;
    }
    if (obj1 && obj2) {
        return [obj1 isEqual:obj2];
    }
    return NO;
}

NSString *SSFakeQNameForURIAndName(NSString *theURI, NSString *name) {
    NSString *localName = [SSXMLNode localNameForName:name];
    NSString *fakeQName = [NSString stringWithFormat:@"{%@}:%@", theURI, localName];
    return fakeQName;
}

xmlChar *SplitQNameReverse(const xmlChar *qname, xmlChar **prefix) {
    
    // search backwards for a colon
    int qnameLen = xmlStrlen(qname);
    for (int idx = qnameLen - 1; idx >= 0; idx--) {
        
        if (qname[idx] == ':') {
            
            // found the prefix; copy the prefix, if requested
            if (prefix != NULL) {
                if (idx > 0) {
                    *prefix = xmlStrsub(qname, 0, idx);
                } else {
                    *prefix = NULL;
                }
            }
            
            if (idx < qnameLen - 1) {
                // return a copy of the local name
                xmlChar *localName = xmlStrsub(qname, idx + 1, qnameLen - idx - 1);
                return localName;
            } else {
                return NULL;
            }
        }
    }
    
    // no colon found, so the qualified name is the local name
    xmlChar *qnameCopy = xmlStrdup(qname);
    return qnameCopy;
}
