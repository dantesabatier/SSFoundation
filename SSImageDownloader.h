//
//  SSImageDownloader.h
//  SSFoundation
//
//  Created by Dante Sabatier on 13/12/13.
//
//

#import <TargetConditionals.h>
#import "SSDownloader.h"
#if TARGET_OS_IPHONE
#import <graphics/SSImage.h>
#import <graphics/SSImageSource.h>
#else
#import <SSGraphics/SSImage.h>
#import <SSGraphics/SSImageSource.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SSImageDownloader : SSDownloader {
@private
    CGImageSourceRef _imageSource;
    size_t _pixelWidth;
    size_t _pixelHeight;
}

@property (nullable, nonatomic, readonly) CGImageRef image;
@property (nullable, nonatomic, readonly, copy) NSDictionary <NSString *, id>*imageProperties;
@property (nonatomic, readonly) CGSize imageSize;

@end

NS_ASSUME_NONNULL_END

