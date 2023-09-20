// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDB.h"
#import "DVECLevelDBOptions.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB.WriteBatch)
@interface DVECLevelDBWriteBatch: NSObject<NSCopying>
@property (nonatomic, strong, readonly) DVECLevelDB *db;
@property (nonatomic, readonly) size_t approximateSize;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDB:(DVECLevelDB *)db NS_DESIGNATED_INITIALIZER;
- (id)valueForKey:(NSString *)key KVC_SWIFT_UNAVAILABLE;

- (BOOL)writeWithOptions:(DVECLevelDBWriteOptions *)options error:(NSError *_Nullable *_Nullable)error;

- (void)setData:(nullable NSData *)data forKey:(NSData *)key;
- (void)removeValueForKey:(NSData *)key;
- (void)clear;
- (void)appendOperationsOf:(DVECLevelDBWriteBatch *)writeBatch;
@end

NS_ASSUME_NONNULL_END
