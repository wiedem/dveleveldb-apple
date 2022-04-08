// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB.KeyComparator)
@protocol DVECLevelDBKeyComparator <NSObject>
@property (nonatomic, readonly) NSString *name;
- (NSComparisonResult)compareKey1:(NSData *)key1 withKey2:(NSData *)key2;

@optional
- (nullable NSData *)findShortestSeparator:(NSData *)start limit:(NSData *)limit;
- (nullable NSData *)findShortestSuccessor:(NSData *)key;
@end

NS_ASSUME_NONNULL_END
