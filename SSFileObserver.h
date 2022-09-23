//
//  SSFileObserver.h
//  SSPluginKit
//
//  Created by Dante Sabatier on 6/18/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSFileObserverDelegate;

@interface SSFileObserver : NSObject {
@private
    NSDate *_launchDate;
	NSArray *_observedLocations;
	NSMutableDictionary *_modifications;
    FSEventStreamRef _streamRef;
	FSEventStreamEventId _eventStreamEventId;
    id <SSFileObserverDelegate> _delegate;
}

- (id<SSFileObserverDelegate>)delegate;
- (void)setDelegate:(id<SSFileObserverDelegate>)delegate;
- (NSArray *)observedLocations;
- (void)setObservedLocations:(NSArray *)observedLocations;

@end

@protocol SSFileObserverDelegate <NSObject>

- (void)fileObserver:(SSFileObserver *)fileObserver locationDidChange:(NSString *)location;

@end
