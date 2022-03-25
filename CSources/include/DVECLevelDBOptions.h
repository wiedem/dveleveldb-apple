// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDBLogger.h"
#import "DVECLevelDBSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVECLevelDBOptionsCompression) {
    DVECLevelDBOptionsCompressionNone = 0x0,
    DVECLevelDBOptionsCompressionSnappy = 0x1,
};

NS_SWIFT_NAME(CLevelDB.Options)
@interface DVECLevelDBOptions: NSObject
@property (nonatomic) BOOL createDBIfMissing;
@property (nonatomic) BOOL throwErrorIfDBExists;
@property (nonatomic) BOOL useParanoidChecks;
@property (nonatomic) size_t writeBufferSize;
@property (nonatomic) int maxOpenFilesCount;
@property (nonatomic) size_t blockSize;
@property (nonatomic) int blockRestartInterval;
@property (nonatomic) size_t maxFileSize;
@property (nonatomic) BOOL reuseLogs;

@property (nonatomic) DVECLevelDBOptionsCompression compression;
@end

NS_SWIFT_NAME(CLevelDB.ReadOptions)
@interface DVECLevelDBReadOptions: NSObject
@property (nonatomic) BOOL verifyChecksums;
@property (nonatomic) BOOL fillCache;
@property (nonatomic, strong, nullable) DVECLevelDBSnapshot *snapshot;

+ (instancetype)DVECLevelDBReadOptionsWithVerifyChecksums:(BOOL)verifyChecksums fillCache:(BOOL)fillCache;
@end

NS_SWIFT_NAME(CLevelDB.WriteOptions)
@interface DVECLevelDBWriteOptions: NSObject
@property (nonatomic) BOOL syncWrite;

+ (instancetype)DVECLevelDBWriteOptionsWithSyncWrite:(BOOL)syncWrite;
@end

NS_ASSUME_NONNULL_END
