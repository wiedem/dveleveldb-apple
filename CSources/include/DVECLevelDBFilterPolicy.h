// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB.FilterPolicy)
@protocol DVECLevelDBFilterPolicy <NSObject>
@property (nonatomic, readonly) NSString *name;
- (NSData *)createFilterForKeys:(NSArray<NSData *> *)keys currentFilter:(NSData *)currentFilter;
- (BOOL)keyMayMatch:(NSData *)key filter:(NSData *)filter;
@end

NS_SWIFT_NAME(CLevelDB.NewBloomFilterPolicy)
@interface DVECLevelDBNewBloomFilterPolicy: NSObject<DVECLevelDBFilterPolicy>
- (instancetype)initWithBitsPerKey:(int)bitsPerKey;
@end

NS_ASSUME_NONNULL_END
