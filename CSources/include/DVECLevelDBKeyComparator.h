// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSComparisonResult (^DVECLevelDBComparatorBlock)(NSString *lhs, NSString *rhs);

NS_SWIFT_NAME(CLevelDB.KeyComparator)
@protocol DVECLevelDBKeyComparator <NSObject>
@property (nonatomic, readonly) NSString *name;
- (NSComparisonResult)compareKey1:(NSString *)key1 withKey2:(NSString *)key2;
@end

NS_SWIFT_NAME(CLevelDB.BlockKeyComparator)
@interface DVECLevelDBBlockKeyComparator: NSObject<DVECLevelDBKeyComparator>
- (instancetype)initWithName:(NSString *)name comparator:(DVECLevelDBComparatorBlock)comparator;
@end

NS_ASSUME_NONNULL_END
