// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBKeyRange.h"

@implementation DVECLevelDBKeyRange

- (instancetype)initWithStartKey:(NSData *)startKey limitKey:(NSData *)limitKey {
    if (self = [super init]) {
        _startKey = startKey;
        _limitKey = limitKey;
    }
    return self;
}

- (BOOL)isEqualToKeyRange:(DVECLevelDBKeyRange *)other {
    return [self.startKey isEqualToData:other.startKey] &&
        [self.limitKey isEqualToData:other.limitKey];
}

- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }

    if (![object isKindOfClass:[DVECLevelDBKeyRange class]]) {
        return NO;
    }

    return [self isEqualToKeyRange:object];
}

- (NSUInteger)hash {
    return [self.startKey hash] ^ [self.limitKey hash];
}

@end
