//
//  SSFoundationUtilities.m
//  SSFoundation
//
//  Created by Dante Sabatier on 7/30/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSFoundationUtilities.h"
#import "NSBundle+SSAdditions.h"

static BOOL _SSFoundationIsLoaded = NO;
static NSBundle *__resourcesBundle = nil;

__attribute__((constructor)) 
static void SSFoundationInit(void) {
    @autoreleasepool {
        if (!_SSFoundationIsLoaded) {
            _SSFoundationIsLoaded = YES;
        }
    }
}

__attribute__((destructor)) 
static void SSFoundationDestroy(void) {
    [__resourcesBundle release];
}

NSBundle *SSFoundationGetResourcesBundle() {
    if (!__resourcesBundle) {
#if TARGET_OS_IPHONE
        __resourcesBundle = [[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SSFoundationResources" withExtension:@"bundle"]] ss_retain];
#else
        __resourcesBundle = [[NSBundle bundleWithIdentifier:@"com.sabatiersoftware.ssfoundation"] ss_retain];
#endif
    }
    return __resourcesBundle;
}

id SSFoundationGetImageResourceNamed(NSString *name) {
    return [SSFoundationGetResourcesBundle() imageForResource:name];
}
