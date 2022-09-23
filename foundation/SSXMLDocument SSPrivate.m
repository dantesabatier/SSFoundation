//
//  SSXMLDocument+SSPrivate.m
//  SSFoundation
//
//  Created by Dante Sabatier on 06/05/17.
//
//

#import "SSXMLDocument+SSPrivate.h"

static const void *StringCacheKeyRetainCallBack(CFAllocatorRef allocator, const void *str) {
    return xmlStrdup(str);
}

static void StringCacheKeyReleaseCallBack(CFAllocatorRef allocator, const void *str) {
    xmlFree((char *) (char *)str);
}

static CFStringRef StringCacheKeyCopyDescriptionCallBack(const void *str) {
    return CFStringCreateWithCString(kCFAllocatorDefault, (const char *)str, kCFStringEncodingUTF8);
}

static Boolean StringCacheKeyEqualCallBack(const void *str1, const void *str2) {
    // compare the key strings
    if (str1 == str2) return true;
    int result = xmlStrcmp(str1, str2);
    return (result == 0);
}

static CFHashCode StringCacheKeyHashCallBack(const void *str) {
    
    // dhb hash, per http://www.cse.yorku.ca/~oz/hash.html
    CFHashCode hash = 5381;
    unsigned int c;
    const unsigned char *chars = (const unsigned char *)str;
    while ((c = *chars++) != 0) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

@implementation SSXMLDocument (SSPrivate)

- (instancetype)initWithXMLDocument:(xmlDoc *)document {
    
    NSCAssert((document != NULL) && (document->_private == NULL), @"SSXMLDocument cache creation problem");
    
    CFIndex capacity = 0;
    CFDictionaryKeyCallBacks keyCallBacks = {
        0,
        StringCacheKeyRetainCallBack,
        StringCacheKeyReleaseCallBack,
        StringCacheKeyCopyDescriptionCallBack,
        StringCacheKeyEqualCallBack,
        StringCacheKeyHashCallBack
    };
    
    document->_private = CFDictionaryCreateMutable(kCFAllocatorDefault, capacity, &keyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    self = [super init];
    if (self) {
        _private = (__bridge id)document;
    }
    return self;
}

- (xmlDoc *)xmlDocument {
    return (__bridge xmlDoc *)_private;
}

@end
