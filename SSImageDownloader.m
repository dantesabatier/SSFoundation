//
//  SSImageDownloader.m
//  SSFoundation
//
//  Created by Dante Sabatier on 13/12/13.
//
//

#import "SSImageDownloader.h"

@interface SSImageDownloader ()

@end

@implementation SSImageDownloader

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super initWithURL:URL];
    if (self) {
        _imageSource = CGImageSourceCreateIncremental(NULL);
        _allowedFileTypes = [[NSArray alloc] initWithObjects:(__bridge NSString *)kUTTypeImage, nil];
    }
    return self;
}

- (void)dealloc {
    CFRelease(_imageSource);
    
    [super ss_dealloc];
}

- (void)cancel {
    [super cancel];
    
    _pixelWidth = 0;
    _pixelHeight = 0;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
    [_data appendData:data];
    
    if (isgreater(_expectedContentLength, 0.0)) {
        CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef)_data, (long long)_data.length == _expectedContentLength);
        
        if ((_pixelWidth + _pixelHeight) == 0) {
            CGSize imageSize = SSImageSourceGetPixelSize(_imageSource);
            _pixelWidth = imageSize.width;
            _pixelHeight = imageSize.height;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSDownloaderDidUpdate object:self];
}

#pragma mark getters & setters

- (CGImageRef)image {
    CGImageRef image = NULL;
    if (isgreater(_expectedContentLength, 0.0)) {
        image = SSAutorelease(CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL));
#if TARGET_OS_IPHONE
        if (image) {
            const size_t partialHeight = CGImageGetHeight(image);
            CGColorSpaceRef space = SSAutorelease(CGColorSpaceCreateDeviceRGB());
            CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, _pixelWidth, _pixelHeight, 8, _pixelWidth * 4, space, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
            if (ctx) {
                CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = _pixelWidth, .size.height = partialHeight}, image);
                image = SSAutorelease(CGBitmapContextCreateImage(ctx));
            }
        }
#endif
    }
    return image;
}

- (NSDictionary *)imageProperties {
    return isgreater(_expectedContentLength, 0.0) ? (__bridge NSDictionary *)SSAutorelease(CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL)) : nil;
}

- (CGSize)imageSize {
    return isgreater(_expectedContentLength, 0.0) ? CGSizeMake(_pixelWidth, _pixelHeight) : CGSizeZero;
}

@end
