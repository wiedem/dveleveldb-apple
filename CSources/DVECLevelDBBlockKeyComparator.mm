// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBBlockKeyComparator.h"

@interface DVECLevelDBBlockKeyComparator()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) DVECLevelDBKeyComparatorBlock comparator;
@end

@implementation DVECLevelDBBlockKeyComparator

- (instancetype)initWithName:(NSString *)name comparator:(DVECLevelDBKeyComparatorBlock)comparator {
    if (self = [super init]) {
        _name = name;
        _comparator = comparator;
    }
    return self;
}

- (NSComparisonResult)compareKey1:(NSData *)key1 withKey2:(NSData *)key2 {
    return _comparator(key1, key2);
}

@end
