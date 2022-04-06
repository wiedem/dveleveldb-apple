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

#pragma mark NSData conversion helper functions
leveldb::Slice sliceForData(NSData *data) {
    return leveldb::Slice((const char *)data.bytes, data.length);
}

NSData *dataForSlice(const leveldb::Slice &slice) {
    return [[NSData alloc] initWithBytesNoCopy:(void *)slice.data() length:slice.size() freeWhenDone:NO];
}

NSData *dataForString(const std::string &string) {
    return [[NSData alloc] initWithBytesNoCopy:(void *)string.data() length:string.size() freeWhenDone:NO];
}

void copyDataToString(NSData *data, std::string &string) {
    if (data.length != string.size()) {
        string.resize(data.length);
    }

    if (data.length > 0) {
        [data getBytes:(void *)string.data() length:string.length()];
    }
}

#pragma mark -
@interface DVECLevelDB()
@property (nonatomic, strong) NSURL *directoryURL;
@property (nonatomic, strong) DVECLevelDBOptions *options;
@property (nonatomic, assign) leveldb::DB *db;

@property (nonatomic, assign) leveldb::Logger *logger;
@property (nonatomic, assign) leveldb::Comparator *keyComparator;
@property (nonatomic, assign) leveldb::FilterPolicy *filterPolicy;
@property (nonatomic, assign) leveldb::Cache *blockCache;
@end

@implementation DVECLevelDB

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

+ (BOOL)repairDbAtDirectoryURL:(NSURL *)url
                       options:(DVECLevelDBOptions *)options
                        logger:(leveldb::Logger *)logger
                         error:(NSError **)error
{
    leveldb::Options levelDBOptions = [options createDefaultLevelDBOptions];
    levelDBOptions.info_log = logger;

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

+ (BOOL)repairDbAtDirectoryURL:(NSURL *)url
                       options:(DVECLevelDBOptions *)options
                  simpleLogger:(id<DVECLevelDBSimpleLogger>)simpleLogger
                         error:(NSError **)error
{
    leveldb::Logger *logger = [DVECLevelDBOptions createSimpleLoggerFacade:simpleLogger];
    return [self repairDbAtDirectoryURL:url options:options logger:logger error:error];
}

+ (BOOL)repairDbAtDirectoryURL:(NSURL *)url
                       options:(DVECLevelDBOptions *)options
                  formatLogger:(id<DVECLevelDBFormatLogger>)formatLogger
                         error:(NSError **)error
{
    leveldb::Logger *logger = [DVECLevelDBOptions createFormatLoggerFacade:formatLogger];
    return [self repairDbAtDirectoryURL:url options:options logger:logger error:error];
}

+ (void)raiseCriticalExceptionForError:(NSError *)error key:(NSData *)key {
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
                        simpleLogger:(id<DVECLevelDBSimpleLogger>)simpleLogger
                       keyComparator:(nullable id<DVECLevelDBKeyComparator>)keyComparator
                        filterPolicy:(nullable id<DVECLevelDBFilterPolicy>)filterPolicy
                   lruBlockCacheSize:(size_t)lruBlockCacheSize
                               error:(NSError **)error
{
    leveldb::Logger *loggerFacade = [DVECLevelDBOptions createSimpleLoggerFacade:simpleLogger];

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
                        formatLogger:(id<DVECLevelDBFormatLogger>)formatLogger
                       keyComparator:(nullable id<DVECLevelDBKeyComparator>)keyComparator
                        filterPolicy:(nullable id<DVECLevelDBFilterPolicy>)filterPolicy
                   lruBlockCacheSize:(size_t)lruBlockCacheSize
                               error:(NSError **)error
{
    leveldb::Logger *loggerFacade = [DVECLevelDBOptions createFormatLoggerFacade:formatLogger];

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

- (NSData *)dataForKey:(NSData *)key options:(DVECLevelDBReadOptions *)options error:(NSError **)error {
    std::string value;
    leveldb::Slice levelDbKey = sliceForData(key);
    leveldb::Status status = self.db->Get(*(options.options), levelDbKey, &value);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return nil;
    }

    return [[NSData alloc] initWithBytes:value.data() length:value.length()];
}

- (NSData *)dataForKey:(NSData *)key error:(NSError **)error {
    return [self dataForKey:key options:[DVECLevelDBReadOptions new] error:error];
}

- (BOOL)setData:(NSData *)data forKey:(NSData *)key options:(DVECLevelDBWriteOptions *)options error:(NSError **)error {
    if (data == nil) {
        return [self removeValueForKey:key options:options error:error];
    }

    leveldb::Slice levelDbKey = sliceForData(key);
    leveldb::Slice levelDbValue = sliceForData(data);

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

- (BOOL)setData:(NSData *)data forKey:(NSData *)key error:(NSError **)error {
    return [self setData:data forKey:key options:[DVECLevelDBWriteOptions new] error:error];
}

- (BOOL)removeValueForKey:(NSData *)key options:(DVECLevelDBWriteOptions *)options error:(NSError **)error {
    leveldb::Slice levelDbKey = sliceForData(key);

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

- (BOOL)removeValueForKey:(NSData *)key error:(NSError **)error {
    return [self removeValueForKey:key options:[DVECLevelDBWriteOptions new] error:error];
}

- (NSData *)objectForKeyedSubscript:(NSData *)key {
    NSError *error = nil;
    NSData *data = [self dataForKey:key error:&error];

    if (error != nil) {
        if (error.domain == DVECLevelDBErrorDomain && error.code == DVECLevelDBErrorNotFound) {
            return nil;
        } else {
            [[self class] raiseCriticalExceptionForError:error key:key];
        }
    }
    return data;
}

- (void)setObject:(NSData *)obj forKeyedSubscript:(NSData *)key {
    if (obj == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Cannot set %@ to 'nil' value", key];
    }

    NSError *error = nil;
    [self setData:obj forKey:key error:&error];

    if (error != nil) {
        [[self class] raiseCriticalExceptionForError:error key:key];
    }
}

- (NSEnumerator<NSData *>*)keyEnumerator {
    return [[DVECLevelDBKeyEnumerator alloc] initWithDB:self reverse:NO options:[DVECLevelDBReadOptions new]];
}

@end
