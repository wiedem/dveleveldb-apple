// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDB.h"
#import "leveldb/leveldb/status.h"

@interface NSError(DVECLevelDBError)
+ (nullable instancetype)createFromLevelDBStatus:(leveldb::Status)status;
@end
