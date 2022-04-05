// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBOptions+Internal.h"
#import "DVECLevelDBLogger.h"
#import "DVECLevelDBFormattingLoggerFacade.hpp"
#import "DVECLevelDBSimpleLoggerFacade.hpp"

@implementation DVECLevelDBOptions

static size_t _defaultWriteBufferSize = 4 * 1024 * 1024;
static int _defaultMaxOpenFilesCount = 1000;
static size_t _defaultBlockSize = 4 * 1024;
static int _defaultBlockRestartInterval = 16;
static size_t _defaultMaxFileSize = 2 * 1024 * 1024;
static DVECLevelDBOptionsCompression _defaultCompression = DVECLevelDBOptionsCompressionSnappy;

+ (size_t)defaultWriteBufferSize {
    return _defaultWriteBufferSize;
}

+ (int)defaultMaxOpenFilesCount {
    return _defaultMaxOpenFilesCount;
}

+ (size_t)defaultBlockSize {
    return _defaultBlockSize;
}

+ (int)defaultBlockRestartInterval {
    return _defaultBlockRestartInterval;
}

+ (size_t)defaultMaxFileSize {
    return _defaultMaxFileSize;
}

+ (DVECLevelDBOptionsCompression)defaultCompression {
    return _defaultCompression;
}

+ (leveldb::Logger *)createSimpleLoggerFacade:(id<DVECLevelDBSimpleLogger>)logger {
    // Optimization to prevent creation and use of unnecessary logger instance.
    if (logger == nil || [logger isKindOfClass:[DVECLevelDBVoidLogger class]]) {
        return nil;
    }
    return new DVECLevelDBSimpleLoggerFacade(logger);
}

+ (leveldb::Logger *)createFormatLoggerFacade:(id<DVECLevelDBFormatLogger>)logger {
    // Optimization to prevent creation and use of unnecessary logger instance.
    if (logger == nil || [logger isKindOfClass:[DVECLevelDBVoidLogger class]]) {
        return nil;
    }
    return new DVECLevelDBFormattingLoggerFacade(logger);
}

- (instancetype)initWithCreateDBIfMissing:(BOOL)createDBIfMissing
                     throwErrorIfDBExists:(BOOL)throwErrorIfDBExists
                        useParanoidChecks:(BOOL)useParanoidChecks
                          writeBufferSize:(size_t)writeBufferSize
                        maxOpenFilesCount:(int)maxOpenFilesCount
                                blockSize:(size_t)blockSize
                     blockRestartInterval:(int)blockRestartInterval
                              maxFileSize:(size_t)maxFileSize
                                reuseLogs:(BOOL)reuseLogs
                              compression:(DVECLevelDBOptionsCompression)compression
{
    if (self = [super init]) {
        _createDBIfMissing = createDBIfMissing;
        _throwErrorIfDBExists = throwErrorIfDBExists;
        _useParanoidChecks = useParanoidChecks;
        _writeBufferSize = writeBufferSize;
        _maxOpenFilesCount = maxOpenFilesCount;
        _blockSize = blockSize;
        _blockRestartInterval = blockRestartInterval;
        _maxFileSize = maxFileSize;
        _reuseLogs = reuseLogs;
        _compression = compression;
    }
    return self;
}

- (instancetype)init {
    return [self initWithCreateDBIfMissing:YES
                      throwErrorIfDBExists:NO
                         useParanoidChecks:NO
                           writeBufferSize:DVECLevelDBOptions.defaultWriteBufferSize
                         maxOpenFilesCount:DVECLevelDBOptions.defaultMaxOpenFilesCount
                                 blockSize:DVECLevelDBOptions.defaultBlockSize
                      blockRestartInterval:DVECLevelDBOptions.defaultBlockRestartInterval
                               maxFileSize:DVECLevelDBOptions.defaultMaxFileSize
                                 reuseLogs:NO
                               compression:DVECLevelDBOptions.defaultCompression];
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
