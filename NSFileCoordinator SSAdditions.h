//
//  NSFileCoordinator+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 08/05/14.
//
//

#import <Foundation/Foundation.h>

@interface NSFileCoordinator (SSAdditions)

- (BOOL)moveItemAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL createIntermediateDirectories:(BOOL)createIntermediateDirectories error:(NSError **)outError;
- (BOOL)moveItemAtURL:(NSURL *)sourceURL error:(NSError **)outError byAccessor:(NSURL * (^)(NSURL *newURL, NSError **outError))accessor;
- (BOOL)removeItemAtURL:(NSURL *)fileURL error:(NSError **)outError byAccessor:(BOOL (^)(NSURL *newURL, NSError **outError))accessor;
- (BOOL)readItemAtURL:(NSURL *)fileURL withChanges:(BOOL)withChanges error:(NSError **)outError byAccessor:(BOOL (^)(NSURL *newURL, NSError **outError))accessor;
- (BOOL)writeItemAtURL:(NSURL *)fileURL withChanges:(BOOL)withChanges error:(NSError **)outError byAccessor:(BOOL (^)(NSURL *newURL, NSError **outError))accessor;
- (BOOL)readItemAtURL:(NSURL *)readURL withChanges:(BOOL)readWithChanges writeItemAtURL:(NSURL *)writeURL withChanges:(BOOL)writeWithChanges error:(NSError **)outError byAccessor:(BOOL (^)(NSURL *newURL1, NSURL *newURL2, NSError **outError))accessor;
- (BOOL)prepareToReadItemsAtURLs:(NSArray *)readingURLs withChanges:(BOOL)withChanges error:(NSError **)outError byAccessor:(BOOL (^)(NSError **outError))accessor;
- (BOOL)prepareToWriteItemsAtURLs:(NSArray *)writingURLs withChanges:(BOOL)withChanges error:(NSError **)outError byAccessor:(BOOL (^)(NSError **outError))accessor;

@end
