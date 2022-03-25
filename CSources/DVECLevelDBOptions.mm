// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBOptions+Internal.h"
#import "DVECLevelDBLogger.h"
#import "DVECLevelDBFormattingLoggerFacade.hpp"

@implementation DVECLevelDBOptions

- (instancetype)init {
    if (self = [super init]) {
        _createDBIfMissing = YES;
        _throwErrorIfDBExists = NO;
        _useParanoidChecks = NO;
        _writeBufferSize = 4 * 1024 * 1024;
        _maxOpenFilesCount = 1000;
        _blockSize = 4 * 1024;
        _blockRestartInterval = 16;
        _maxFileSize = 2 * 1024 * 1024;
        _compression = DVECLevelDBOptionsCompressionSnappy;
        _reuseLogs = NO;
    }
    return self;
}

- (leveldb::Options)createDefaultLevelDBOptions {
    return [self createLevelDBOptionsWithLogger:nil keyComparator:nil filterPolicy:nil blockCache:nil];
}

- (leveldb::Options)createLevelDBOptionsWithLogger:(leveldb::Logger *)logger
                                     keyComparator:(leveldb::Comparator *)keyComparator
                                      filterPolicy:(leveldb::FilterPolicy *)filterPolicy
                                        blockCache:(leveldb::Cache *)blockCache
{
    leveldb::Options options;

    options.create_if_missing = _createDBIfMissing;
    options.error_if_exists = _throwErrorIfDBExists;
    options.paranoid_checks = _useParanoidChecks;
    options.write_buffer_size = _writeBufferSize;
    options.max_open_files = _maxOpenFilesCount;
    options.block_size = _blockSize;
    options.block_restart_interval = _blockRestartInterval;
    options.max_file_size = _maxFileSize;
    options.compression = (leveldb::CompressionType)_compression;
    options.reuse_logs = _reuseLogs;

    if (keyComparator != nil) {
        options.comparator = keyComparator;
    }
    if (filterPolicy != nil) {
        options.filter_policy = filterPolicy;
    }
    if (blockCache != nil) {
        options.block_cache = blockCache;
    }

    options.info_log = logger;

    return options;
}

@end
