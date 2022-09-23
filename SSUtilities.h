//
//  SSUtilities.h
//  SSFoundation
//
//  Created by Dante Sabatier on 8/3/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSComparisonResult SSCompareVersions(NSString *currentVersion, NSString *latestVersion) NS_AVAILABLE(10_5, 4_0);
extern NSString *SSHumanReadableFileSizeUsingFormat(NSNumber *fileSize, NSString *format) NS_AVAILABLE(10_5, 4_0);
extern NSString *SSHumanReadableTime(int32_t seconds) NS_AVAILABLE(10_5, 4_0);
extern NSData *__nullable SSGetImageDataOfItemAtURL(NSURL *URL);
extern CFNetDiagnosticStatus SSValidateConnectionWithURL(NSURL *url, NSString *__nullable *__nullable diagnosticDescription) NS_DEPRECATED(10_6, 10_13, 6_0, 11_0);
extern CFNetDiagnosticStatus SSValidateInternetConnection(NSString *__nullable *__nullable diagnosticDescription) NS_DEPRECATED(10_6, 10_13, 6_0, 11_0);
extern BOOL SSInternetConnectionIsUp(void) NS_DEPRECATED(10_6, 10_13, 6_0, 11_0);

NS_ASSUME_NONNULL_END
