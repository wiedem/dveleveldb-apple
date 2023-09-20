// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB.KeyRange)
@interface DVECLevelDBKeyRange: NSObject
@property (nonatomic) NSData *startKey;
@property (nonatomic) NSData *limitKey;

- (instancetype)initWithStartKey:(NSData *)startKey limitKey:(NSData *)limitKey;
- (BOOL)isEqualToKeyRange:(DVECLevelDBKeyRange *)other;
@end

NS_ASSUME_NONNULL_END
