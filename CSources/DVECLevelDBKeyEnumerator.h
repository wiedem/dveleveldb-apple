// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDB.h"
#import "DVECLevelDBOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVECLevelDBKeyEnumerator: NSEnumerator
- (instancetype)initWithDB:(DVECLevelDB *)levelDB reverse:(BOOL)reverse options:(DVECLevelDBReadOptions *)options;
@end

NS_ASSUME_NONNULL_END
