// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDB.h"
#import "DVECLevelDBOptions.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB.WriteBatch)
@interface DVECLevelDBWriteBatch: NSObject
@property (nonatomic, strong, readonly) DVECLevelDB* db;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDB:(DVECLevelDB *)db NS_DESIGNATED_INITIALIZER;
- (id)valueForKey:(NSString *)key KVC_SWIFT_UNAVAILABLE;

- (BOOL)write:(NSError *_Nullable *_Nullable)error;
- (BOOL)syncWrite:(NSError *_Nullable *_Nullable)error;
- (BOOL)writeWithOptions:(DVECLevelDBWriteOptions *)options error:(NSError *_Nullable *_Nullable)error;

- (void)setValue:(nullable NSString *)value forKey:(NSString *)key;
- (void)removeValueForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
