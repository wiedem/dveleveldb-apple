// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDBKeyComparator.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB.KeyComparatorBlock)
typedef NSComparisonResult (^DVECLevelDBKeyComparatorBlock)(NSData *lhs, NSData *rhs);
NS_SWIFT_NAME(CLevelDB.KeyFindShortestSeparatorBlock)
typedef NSData *_Nullable (^DVECLevelDBKeyFindShortestSeparatorBlock)(NSData *start, NSData *limit);
NS_SWIFT_NAME(CLevelDB.KeyFindShortestSuccessorBlock)
typedef NSData *_Nullable (^DVECLevelDBKeyFindShortestSuccessorBlock)(NSData *key);

NS_SWIFT_NAME(CLevelDB.BlockKeyComparator)
@interface DVECLevelDBBlockKeyComparator: NSObject<DVECLevelDBKeyComparator>
- (instancetype)initWithName:(NSString *)name
              stringEncoding:(NSStringEncoding)stringEncoding
                  comparator:(DVECLevelDBKeyComparatorBlock)comparator
       findShortestSeparator:(nullable DVECLevelDBKeyFindShortestSeparatorBlock)findShortestSeparator
       findShortestSuccessor:(nullable DVECLevelDBKeyFindShortestSuccessorBlock)findShortestSuccessor NS_REFINED_FOR_SWIFT;
@end

NS_ASSUME_NONNULL_END
