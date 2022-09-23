//
//  SSFileObserver.m
//  SSPluginKit
//
//  Created by Dante Sabatier on 6/18/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSFileObserver.h"

#import "SSDefines.h"

void fsevents_callback(ConstFSEventStreamRef streamRef, void *userData, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]);

@implementation SSFileObserver

- (id)init 
{
	self = [super init];
    if (self) 
	{
		_eventStreamEventId = 0;
    }    
	return self;
}

- (void)dealloc
{
    _delegate = nil;
    
	if (_streamRef)
    {
        FSEventStreamStop(_streamRef);
		FSEventStreamInvalidate(_streamRef);
        FSEventStreamRelease(_streamRef);;
    }
	
	[_launchDate release];
	[_observedLocations release];
	[_modifications release];
	
	[super dealloc];
}

#pragma mark private methods

- (void)verifyChangesOfItemAtLocation:(NSString *)location 
{
    NSMutableDictionary *modifications = self.modifications;
	NSDictionary *fileAttributes = [NSFileManager.defaultManager attributesOfItemAtPath:location error:NULL];
	NSDate *currentDate = fileAttributes[NSFileModificationDate];
	NSDate *lastDate = modifications[location];
	if (!lastDate) lastDate = _launchDate;
	
	if ([currentDate compare:lastDate] != NSOrderedDescending) return;
	
    [self.delegate fileObserver:self locationDidChange:location.stringByStandardizingPath];
	
	modifications[location] = currentDate;
}

- (void)updateEventStreamEventId:(FSEventStreamEventId)eventStreamEventId; 
{
	_eventStreamEventId = eventStreamEventId;
}

#pragma mark getters & setters

- (id<SSFileObserverDelegate>)delegate;
{
    return _delegate;
}

- (void)setDelegate:(id<SSFileObserverDelegate>)delegate;
{
    if (![delegate conformsToProtocol:@protocol(SSFileObserverDelegate)])
        [NSException raise:NSInvalidArgumentException format:@"%@ %@%@, invalid delegate", self.class, NSStringFromSelector(_cmd), delegate];
    _delegate = delegate;
}

- (FSEventStreamRef)streamRef;
{
    return _streamRef;
}

- (NSMutableDictionary *)modifications
{
    if (!_modifications) _modifications = [[NSMutableDictionary alloc] init];
    return _modifications;
}

- (NSArray *)observedLocations; 
{
	return _observedLocations;
}

- (void)setObservedLocations:(NSArray *)observedLocations;
{
    if ([self.observedLocations isEqualToArray:observedLocations]) return;
    
    SSNonAtomicCopiedSet(_observedLocations, observedLocations);
    
    NSMutableDictionary *modifications = self.modifications;
    [modifications removeAllObjects];
    
    if (_streamRef)
    {
        FSEventStreamStop(_streamRef);
		FSEventStreamInvalidate(_streamRef);
        FSEventStreamRelease(_streamRef);
    }
    
    if (observedLocations.count)
    {
        for (NSString *location in observedLocations)
        {
            if (![NSFileManager.defaultManager isReadableFileAtPath:location]) continue;
            
            NSDictionary *fileAttributes = [NSFileManager.defaultManager attributesOfItemAtPath:location error:NULL];
            NSDate *modificationDate = fileAttributes[NSFileModificationDate];
            if (!modificationDate) continue;
            
            modifications[location] = modificationDate;
        }
        
        SSNonAtomicCopiedSet(_launchDate, [NSDate date]);
        FSEventStreamContext context = {0, (void *)self, NULL, NULL, NULL};
        
        _streamRef = FSEventStreamCreate(NULL, &fsevents_callback, &context, (__bridge CFArrayRef) observedLocations, _eventStreamEventId, (CFAbsoluteTime) 3.0, kFSEventStreamCreateFlagUseCFTypes);
        
        FSEventStreamScheduleWithRunLoop(_streamRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStart(_streamRef);
    }
}

@end

void fsevents_callback(ConstFSEventStreamRef streamRef, void *userData, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]) 
{
    SSFileObserver *fileObserver = (__bridge SSFileObserver *)userData;
	size_t i;
	for (i = 0; i < numEvents; i++) 
	{
		[fileObserver verifyChangesOfItemAtLocation:(NSString *) ((__bridge NSArray *)eventPaths)[i]];
		[fileObserver updateEventStreamEventId:eventIds[i]];
	}
}
