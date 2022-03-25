// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBOptions.h"
#import "leveldb/leveldb/options.h"

@interface DVECLevelDBWriteOptions()
@property (nonatomic, assign, readonly) leveldb::WriteOptions *options;
@end

@implementation DVECLevelDBWriteOptions

+ (instancetype)DVECLevelDBWriteOptionsWithSyncWrite:(BOOL)syncWrite {
    DVECLevelDBWriteOptions *options = [DVECLevelDBWriteOptions new];
    options.syncWrite = syncWrite;
    return options;
}

- (instancetype)init {
    if (self = [super init]) {
        _options = new leveldb::WriteOptions;
    }
    return self;
}

- (void)dealloc {
    delete _options;
    _options = nil;
}

- (BOOL)syncWrite {
    return _options->sync;
}

- (void)setSyncWrite:(BOOL)syncWrite {
    _options->sync = syncWrite;
}

@end
