//
//  SSCollectionProtocol.h
//  SSFoundation
//
//  Created by Dante Sabatier on 1/15/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSCollectionProtocol <NSObject>

@property (readonly) NSUInteger count;
@property (readonly) BOOL isEmpty;

@end

@interface NSSet (NSSetCollectionProtocolAdditions) <SSCollectionProtocol>

@end

@interface NSArray (NSArrayCollectionProtocolAdditions) <SSCollectionProtocol>

@end

@interface NSDictionary (NSDictionaryCollectionProtocolAdditions) <SSCollectionProtocol>

@end
