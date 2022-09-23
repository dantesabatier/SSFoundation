//
//  NSStream+SSAdditions.m
//  SSFoundation
//
//  Created by Dante Sabatier on 14/02/13.
//
//

#import "NSStream+SSAdditions.h"
#if !TARGET_OS_WATCH
#import <CFNetwork/CFNetwork.h>
#endif

@implementation NSStream (SSAdditions)

#if !TARGET_OS_WATCH

+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream {
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFHostRef host = CFHostCreateWithName(NULL, (__bridge CFStringRef)hostName);
    if (host) {
        (void) CFStreamCreatePairWithSocketToCFHost(NULL, host, (SInt32)port, &readStream, &writeStream);
        CFRelease(host);
    }
    
    if (inputStream) {
        *inputStream = (__bridge NSInputStream *)SSAutorelease(readStream);
    } else {
        if (readStream) {
            CFRelease(readStream);
        }
    }
    
    if (outputStream) {
        *outputStream = (__bridge NSOutputStream *)SSAutorelease(writeStream);
    } else {
        if (writeStream) {
            CFRelease(writeStream);
        }
    }
}

#endif

@end

CFIndex SSWriteStreamWriteFully(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length) {
    CFIndex bufferOffset = 0;
    CFIndex bytesWritten;
    
    while (bufferOffset < length) {
        if (CFWriteStreamCanAcceptBytes(outputStream)) {
            bytesWritten = CFWriteStreamWrite(outputStream, &(buffer[bufferOffset]), length - bufferOffset);
            if (bytesWritten < 0)
                return bytesWritten;
            bufferOffset += bytesWritten;
        } else if (CFWriteStreamGetStatus(outputStream) == kCFStreamStatusError) {
            return -1;
        } else {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.0, true);
        }
            
    }
    
    return bufferOffset;
}
