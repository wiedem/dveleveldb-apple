// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBSnapshot.h"
#import "DVECLevelDB+Internal.h"
#import "leveldb/leveldb/db.h"

@interface DVECLevelDBSnapshot()
@property (nonatomic, strong) DVECLevelDB *db;
@property (nonatomic, assign) const leveldb::Snapshot *snapshot;
@end

@implementation DVECLevelDBSnapshot

- (instancetype)initWithDB:(DVECLevelDB *)db {
    if (self = [super init]) {
        _db = db;
        _snapshot = _db.db->GetSnapshot();
    }
    return self;
}

- (void)dealloc {
    _db.db->ReleaseSnapshot(_snapshot);
    _db = nil;
    _snapshot = nil;
}

@end
