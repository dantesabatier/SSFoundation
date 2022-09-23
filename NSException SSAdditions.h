//
//  NSException+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 5/10/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSException (SSAdditions)

@property (nonnull, readonly, unsafe_unretained) NSError *underlayingError;

@end

NS_ASSUME_NONNULL_END
