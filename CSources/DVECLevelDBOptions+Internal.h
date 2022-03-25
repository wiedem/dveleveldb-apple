// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDB.h"
#import "DVECLevelDBLogger.h"
#import "leveldb/leveldb/options.h"
#import "leveldb/leveldb/comparator.h"
#import "leveldb/leveldb/filter_policy.h"
#import "leveldb/leveldb/cache.h"

@interface DVECLevelDBOptions(Internal)
- (leveldb::Options)createDefaultLevelDBOptions;
- (leveldb::Options)createLevelDBOptionsWithLogger:(nullable leveldb::Logger *)logger
                                     keyComparator:(nullable leveldb::Comparator *)keyComparator
                                      filterPolicy:(nullable leveldb::FilterPolicy *)filterPolicy
                                        blockCache:(nullable leveldb::Cache *)blockCache;
@end
