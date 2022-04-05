// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDBKeyComparator.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSComparisonResult (^DVECLevelDBKeyComparatorBlock)(NSData *lhs, NSData *rhs);

NS_SWIFT_NAME(CLevelDB.BlockKeyComparator)
@interface DVECLevelDBBlockKeyComparator: NSObject<DVECLevelDBKeyComparator>
- (instancetype)initWithName:(NSString *)name comparator:(DVECLevelDBKeyComparatorBlock)comparator;
@end

NS_ASSUME_NONNULL_END
