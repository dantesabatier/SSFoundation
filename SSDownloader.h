//
//  SSDownloader.h
//  SSFoundation
//
//  Created by Dante Sabatier on 13/11/14.
//
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol SSDownloaderDelegate;

@interface SSDownloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
@package
    NSURL *_URL;
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSArray *_allowedFileTypes;
    long long _expectedContentLength;
    NSError *_error;
    BOOL _cancelled;
    __ss_weak id <SSDownloaderDelegate> _delegate;
}

@property (nullable, nonatomic, ss_weak) id <SSDownloaderDelegate> delegate;
@property (nullable, nonatomic, copy) NSArray <NSString *> *allowedFileTypes;
@property (nullable, nonatomic, readonly, copy) NSURL *URL;
@property (nullable, nonatomic, readonly, copy) NSData *data;
@property (nullable, nonatomic, readonly, copy) NSError *error;
@property (readonly, nonatomic, getter = isCancelled) BOOL cancelled;
@property (readonly, nonatomic) long long expectedContentLength;
@property (readonly, nonatomic) long long currentContentLength;
- (instancetype)init SS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)URL;
- (void)start;
- (void)cancel;

@end

@protocol SSDownloaderDelegate <NSObject>

@optional
- (void)downloaderDidStartLoading:(NSNotification *)notification;
- (void)downloaderDidUpdate:(NSNotification *)notification;
- (void)downloaderDidFinishLoading:(NSNotification *)notification;

@end

//notification names
extern NSString *const SSDownloaderDidStartLoading;
extern NSString *const SSDownloaderDidUpdate;
extern NSString *const SSDownloaderDidFinishLoading;

NS_ASSUME_NONNULL_END
