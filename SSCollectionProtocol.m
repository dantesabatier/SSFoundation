//
//  SSCollectionProtocol.h
//  SSFoundation
//
//  Created by Dante Sabatier on 1/15/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation NSSet (NSSetCollectionProtocolAdditions)

- (BOOL)isEmpty {
    return self.count == 0;
}

@end

@implementation NSArray (NSArrayCollectionProtocolAdditions)

- (BOOL)isEmpty {
    return self.count == 0;
}

@end

@implementation NSDictionary (NSDictionaryCollectionProtocolAdditions)

- (BOOL)isEmpty {
    return self.count == 0;
}

@end
