// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBWriteBatch.h"
#import "DVECLevelDB+Internal.h"
#import "DVECLevelDBWriteOptions+Internal.h"
#import "NSError+DVECLevelDBError.h"
#import "leveldb/leveldb/db.h"
#import "leveldb/leveldb/write_batch.h"

@interface DVECLevelDBWriteBatch()
@property (nonatomic, strong) DVECLevelDB *db;
@end

@implementation DVECLevelDBWriteBatch {
    leveldb::WriteBatch *_writeBatch;
}

- (instancetype)initWithDB:(DVECLevelDB *)db {
    if (self = [super init]) {
        _db = db;
        _writeBatch = new leveldb::WriteBatch();
    }
    return self;
}

- (void)dealloc {
    delete _writeBatch;
    _writeBatch = nil;
}

- (id)copyWithZone:(NSZone *)zone {
    DVECLevelDBWriteBatch *copy = [[DVECLevelDBWriteBatch allocWithZone:zone] initWithDB:_db];
    copy->_writeBatch = new leveldb::WriteBatch(*_writeBatch);
    return copy;
}

- (id)valueForKey:(NSString *)key {
    return [super valueForKey:key];
}

- (size_t)approximateSize {
    return _writeBatch->ApproximateSize();
}

- (BOOL)writeWithOptions:(DVECLevelDBWriteOptions *)options error:(NSError **)error {
    leveldb::Status status = self.db.db->Write(*(options.options), _writeBatch);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return NO;
    }
    return YES;
}

- (void)setData:(NSData *)data forKey:(NSData *)key {
    if (key == nil) {
        [self removeValueForKey:key];
        return;
    }

    leveldb::Slice levelDbKey = sliceForData(key);
    leveldb::Slice levelDbValue = sliceForData(data);

    _writeBatch->Put(levelDbKey, levelDbValue);
}

- (void)removeValueForKey:(NSData *)key {
    leveldb::Slice levelDbKey = sliceForData(key);
    _writeBatch->Delete(levelDbKey);
}

- (void)clear {
    _writeBatch->Clear();
}

- (void)appendOperationsOf:(DVECLevelDBWriteBatch *)source {
    _writeBatch->Append(*source->_writeBatch);
}

@end
