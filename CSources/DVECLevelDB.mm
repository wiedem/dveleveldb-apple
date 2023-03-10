// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDB.h"
#import "DVECLevelDBFormattingLoggerFacade.hpp"
#import "DVECLevelDBSimpleLoggerFacade.hpp"
#import "DVECLevelDBComparatorFacade.hpp"
#import "DVECLevelDBFilterPolicyFacade.hpp"

#import "DVECLevelDBOptions+Internal.h"
#import "DVECLevelDBReadOptions+Internal.h"
#import "DVECLevelDBWriteOptions+Internal.h"
#import "DVECLevelDBKeyEnumerator.h"
#import "DVECLevelDBKeyComparator.h"
#import "DVECLevelDBError.h"
#import "NSError+DVECLevelDBError.h"

#import "leveldb/leveldb/db.h"

@interface DVECLevelDB()
@property (nonatomic, strong) NSURL *directoryURL;
@property (nonatomic, strong) DVECLevelDBOptions *options;
@property (nonatomic, assign) leveldb::DB *db;

@property (nonatomic, assign) leveldb::Logger *logger;
@property (nonatomic, assign) leveldb::Comparator *keyComparator;
@property (nonatomic, assign) leveldb::FilterPolicy *filterPolicy;
@property (nonatomic, assign) leveldb::Cache *blockCache;

@property (nonatomic, strong) DVECLevelDBWriteOptions *syncWriteOptions;
@end

@implementation DVECLevelDB

@synthesize syncWriteOptions = _syncWriteOptions;

+ (BOOL)destroyDbAtDirectoryURL:(NSURL *)url options:(DVECLevelDBOptions *)options error:(NSError **)error {
    leveldb::Options levelDBOptions = [options createDefaultLevelDBOptions];
    leveldb::Status status = leveldb::DestroyDB([url.path UTF8String], levelDBOptions);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return NO;
    }
    return YES;
}

+ (BOOL)repairDbAtDirectoryURL:(NSURL *)url options:(DVECLevelDBOptions *)options error:(NSError **)error {
    leveldb::Options levelDBOptions = [options createDefaultLevelDBOptions];
    leveldb::Status status = leveldb::RepairDB([url.path UTF8String], levelDBOptions);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return NO;
    }
    return YES;
}

+ (void)raiseCriticalExceptionForError:(NSError *)error key:(NSString *)key {
    NSString *debugDescription = error.userInfo[NSDebugDescriptionErrorKey];
    if (debugDescription == nil) {
        debugDescription = @"unknown error";
    }
    [NSException raise:DVECLevelDBException format:@"Critical error setting object for key %@: %@", key, debugDescription];
}

+ (int)majorVersion {
    return leveldb::kMajorVersion;
}

+ (int)minorVersion {
    return leveldb::kMinorVersion;
}

#pragma mark -
- (instancetype)initWithDirectoryURL:(NSURL *)url
                             options:(DVECLevelDBOptions *)options
                              logger:(leveldb::Logger *)logger
                       keyComparator:(leveldb::Comparator *)keyComparator
                        filterPolicy:(leveldb::FilterPolicy *)filterPolicy
                          blockCache:(leveldb::Cache *)blockCache
                               error:(NSError **)error
{
    self = [super init];
    if (!self) {
        return nil;
    }

    _logger = logger;
    _keyComparator = keyComparator;
    _filterPolicy = filterPolicy;
    _blockCache = blockCache;

    leveldb::Options levelDBOptions = [options createLevelDBOptionsWithLogger:_logger
                                                                keyComparator:_keyComparator
                                                                 filterPolicy:_filterPolicy
                                                                   blockCache:_blockCache];
    leveldb::DB *db;
    leveldb::Status status = leveldb::DB::Open(levelDBOptions, [url.path UTF8String], &db);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return nil;
    }
    _db = db;
    _directoryURL = url;
    _options = options;

    return self;
}

- (instancetype)initWithDirectoryURL:(NSURL *)url
                             options:(DVECLevelDBOptions *)options
                        formatLogger:(id<DVECLevelDBFormatLogger>)formatLogger
                       keyComparator:(nullable id<DVECLevelDBKeyComparator>)keyComparator
                        filterPolicy:(nullable id<DVECLevelDBFilterPolicy>)filterPolicy
                   lruBlockCacheSize:(size_t)lruBlockCacheSize
                               error:(NSError **)error
{
    leveldb::Logger *loggerFacade = nil;

    if ([formatLogger isKindOfClass:[DVECLevelDBVoidLogger class]]) {
        // Optimization to prevent creation and use of unnecessary logger instance.
        loggerFacade = new DVECLevelDBFormattingLoggerFacade(nil);
    } else {
        loggerFacade = new DVECLevelDBFormattingLoggerFacade(formatLogger);
    }

    leveldb::Comparator *keyComparatorFacade = nil;
    if (keyComparator != nil) {
        keyComparatorFacade = new DVECLevelDBComparatorFacade(keyComparator);
    }

    leveldb::FilterPolicy *filterPolicyFacade = nil;
    if (filterPolicy != nil) {
        filterPolicyFacade = new DVECLevelDBFilterPolicyFacade(filterPolicy);
    }

    leveldb::Cache *blockCache = nil;
    if (lruBlockCacheSize > 0) {
        blockCache = leveldb::NewLRUCache(lruBlockCacheSize);
    }

    return [self initWithDirectoryURL:url
                              options:options
                               logger:loggerFacade
                        keyComparator:keyComparatorFacade
                         filterPolicy:filterPolicyFacade
                           blockCache:blockCache
                                error:error];
}

