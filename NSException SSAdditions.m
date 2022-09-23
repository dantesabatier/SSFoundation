//
//  NSException+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 5/10/15.
//
//

#import "NSException+SSAdditions.h"
#import "SSFoundationUtilities.h"

@implementation NSException (SSAdditions)

- (NSError *)underlayingError {
    return [NSError errorWithDomain:@"SSFoundationErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: SSFoundationLocalizedString(@"An unexpected error has occurred", @"error description"), NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat:@"%@ %@ \"%@\" %@", self.class, NSStringFromSelector(_cmd), self.name, self.reason]}];
}

@end
