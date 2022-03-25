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
    leveldb::WriteBatch *_updates;
}

- (instancetype)initWithDB:(DVECLevelDB *)db {
    if (self = [super init]) {
        _db = db;
        _updates = new leveldb::WriteBatch();
    }
    return self;
}

- (void)dealloc {
    delete _updates;
    _updates = nil;
}

- (id)valueForKey:(NSString *)key {
    return [super valueForKey:key];
}

- (BOOL)write:(NSError **)error {
    return [self writeWithOptions:[DVECLevelDBWriteOptions new] error:error];
}

- (BOOL)syncWrite:(NSError **)error {
    return [self writeWithOptions:[DVECLevelDBWriteOptions DVECLevelDBWriteOptionsWithSyncWrite:YES] error:error];
}

- (BOOL)writeWithOptions:(DVECLevelDBWriteOptions *)options error:(NSError **)error {
    leveldb::Status status = self.db.db->Write(*(options.options), _updates);

    NSError *levelDBError = [NSError createFromLevelDBStatus:status];
    if (levelDBError != nil) {
        if (error != nil) {
            *error = levelDBError;
        }
        return NO;
    }
    return YES;
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    if (key == nil) {
        [self removeValueForKey:key];
        return;
    }

    leveldb::Slice levelDbKey([key UTF8String]);
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    leveldb::Slice levelDbValue((const char *)valueData.bytes, valueData.length);
    
    _updates->Put(levelDbKey, levelDbValue);
}

- (void)removeValueForKey:(NSString *)key {
    leveldb::Slice levelDbKey([key UTF8String]);
    _updates->Delete(levelDbKey);
}

@end
