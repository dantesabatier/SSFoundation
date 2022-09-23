//
//  SSImageProviderWorker.m
//  SSFoundation
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSImageProviderWorker.h"

@implementation SSImageProviderWorker

- (void)dealloc {
    [_block release];
    
    [super ss_dealloc];
}

- (SSImageProviderWorkerBlock)block {
    return SSAtomicAutoreleasedGet(_block);
}

- (void)setBlock:(SSImageProviderWorkerBlock)block {
    SSAtomicCopiedSet(_block, block);
}

@end
