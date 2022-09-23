//
//  SSImageProviderObserver.m
//  SSFoundation
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSImageProviderObserver.h"

@implementation SSImageProviderObserver

- (void)dealloc {
    [_queue release];
    [_URL release];
    [_block release];
    
    [super ss_dealloc];
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        return [NSOperationQueue mainQueue];
    }
    return SSAtomicAutoreleasedGet(_queue);
}

- (void)setQueue:(NSOperationQueue *)queue {
    SSAtomicRetainedSet(_queue, queue);
}

- (SSImageProviderObserverBlock)block {
    return SSAtomicAutoreleasedGet(_block);
}

- (void)setBlock:(SSImageProviderObserverBlock)block {
    SSAtomicCopiedSet(_block, block);
}

- (NSURL *)URL {
    return SSAtomicAutoreleasedGet(_URL);
}

- (void)setURL:(NSURL *)URL {
    SSAtomicCopiedSet(_URL, URL);
}

@end
