//
//  SSDownloader.m
//  SSFoundation
//
//  Created by Dante Sabatier on 13/11/14.
//
//

#import "SSDownloader.h"

NSString *const SSDownloaderDidStartLoading = @"SSDownloaderDidStartLoading";
NSString *const SSDownloaderDidUpdate = @"SSDownloaderDidUpdate";
NSString *const SSDownloaderDidFinishLoading = @"SSDownloaderDidFinishLoading";

@implementation SSDownloader

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        _URL = [URL copy];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    
    [_allowedFileTypes release];
    [_URL release];
    [_connection release];
    [_data release];
    [_error release];
    
    [super ss_dealloc];
}

- (void)start {
    [self cancel];
    
    __ss_weak NSURL *URL = self.URL;
    NSParameterAssert(URL != nil);
    
    CFStringRef inUTI = SSAutorelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)URL.pathExtension, NULL));
    __ss_weak NSArray *allowedFileTypes = self.allowedFileTypes;
    for (NSString *allowedFileType in allowedFileTypes) {
        if (!UTTypeConformsTo(inUTI, (__bridge CFStringRef)allowedFileType)) {
            self.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSDownloaderDidFinishLoading object:self];
            return;
        }
    }
    
    self.error = nil;
    _cancelled = NO;
    
#if !TARGET_OS_WATCH
    _connection = [[NSURLConnection alloc] initWithRequest:[[[NSURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy|NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15] autorelease] delegate:self startImmediately:NO];
#endif
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_connection start];
}

- (void)cancel {
    self.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
    if (_connection) {
        [_connection cancel];
        [_connection release];
        _connection = nil;
        [_data release];
        _data = nil;
        _expectedContentLength = 0;
        _cancelled = YES;
    }
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.error = error;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSDownloaderDidFinishLoading object:self];
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
    [[NSNotificationCenter defaultCenter] postNotificationName:SSDownloaderDidStartLoading object:self];
    
    if (![response respondsToSelector:@selector(statusCode)] || (((NSHTTPURLResponse *)response).statusCode < 400)) {
        _expectedContentLength = isgreater(response.expectedContentLength, 0.0) ? response.expectedContentLength : 0.0;
        _data = [[NSMutableData alloc] initWithCapacity:(NSUInteger)_expectedContentLength];
    } else {
        [self cancel];
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
    [_data appendData:data];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSDownloaderDidUpdate object:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    [[NSNotificationCenter defaultCenter] postNotificationName:SSDownloaderDidFinishLoading object:self];
}

#pragma mark getters & setters

- (id<SSDownloaderDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<SSDownloaderDelegate>)delegate {
    __ss_weak __typeof(_delegate) weakDelegate = _delegate;
    if (weakDelegate) {
        if ([weakDelegate respondsToSelector:@selector(downloaderDidStartLoading:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:weakDelegate name:SSDownloaderDidStartLoading object:self];
        }
        
        if ([weakDelegate respondsToSelector:@selector(downloaderDidUpdate:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:weakDelegate name:SSDownloaderDidUpdate object:self];
        }
            
        if ([weakDelegate respondsToSelector:@selector(downloaderDidFinishLoading:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:weakDelegate name:SSDownloaderDidFinishLoading object:self];
        }
            
        
        weakDelegate = nil;
    }
    
    weakDelegate = delegate;
    
    if (weakDelegate) {
        if ([weakDelegate respondsToSelector:@selector(downloaderDidStartLoading:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:weakDelegate selector:@selector(downloaderDidStartLoading:) name:SSDownloaderDidStartLoading object:self];
        }
        
        if ([weakDelegate respondsToSelector:@selector(downloaderDidUpdate:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:weakDelegate selector:@selector(downloaderDidUpdate:) name:SSDownloaderDidUpdate object:self];
        }
            
        if ([weakDelegate respondsToSelector:@selector(downloaderDidFinishLoading:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:weakDelegate selector:@selector(downloaderDidFinishLoading:) name:SSDownloaderDidFinishLoading object:self];
        }
            
    }
}

- (NSArray *)allowedFileTypes {
    return SSAtomicAutoreleasedGet(_allowedFileTypes);
}

- (void)setAllowedFileTypes:(NSArray *)allowedFileTypes {
    SSAtomicCopiedSet(_allowedFileTypes, allowedFileTypes);
}

- (NSURL *)URL {
    return SSAtomicAutoreleasedGet(_URL);
}

- (void)setURL:(NSURL *)URL {
    SSAtomicCopiedSet(_URL, URL);
}

- (NSError *)error {
    return SSAtomicAutoreleasedGet(_error);
}

- (void)setError:(NSError *)error {
    SSAtomicCopiedSet(_error, error);
}

- (NSData *)data {
    return _data;
}

- (long long)expectedContentLength {
    return _expectedContentLength;
}

- (long long)currentContentLength {
    return (long long)_data.length;
}

- (BOOL)isCancelled {
    return _cancelled;
}

@end
