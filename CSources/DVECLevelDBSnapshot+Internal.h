// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBSnapshot.h"
#import "leveldb/leveldb/db.h"

@interface DVECLevelDBSnapshot(Internal)
@property (nonatomic, assign, readonly) const leveldb::Snapshot *snapshot;
@end
