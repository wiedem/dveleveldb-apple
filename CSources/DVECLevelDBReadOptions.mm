// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBOptions.h"
#import "DVECLevelDBSnapshot+Internal.h"
#import "leveldb/leveldb/options.h"

@interface DVECLevelDBReadOptions()
@property (nonatomic, assign, readonly) leveldb::ReadOptions *options;
@end

@implementation DVECLevelDBReadOptions

+ (instancetype)DVECLevelDBReadOptionsWithVerifyChecksums:(BOOL)verifyChecksums fillCache:(BOOL)fillCache {
    DVECLevelDBReadOptions *options = [DVECLevelDBReadOptions new];
    options.verifyChecksums = verifyChecksums;
    options.fillCache = fillCache;
    return options;
}

- (instancetype)init {
    if (self = [super init]) {
        _options = new leveldb::ReadOptions;
    }
    return self;
}

- (void)dealloc {
    delete _options;
    _options = nil;
}

- (BOOL)verifyChecksums {
    return _options->verify_checksums;
}

- (void)setVerifyChecksums:(BOOL)verifyChecksums {
    _options->verify_checksums = verifyChecksums;
}

- (BOOL)fillCache {
    return _options->fill_cache;
}

- (void)setFillCache:(BOOL)fillCache {
    _options->fill_cache = fillCache;
}

- (void)setSnapshot:(DVECLevelDBSnapshot *)snapshot {
    _snapshot = snapshot;

    if (snapshot != nil) {
        _options->snapshot = snapshot.snapshot;
    } else {
        _options->snapshot = nil;
    }
}

@end
