//
//  NSSortDescriptor+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 9/6/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSortDescriptor (SSAdditions)

+ (NSArray<NSSortDescriptor *>*)ascendingDescriptorsForKeys:(NSString *)firstKey,... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
