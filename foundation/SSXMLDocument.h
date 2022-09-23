//
//  SSXMLDocument.h
//  SSFoundation
//
//  Created by Dante Sabatier on 26/04/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import "SSXMLElement.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSXMLDocumentContentKind) {
    SSXMLDocumentXMLKind = 0,
    SSXMLDocumentXHTMLKind,
    SSXMLDocumentHTMLKind,
    SSXMLDocumentTextKind
} NS_SWIFT_NAME(XMLDocument.ContentKind);

NS_SWIFT_NAME(XMLDocument)
@interface SSXMLDocument : SSXMLNode {
@protected
    id _private;
}

- (nullable instancetype)initWithXMLString:(NSString *)string options:(SSXMLNodeOptions)mask error:(NSError *__nullable * __nullable)error;
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url options:(SSXMLNodeOptions)mask error:(NSError *__nullable * __nullable)error;
- (nullable instancetype)initWithData:(NSData *)data options:(SSXMLNodeOptions)mask error:(NSError *__nullable * __nullable)error;
- (instancetype)initWithRootElement:(nullable SSXMLElement *)element;
@property (nullable, readonly, strong) SSXMLElement *rootElement;
- (NSData *)XMLDataWithOptions:(SSXMLNodeOptions)options;
@property (nullable, readonly, strong) NSData *XMLData;
- (void)setVersion:(NSString *)version;
- (void)setCharacterEncoding:(NSString *)encoding;

@end

NS_ASSUME_NONNULL_END
