// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDB.h"
#import "leveldb/leveldb/db.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVECLevelDB(Internal)
@property (nonatomic, assign, readonly) leveldb::DB *db;
@end

NS_ASSUME_NONNULL_END
