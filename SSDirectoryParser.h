//
//  SSDirectoryParser.h
//  SSFoundation
//
//  Created by Dante Sabatier on 6/17/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

@protocol SSDirectoryParserDelegate;

@interface SSDirectoryParser : NSObject {
@private
    NSFileManager *_fileManager;
    NSURL *_baseURL;
    NSError *_error;
    BOOL _cancelled;
    __ss_weak id <SSDirectoryParserDelegate> _delegate;
}

@property (weak) id <SSDirectoryParserDelegate> delegate;
@property (strong) NSURL *baseURL;
@property (readonly, strong) NSError *error;
@property (readonly, getter = isCancelled) BOOL cancelled;

- (BOOL)parse;
- (void)cancel;

@end

@protocol SSDirectoryParserDelegate <NSObject>

@optional
- (BOOL)directoryParser:(SSDirectoryParser *)directoryParser shouldParseDirectoryAtURL:(NSURL *)directoryURL;
- (void)directoryParser:(SSDirectoryParser *)directoryParser willParseDirectoryAtURL:(NSURL *)directoryURL;
- (void)directoryParser:(SSDirectoryParser *)directoryParser fileReachedAtURL:(NSURL *)fileURL;

@end
