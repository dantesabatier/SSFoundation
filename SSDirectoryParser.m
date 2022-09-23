//
//  SSDirectoryParser.m
//  SSFoundation
//
//  Created by Dante Sabatier on 6/17/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSDirectoryParser.h"

@implementation SSDirectoryParser

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    
    [_fileManager release];
    [_baseURL release];
    [_error release];
    
    [super ss_dealloc];
}

- (void)cancel
{
    if (self.isCancelled)
        return;
	
	_cancelled = YES;
	
	self.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
}

- (BOOL)parse;
{
    _cancelled = NO;
    
    return [self parseDirectoryAtURL:self.baseURL];
}

- (BOOL)parseDirectoryAtURL:(NSURL *)directoryURL;
{
#if !TARGET_OS_IPHONE
    LSItemInfoRecord itemInfo;
    if ((LSCopyItemInfoForURL((__bridge CFURLRef)directoryURL, kLSRequestBasicFlagsOnly, &itemInfo) == noErr) && (itemInfo.flags & kLSItemInfoIsInvisible))
        return YES;
#endif
    BOOL isDirectory;
    NSString *directory = directoryURL.path;
    NSFileManager *fileManager = self.fileManager;
	if ([fileManager fileExistsAtPath:directory isDirectory:&isDirectory]) {
        id <SSDirectoryParserDelegate>delegate = self.delegate;
        BOOL isFilePackage = NO;
#if !TARGET_OS_IPHONE
        isFilePackage = [[NSWorkspace sharedWorkspace] isFilePackageAtPath:directory];
#endif
        if (!isDirectory || isFilePackage)
            [delegate directoryParser:self fileReachedAtURL:directoryURL];
        else {
            if ([delegate respondsToSelector:@selector(directoryParser:shouldParseDirectoryAtURL:)] && ![delegate directoryParser:self shouldParseDirectoryAtURL:directoryURL])
                return YES;
            if ([delegate respondsToSelector:@selector(directoryParser:willParseDirectoryAtURL:)])
                [delegate directoryParser:self willParseDirectoryAtURL:directoryURL];
            
            NSError *error = nil;
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:directory error:&error];
            if (error) {
                self.error = error;
                return NO;
            }
            
            for (NSString *component in contents) {
                if (self.isCancelled)
                    break;
                
                [self parseDirectoryAtURL:[directoryURL URLByAppendingPathComponent:component]];
            }
        }
    }
    
    return YES;
}

- (id<SSDirectoryParserDelegate>)delegate;
{
    return _delegate;
}

- (void)setDelegate:(id<SSDirectoryParserDelegate>)delegate;
{
    _delegate = delegate;
}

- (NSURL *)baseURL;
{
    return SSAtomicAutoreleasedGet(_baseURL);
}

- (void)setBaseURL:(NSURL *)baseURL;
{
    SSAtomicRetainedSet(_baseURL, baseURL);
}

- (NSError *)error;
{
    return SSAtomicAutoreleasedGet(_error);
}

- (void)setError:(NSError *)error;
{
    SSAtomicRetainedSet(_error, error);
}

- (NSFileManager *)fileManager;
{
    if (!_fileManager)
        _fileManager = [[NSFileManager alloc] init];
    return _fileManager;
}

- (BOOL)isCancelled;
{
    return _cancelled;
}

@end
