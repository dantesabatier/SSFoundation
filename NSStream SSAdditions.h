//
//  NSStream+SSAdditions.h
//  SSFoundation
//
//  Created by Dante Sabatier on 14/02/13.
//
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSStream (SSAdditions)

#if !TARGET_OS_WATCH
+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream * __nullable * __nullable)inputStream outputStream:(NSOutputStream * __nullable * __nullable)outputStream;
#endif

@end

extern CFIndex SSWriteStreamWriteFully(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length);

NS_ASSUME_NONNULL_END
