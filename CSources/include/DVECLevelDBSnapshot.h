// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

@class DVECLevelDB;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB.Snapshot)
@interface DVECLevelDBSnapshot: NSObject
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDB:(DVECLevelDB *)db NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
