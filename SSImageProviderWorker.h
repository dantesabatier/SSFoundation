//
//  SSImageProviderWorker.h
//  SSFoundation
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSImageDownloader.h"
#import "SSImageProvider.h"

typedef void (^SSImageProviderWorkerBlock)(CGImageRef image, NSData *imageData, NSDictionary *imageProperties, SSImageProviderResult result, NSError *error);

@interface SSImageProviderWorker : SSImageDownloader {
@private
    SSImageProviderWorkerBlock _block;
}

@property (copy) SSImageProviderWorkerBlock block;

@end
