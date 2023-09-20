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
#import "DVECLevelDBKeyComparator.h"
#import "DVECLevelDBInternalComparator.h"
#import "DVECLevelDBError.h"
#import "NSError+DVECLevelDBError.h"

#import "leveldb/leveldb/db.h"
#import "leveldb/leveldb/comparator.h"

#pragma mark NSData conversion helper functions
leveldb::Slice sliceForData(NSData *data) {
    return leveldb::Slice((const char *)data.bytes, data.length);
}

NSData *dataForString(const std::string &string) {
    if (string.size() == 0) {
        return [NSData data];
    }
    return [[NSData alloc] initWithBytesNoCopy:(void *)string.data() length:string.size() freeWhenDone:NO];
}

NSData *dataForSlice(const leveldb::Slice &slice) {
    if (slice.size() == 0) {
        return [NSData data];
    }
    return [[NSData alloc] initWithBytesNoCopy:(void *)slice.data() length:slice.size() freeWhenDone:NO];
}

NSData *createDataForString(std::string &string) {
    if (string.length() == 0) {
        return [NSData new];
    }
    return [[NSData alloc] initWithBytes:string.data() length:string.length()];
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

@property (nonatomic, assign) leveldb::Comparator *leveldbComparator;
@property (nonatomic, assign) leveldb::Logger *leveldbLogger;
@property (nonatomic, assign) leveldb::FilterPolicy *leveldbFilterPolicy;
@property (nonatomic, assign) leveldb::Cache *leveldbBlockCache;
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

+ (leveldb::DB *)openLevelDBAtUrl:(NSURL *)url options:(leveldb::Options)options error:(NSError **)error {
    leveldb::DB *db;
    leveldb::Status status = leveldb::DB::Open(options, [url.path UTF8String], &db);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return nil;
    }
    return db;
}

#pragma mark -
- (instancetype)initWithDirectoryURL:(NSURL *)url
                             options:(DVECLevelDBOptions *)options
                        simpleLogger:(id<DVECLevelDBSimpleLogger>)simpleLogger
                       keyComparator:(nullable id<DVECLevelDBKeyComparator>)keyComparator
                        filterPolicy:(nullable id<DVECLevelDBFilterPolicy>)filterPolicy
                   lruBlockCacheSize:(size_t)lruBlockCacheSize
                               error:(NSError **)error
{
    self = [super init];
    if (!self) {
        return nil;
    }

    _directoryURL = url;
    _options = options;

    // Logger.
    _leveldbLogger = [DVECLevelDBOptions createSimpleLoggerFacade:simpleLogger];

    // Comparator.
    if (keyComparator != nil) {
        _leveldbComparator = new DVECLevelDBComparatorFacade(keyComparator);
    }

    // Filter policy.
    if (filterPolicy != nil) {
        _leveldbFilterPolicy = new DVECLevelDBFilterPolicyFacade(filterPolicy);
    }

    // Block cache.
    if (lruBlockCacheSize > 0) {
        _leveldbBlockCache = leveldb::NewLRUCache(lruBlockCacheSize);
    }

    //
    leveldb::Options levelDBOptions = [options createLevelDBOptionsWithLogger:_leveldbLogger
                                                                keyComparator:_leveldbComparator
                                                                 filterPolicy:_leveldbFilterPolicy
                                                                   blockCache:_leveldbBlockCache];

    NSError *levelDBError = nil;
    _db = [DVECLevelDB openLevelDBAtUrl:url options:levelDBOptions error:&levelDBError];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return nil;
    }

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
    self = [super init];
    if (!self) {
        return nil;
    }

    _directoryURL = url;
    _options = options;

    // Logger.
    _leveldbLogger = [DVECLevelDBOptions createFormatLoggerFacade:formatLogger];

    // Comparator.
    // Comparator.
    if (keyComparator != nil) {
        _leveldbComparator = new DVECLevelDBComparatorFacade(keyComparator);
    }

    // Filter policy.
    if (filterPolicy != nil) {
        _leveldbFilterPolicy = new DVECLevelDBFilterPolicyFacade(filterPolicy);
    }

    // Block cache.
    if (lruBlockCacheSize > 0) {
        _leveldbBlockCache = leveldb::NewLRUCache(lruBlockCacheSize);
    }

    //
    leveldb::Options levelDBOptions = [options createLevelDBOptionsWithLogger:_leveldbLogger
                                                                keyComparator:_leveldbComparator
                                                                 filterPolicy:_leveldbFilterPolicy
                                                                   blockCache:_leveldbBlockCache];

    NSError *levelDBError = nil;
    _db = [DVECLevelDB openLevelDBAtUrl:url options:levelDBOptions error:&levelDBError];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return nil;
    }

    return self;
}

- (void)dealloc {
    delete _db;
    _db = nil;

    delete _leveldbComparator;
    _leveldbComparator = nil;
    delete _leveldbLogger;
    _leveldbLogger = nil;
    delete _leveldbFilterPolicy;
    _leveldbFilterPolicy = nil;
    delete _leveldbBlockCache;
    _leveldbBlockCache = nil;
}

- (id)valueForKey:(NSString *)key {
    return [super valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [super setValue:value forKey:key];
}

- (NSString *)dbPropertyForKey:(NSString *)key {
    leveldb::Slice property = leveldb::Slice([key UTF8String]);
    std::string value = std::string();
    self.db->GetProperty(property, &value);
    return [NSString stringWithUTF8String:value.c_str()];
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

- (DVECLevelDBIterator *)iteratorWithOptions:(DVECLevelDBReadOptions *)options {
    return [[DVECLevelDBIterator alloc] initWithLevelDB:self readOptions:options];
}

- (NSArray<NSNumber *> *)getApproximateSizesForKeyRanges:(NSArray<DVECLevelDBKeyRange *> *)keyRanges {
    NSMutableArray *arrSizes = [[NSMutableArray alloc] initWithCapacity:keyRanges.count];

    leveldb::Range *ranges = new leveldb::Range[keyRanges.count];
    uint64_t *sizes = new uint64_t[keyRanges.count];

    for (int i = 0; i < keyRanges.count; i++) {
        ranges[i].start = sliceForData(keyRanges[i].startKey);
        ranges[i].limit = sliceForData(keyRanges[i].limitKey);
    }
    self.db->GetApproximateSizes(ranges, keyRanges.count, sizes);

    for (int i = 0; i < keyRanges.count; i++) {
        [arrSizes addObject:@(sizes[i])];
    }

    delete[] sizes;
    delete[] ranges;

    return [NSArray arrayWithArray:arrSizes];
}

- (void)compactWithStartKey:(NSData *)startKey endKey:(NSData *)endKey {
    leveldb::Slice *start = nil;
    leveldb::Slice *end = nil;

    if (startKey != nil) {
        start = new leveldb::Slice((const char *)startKey.bytes, startKey.length);
    }
    if (endKey != nil) {
        end = new leveldb::Slice((const char *)endKey.bytes, endKey.length);
    }
    self.db->CompactRange(start, end);

    delete start;
    delete end;
}

@end
