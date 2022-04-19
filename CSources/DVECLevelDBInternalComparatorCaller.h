// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDBKeyComparator.h"
#import "leveldb/leveldb/comparator.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVECLevelDBInternalComparatorCaller: NSObject<DVECLevelDBKeyComparator>
- (instancetype)initWithComparator:(const leveldb::Comparator *)comparator;
@end

NS_ASSUME_NONNULL_END
