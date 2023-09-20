// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDBOptions.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB.Iterator)
@interface DVECLevelDBIterator: NSObject
@property (nonatomic, readonly) BOOL isValid;

- (instancetype)initWithLevelDB:(DVECLevelDB *)levelDB readOptions:(DVECLevelDBReadOptions *)readOptions;
- (void)seekToFirstEntry;
- (void)seekToLastEntry;
- (void)seekToNextEntry;
- (void)seekToPreviousEntry;
- (void)seekToKey:(NSData *)key;
- (NSData *)currentKey;
- (NSData *)currentValue;
//- (leveldb::Status)currentStatus;
@end

NS_ASSUME_NONNULL_END
