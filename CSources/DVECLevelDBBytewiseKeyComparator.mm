// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBBytewiseKeyComparator.h"
#import "DVECLevelDB+Internal.h"

#import "leveldb/leveldb/comparator.h"

@interface DVECLevelDBBytewiseKeyComparator()
@property (nonatomic, assign) leveldb::Comparator const *comparator;
@end

@implementation DVECLevelDBBytewiseKeyComparator

- (instancetype)init {
    if (self = [super init]) {
        _comparator = leveldb::BytewiseComparator();
    }
    return self;
}

- (NSString *)name {
    return [NSString stringWithCString:self.comparator->Name() encoding:NSUTF8StringEncoding];
}

- (NSComparisonResult)compare:(NSData *)key1 with:(NSData *)key2 {
    leveldb::Slice a = sliceForData(key1);
    leveldb::Slice b = sliceForData(key2);

    int result = self.comparator->Compare(a, b);
    if (result < 0) {
        return NSOrderedAscending;
    } else if (result > 0) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (NSData *)findShortestSeparator:(NSData *)start limit:(NSData *)limit {
    std::string startString;
    copyDataToString(start, startString);
    leveldb::Slice limitSlice = sliceForData(limit);

    self.comparator->FindShortestSeparator(&startString, limitSlice);

    return createDataForString(startString);
}

- (NSData *)findShortestSuccessor:(NSData *)key {
    std::string keyString;
    copyDataToString(key, keyString);

    self.comparator->FindShortSuccessor(&keyString);

    return createDataForString(keyString);
}

@end
