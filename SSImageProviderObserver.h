//
//  SSImageProviderObserver.h
//  SSFoundation
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSImageProvider.h"

typedef void (^SSImageProviderObserverBlock)(CGImageRef image, CGSize imageSize, SSImageProviderState state, long long loadedImageLength, long long expectedImageLength);

@interface SSImageProviderObserver : NSObject {
@private
    NSURL *_URL;
    NSOperationQueue *_queue;
    SSImageProviderObserverBlock _block;
}

@property (copy) NSURL *URL;
@property (strong) NSOperationQueue *queue;
@property (copy) SSImageProviderObserverBlock block;

@end
