// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDBKeyComparator.h"
#import "leveldb/leveldb/comparator.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVECLevelDBInternalComparator: NSObject<DVECLevelDBKeyComparator>
@property (nonatomic, assign, readonly) leveldb::Comparator const *comparator;

+ (instancetype)bytewiseComparator;

- (instancetype)initWithComparator:(const leveldb::Comparator *)comparator
                      freeWhenDone:(BOOL)freeWhenDone
                    stringEncoding:(NSStringEncoding)stringEncoding;
@end

NS_ASSUME_NONNULL_END
