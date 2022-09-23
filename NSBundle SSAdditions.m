//
//  NSBundle+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 6/12/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "NSBundle+SSAdditions.h"
#import "NSObject+SSAdditions.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIImage.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <graphics/SSImage.h>
#else
#import <AppKit/NSImage.h>
#import <AppKit/NSWorkspace.h>
#import <SSGraphics/SSImage.h>
#endif

@implementation NSBundle (SSAdditions)

#if (TARGET_MACOS && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_7)) || TARGET_OS_IPHONE

- (NSString *)pathForImageResource:(NSString *)name {
#if TARGET_MACOS
    IMP methodImplementation = SSObjectGetMethodImplementationOfSelector(self, _cmd);
    if (methodImplementation) {
        return ((NSString *(*)(id, SEL, NSString *))SSObjectPerformSupersequentMethodImplementation(self, _cmd, methodImplementation)) (self, _cmd, name);
    }
#endif
    NSString *extension = name.pathExtension;
    if (extension.length) {
        return [self pathForResource:name.stringByDeletingPathExtension ofType:extension];
    }
    
    NSString *path = nil;
    NSArray <NSString *>*imageTypes = (__bridge NSArray <NSString *>*)SSAutorelease(CGImageDestinationCopyTypeIdentifiers());
    for (NSString *imageType in imageTypes) {
        if ((path = [self pathForResource:name ofType:(__bridge NSString *)SSAutorelease(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)imageType, kUTTagClassFilenameExtension))])) {
            break;
        }
    }
    return path;
}

- (NSURL *)URLForImageResource:(NSString *)name {
#if TARGET_MACOS
    IMP methodImplementation = SSObjectGetMethodImplementationOfSelector(self, _cmd);
    if (methodImplementation) {
        return ((NSURL *(*)(id, SEL, NSString *))SSObjectPerformSupersequentMethodImplementation(self, _cmd, methodImplementation)) (self, _cmd, name);
    }
#endif
    return [NSURL fileURLWithPath:[self pathForImageResource:name]];
}

- (id)imageForResource:(NSString *)name {
#if TARGET_MACOS
    IMP methodImplementation = SSObjectGetMethodImplementationOfSelector(self, _cmd);
    if (methodImplementation) {
        return ((id(*)(id, SEL, NSString *))SSObjectPerformSupersequentMethodImplementation(self, _cmd, methodImplementation)) (self, _cmd, name);
    }
#endif
    id image = nil;
#if TARGET_OS_IPHONE
    image = [UIImage imageNamed:name inBundle:self compatibleWithTraitCollection:nil];
#endif
    if (!image) {
        NSString *path = [self pathForImageResource:name];
        if (path) {
#if TARGET_OS_IPHONE
            image = [UIImage imageWithContentsOfFile:path];
            if (!image) {
                CFStringRef imageType = SSAutorelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)path.pathExtension, NULL));
                if (UTTypeConformsTo(imageType, kUTTypePDF)) {
                    CGPDFDocumentRef document = SSAutorelease(CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path]));
                    if (document) {
                        CGImageRef cgImage = SSAutorelease(SSImageCreateWithCGPDFDocument(document, 1, 72.0));
                        if (cgImage) {
                            image = [UIImage imageWithCGImage:cgImage];
#if defined(__IPHONE_7_0)
                            if ([name hasSuffix:@"Template"]) {
                                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            }
#endif
                        }
                    }
                }
            }
#else
            image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
            if ([name hasSuffix:@"Template"]) {
                ((NSImage *)image).template = YES;
            }
#endif
        }
    }
    return image;
}

#endif

#if TARGET_OS_IPHONE

- (NSString *)pathForSoundResource:(NSString *)name {
    NSString *path = nil;
    if (name.length) {
        NSString *extension = name.pathExtension;
        if (extension.length) {
            path = [self pathForResource:name.stringByDeletingPathExtension ofType:extension];
        } else if (!(path = [self pathForResource:name ofType:@"m4a"])) {
            NSArray *audioTypes = @[@"com.apple.m4a-audio", @"com.apple.coreaudio-format", @"com.microsoft.waveform-audio", @"public.aiff-audio", @"public.aifc-audio", @"org.3gpp.adaptive-multi-rate-audio", @"public.mp3", @"public.au-audio", @"public.ac3-audio"];
            for (NSString *audioType in audioTypes) {
                if ((path = [self pathForResource:name ofType:(__bridge NSString *)SSAutorelease(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)audioType, kUTTagClassFilenameExtension))])) {
                    break;
                }
            }
        }
    }
    return path;
}

#endif

- (NSURL *)URLForSoundResource:(NSString *)name {
    NSString *path = [self pathForSoundResource:name];
    return path ? [NSURL fileURLWithPath:path] : nil;
}

#if !TARGET_OS_IPHONE

- (NSSound *)soundForResource:(NSString *)name {
    return [[[NSSound alloc] initWithContentsOfFile:[self pathForSoundResource:name] byReference:NO] autorelease];
}

#endif

- (id)imageForInfoDictionaryKey:(NSString *)key {
    return [self imageForResource:[self objectForInfoDictionaryKey:key]];
}

- (id)icon {
    id icon = [self imageForInfoDictionaryKey:@"CFBundleIconFile"];
#if TARGET_OS_IPHONE
    
#else
    if (!icon) {
        icon = [[NSWorkspace sharedWorkspace] iconForFileType:@"com.apple.plugin"];
    }
    
#if MAC_OS_X_VERSION_MIN_REQUIRED < 1060
    [icon setScalesWhenResized:YES];
#endif
    [icon setSize:CGSizeMake(1024, 1024)];
#endif
    return icon;
}

- (NSString *)name {
    return self.infoDictionary[(__bridge NSString *)kCFBundleNameKey];
}

- (NSString *)localizedName {
    return self.localizedInfoDictionary[(__bridge NSString *)kCFBundleNameKey] ? self.localizedInfoDictionary[(__bridge NSString *)kCFBundleNameKey] : self.infoDictionary[(__bridge NSString *)kCFBundleNameKey];
}

- (NSString *)version {
    return [self objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleVersionKey];
}

- (NSString *)shortVersion {
    return [self objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)appStoreReceiptPath {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_7_0)))
    if ([self respondsToSelector:@selector(appStoreReceiptURL)]) {
        return self.appStoreReceiptURL.path;
    }   
#endif
    return [[[self.bundlePath stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"_MASReceipt"] stringByAppendingPathComponent:@"receipt"];
}

@end
