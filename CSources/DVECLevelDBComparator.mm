// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBKeyComparator.h"

@interface DVECLevelDBBlockKeyComparator()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) DVECLevelDBComparatorBlock comparator;
@end

@implementation DVECLevelDBBlockKeyComparator

- (instancetype)initWithName:(NSString *)name comparator:(DVECLevelDBComparatorBlock)comparator {
    if (self = [super init]) {
        _name = name;
        _comparator = comparator;
    }
    return self;
}

- (NSComparisonResult)compareKey1:(NSString *)key1 withKey2:(NSString *)key2 {
    return _comparator(key1, key2);
}

@end
