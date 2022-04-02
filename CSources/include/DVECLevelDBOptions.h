// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDBLogger.h"
#import "DVECLevelDBSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVECLevelDBOptionsCompression) {
    DVECLevelDBOptionsCompressionNone = 0x0,
    DVECLevelDBOptionsCompressionSnappy = 0x1,
} NS_SWIFT_NAME(CLevelDB.CompressionOption);

NS_SWIFT_NAME(CLevelDB.Options)
@interface DVECLevelDBOptions: NSObject
@property (class, nonatomic, readonly) size_t defaultWriteBufferSize;
@property (class, nonatomic, readonly) int defaultMaxOpenFilesCount;
@property (class, nonatomic, readonly) size_t defaultBlockSize;
@property (class, nonatomic, readonly) int defaultBlockRestartInterval;
@property (class, nonatomic, readonly) size_t defaultMaxFileSize;
@property (class, nonatomic, readonly) DVECLevelDBOptionsCompression defaultCompression;

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

- (instancetype)initWithCreateDBIfMissing:(BOOL)createDBIfMissing
                     throwErrorIfDBExists:(BOOL)throwErrorIfDBExists
                        useParanoidChecks:(BOOL)useParanoidChecks
                          writeBufferSize:(size_t)writeBufferSize
                        maxOpenFilesCount:(int)maxOpenFilesCount
                                blockSize:(size_t)blockSize
                     blockRestartInterval:(int)blockRestartInterval
                              maxFileSize:(size_t)maxFileSize
                                reuseLogs:(BOOL)reuseLogs
                              compression:(DVECLevelDBOptionsCompression)compression NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

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