- (instancetype)initWithDirectoryURL:(NSURL *)url
                             options:(DVECLevelDBOptions *)options
                        simpleLogger:(id<DVECLevelDBSimpleLogger>)simpleLogger
                       keyComparator:(nullable id<DVECLevelDBKeyComparator>)keyComparator
                        filterPolicy:(nullable id<DVECLevelDBFilterPolicy>)filterPolicy
                   lruBlockCacheSize:(size_t)lruBlockCacheSize
                               error:(NSError **)error
{
    leveldb::Logger *loggerFacade = nil;

    if ([simpleLogger isKindOfClass:[DVECLevelDBVoidLogger class]]) {
        // Optimization to prevent creation and use of unnecessary logger instance.
        loggerFacade = new DVECLevelDBSimpleLoggerFacade(nil);
    } else {
        loggerFacade = new DVECLevelDBSimpleLoggerFacade(simpleLogger);
    }

    leveldb::Comparator *keyComparatorFacade = nil;
    if (keyComparator != nil) {
        keyComparatorFacade = new DVECLevelDBComparatorFacade(keyComparator);
    }

    leveldb::FilterPolicy *filterPolicyFacade = nil;
    if (filterPolicy != nil) {
        filterPolicyFacade = new DVECLevelDBFilterPolicyFacade(filterPolicy);
    }

    leveldb::Cache *blockCache = nil;
    if (lruBlockCacheSize > 0) {
        blockCache = leveldb::NewLRUCache(lruBlockCacheSize);
    }

    return [self initWithDirectoryURL:url
                              options:options
                               logger:loggerFacade
                        keyComparator:keyComparatorFacade
                         filterPolicy:filterPolicyFacade
                           blockCache:blockCache
                                error:error];
}

- (instancetype)initWithDirectoryURL:(NSURL *)url
                             options:(DVECLevelDBOptions *)options
                               error:(NSError **)error {
    return [self initWithDirectoryURL:url
                              options:options
                               logger:nil
                        keyComparator:nil
                         filterPolicy:nil
                           blockCache:nil
                                error:error];
}

- (DVECLevelDBWriteOptions *)syncWriteOptions {
    if (!_syncWriteOptions) {
        _syncWriteOptions = [DVECLevelDBWriteOptions DVECLevelDBWriteOptionsWithSyncWrite:YES];
    }
    return _syncWriteOptions;
}

- (void)dealloc {
    delete _db;
    _db = nil;

    delete _logger;
    _logger = nil;
    delete _keyComparator;
    _keyComparator = nil;
    delete _filterPolicy;
    _filterPolicy = nil;
    delete _blockCache;
    _blockCache = nil;
}

- (id)valueForKey:(NSString *)key {
    return [super valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [super setValue:value forKey:key];
}

- (NSString *)valueForKey:(NSString *)key options:(DVECLevelDBReadOptions *)options error:(NSError **)error {
    std::string value;
    leveldb::Slice levelDbKey([key UTF8String]);

    leveldb::Status status = self.db->Get(*(options.options), levelDbKey, &value);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return nil;
    }

    return [[NSString alloc] initWithBytes:value.data() length:value.length() encoding:NSUTF8StringEncoding];
}

- (NSString *)valueForKey:(NSString *)key error:(NSError **)error {
    return [self valueForKey:key options:[DVECLevelDBReadOptions new] error:error];
}

- (BOOL)setValue:(NSString *)value forKey:(NSString *)key options:(DVECLevelDBWriteOptions *)options error:(NSError **)error {
    if (value == nil) {
        return [self removeValueForKey:key options:options error:error];
    }

    leveldb::Slice levelDbKey([key UTF8String]);
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    leveldb::Slice levelDbValue((const char *)valueData.bytes, valueData.length);

    leveldb::Status status = self.db->Put(*(options.options), levelDbKey, levelDbValue);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return NO;
    }
    return YES;
}

- (BOOL)setValue:(NSString *)value forKey:(NSString *)key error:(NSError **)error {
    return [self setValue:value forKey:key options:[DVECLevelDBWriteOptions new] error:error];
}

- (BOOL)syncSetValue:(NSString *)value forKey:(NSString *)key error:(NSError **)error {
    return [self setValue:value forKey:key options:self.syncWriteOptions error:error];
}

- (BOOL)removeValueForKey:(NSString *)key options:(DVECLevelDBWriteOptions *)options error:(NSError **)error {
    leveldb::Slice levelDbKey([key UTF8String]);

    leveldb::Status status = self.db->Delete(*(options.options), levelDbKey);
    
    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return NO;
    }
    return YES;
}

- (BOOL)removeValueForKey:(NSString *)key error:(NSError **)error {
    return [self removeValueForKey:key options:[DVECLevelDBWriteOptions new] error:error];
}

- (BOOL)syncRemoveValueForKey:(NSString *)key error:(NSError **)error {
    return [self removeValueForKey:key options:self.syncWriteOptions error:error];
}

- (NSString *)objectForKeyedSubscript:(NSString *)key {
    NSError *error = nil;
    NSString *value = [self valueForKey:key error:&error];

    if (error != nil) {
        if (error.domain == DVECLevelDBErrorDomain && error.code == DVECLevelDBErrorNotFound) {
            return nil;
        } else {
            [[self class] raiseCriticalExceptionForError:error key:key];
        }
    }
    return value;
}

- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString *)key {
    if (obj == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Cannot set %@ to 'nil' value", key];
    }

    NSError *error = nil;
    [self setValue:obj forKey:key error:&error];

    if (error != nil) {
        [[self class] raiseCriticalExceptionForError:error key:key];
    }
}

- (NSEnumerator<NSString *>*)keyEnumerator {
    return [[DVECLevelDBKeyEnumerator alloc] initWithDB:self reverse:NO options:[DVECLevelDBReadOptions new]];
}

@end
