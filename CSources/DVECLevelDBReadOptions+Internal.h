// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBOptions.h"
#import "leveldb/leveldb/options.h"

@interface DVECLevelDBReadOptions(Internal)
@property (nonatomic, assign, readonly) leveldb::ReadOptions *options;
@end
