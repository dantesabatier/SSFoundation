//
//  SSUtilities.m
//  SSFoundation
//
//  Created by Dante Sabatier on 8/3/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSUtilities.h"
#import "NSNumber+SSAdditions.h"
#import "NSArray+SSAdditions.h"
#if TARGET_OS_IPHONE
#import <graphics/SSImage.h>
#import <UIKit/UIImage.h>
#else
#import <AppKit/NSImage.h>
#import <AppKit/NSBitmapImageRep.h>
#import <SSGraphics/SSImage.h>
#endif
#if !TARGET_OS_WATCH
#import <AVFoundation/AVFoundation.h>
#endif

NSComparisonResult SSCompareVersions(NSString *currentVersion, NSString *latestVersion) {
	NSArray *current = [currentVersion componentsSeparatedByString:@"."];
	NSArray *latest = [latestVersion componentsSeparatedByString:@"."];
    NSInteger i, currentCount = current.count, latestCount = latest.count;
	for (i = 0; i < currentCount && i < latestCount; i++) {
		NSInteger c = [current[i] integerValue];
		NSInteger l = [latest[i] integerValue];
		
        if (c < l) {
            return NSOrderedAscending;
        } else if (c > l) {
            return NSOrderedDescending;
        }
            
    }
    return (i < latestCount) ? NSOrderedAscending : NSOrderedSame;
}

NSString *SSHumanReadableFileSizeUsingFormat(NSNumber *fileSize, NSString *format) {
    CGFloat bytes = (CGFloat)fileSize.CGFloatValue;
	NSString *suffix = @"";
	
    if (!format.length) {
        format = @"#,###.##;0.00;(#,##0.00)";
    }
    
    if (bytes < 1024) {
        suffix = @"bytes";
    } else if (bytes < 1024 * 1024) {
		suffix = @"KB";
		bytes = (bytes/(CGFloat)1024.0);
	} else if (bytes < 1024 * 1024 * 1024) {
		suffix = @"MB";
		bytes = (bytes/(CGFloat)1024.0/(CGFloat)1024.0);
	} else {
		suffix = @"GB";
		bytes = (bytes/(CGFloat)1024.0/(CGFloat)1024.0/(CGFloat)1024.0);
	}
	
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.decimalSeparator = @",";
    
#if TARGET_OS_IPHONE
    formatter.positiveFormat = format;
#else
    formatter.format = format;
#endif
	
	return [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:@(bytes)], suffix];
}

NSString *SSHumanReadableTime(int32_t seconds) {
    div_t hours = div(seconds, 3600);
	div_t minutes = div(hours.rem, 60);
    
    if ((minutes.quot == 0) && (minutes.rem == 0)) {
        return @"";
    }
    
    if (hours.quot == 0) {
        return [NSString stringWithFormat:@"%d:%.2d", minutes.quot, minutes.rem];
    }
    
    return [NSString stringWithFormat:@"%d:%02d:%02d", hours.quot, minutes.quot, minutes.rem];
}

NSData *SSGetImageDataOfItemAtURL(NSURL *URL) {
    NSData *imageData = nil;
    CFStringRef inUTI = SSAutorelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)URL.pathExtension, NULL));
    if (UTTypeConformsTo(inUTI, kUTTypeImage)) {
        imageData = [[[NSData alloc] initWithContentsOfURL:URL options:0 error:NULL] autorelease];
    } else if (UTTypeConformsTo(inUTI, kUTTypePDF)) {
#if TARGET_OS_IPHONE
        imageData = UIImageJPEGRepresentation([[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:URL options:0 error:NULL]] autorelease ], 1.0);
#else
        imageData = [[[[NSBitmapImageRep alloc] initWithData:[[[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:URL options:0 error:NULL]] autorelease].TIFFRepresentation] autorelease] representationUsingType:NSJPEGFileType properties:@{NSImageCompressionFactor: @1.0}];
#endif
    } else if (UTTypeConformsTo(inUTI, kUTTypeAudio) || UTTypeConformsTo(inUTI, kUTTypeMovie)) {
#if (!(TARGET_OS_IPHONE && defined(__MAC_10_7))) || (TARGET_OS_IPHONE && defined(__IPHONE_5_0)) && !TARGET_OS_WATCH
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
        id obj = ((AVMetadataItem *)[asset.commonMetadata filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [[evaluatedObject commonKey] isEqualToString:AVMetadataCommonKeyArtwork];
        }]].firstObject).value;
        
        if (obj) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                 imageData = obj[@"data"];
            } else if ([obj isKindOfClass:[NSData class]]) {
                imageData = obj;
            }
        } else {
            if (UTTypeConformsTo(inUTI, kUTTypeMovie)) {
                imageData = (__bridge NSData *)SSImageGetData(SSAutorelease([[AVAssetImageGenerator assetImageGeneratorWithAsset:asset] copyCGImageAtTime:CMTimeMakeWithSeconds(MIN(6, CMTimeGetSeconds(asset.duration)), 1) actualTime:NULL error:NULL]));
            }
                
        }
#else
#if !TARGET_OS_IPHONE
        imageData = (__bridge NSData *)SSImageGetData(SSAutorelease(SSImageCreateWithPreviewOfItemAtURL((__bridge CFURLRef)URL, CGSizeZero)));
#endif
#endif
    }
#if !TARGET_OS_IPHONE
    else {
        imageData = (__bridge NSData *)SSImageGetData(SSAutorelease(SSImageCreateWithPreviewOfItemAtURL((__bridge CFURLRef)URL, CGSizeZero)));
    }  
#endif
    return imageData;
}

CFNetDiagnosticStatus SSValidateConnectionWithURL(NSURL *url, NSString **diagnosticDescription) {
    CFStringRef description = nil;
    CFNetDiagnosticStatus status = kCFNetDiagnosticErr;
    if (url) {
        CFNetDiagnosticRef diagnostic = CFNetDiagnosticCreateWithURL(CFAllocatorGetDefault(), (__bridge CFURLRef)url);
        status = CFNetDiagnosticCopyNetworkStatusPassively(diagnostic, &description);
        CFRelease(diagnostic);
        
        if (diagnosticDescription) {
            *diagnosticDescription = [[(__bridge NSString *)description copy] autorelease];
        }
        
        if (description) {
            CFRelease(description);
        }
    }
    
    return status;
}

CFNetDiagnosticStatus SSValidateInternetConnection(NSString **diagnosticDescription) {
    return SSValidateConnectionWithURL([NSURL URLWithString:@"https://www.apple.com"], diagnosticDescription);
}

BOOL SSInternetConnectionIsUp(void) {
    return SSValidateInternetConnection(NULL) == kCFNetDiagnosticConnectionUp;
}
