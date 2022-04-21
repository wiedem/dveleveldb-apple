// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBInternalComparator.h"
#import "DVECLevelDB+Internal.h"

@interface DVECLevelDBInternalComparator()
@property (nonatomic, assign) leveldb::Comparator const *comparator;
@property (nonatomic, assign) BOOL freeWhenDone;
@end

@implementation DVECLevelDBInternalComparator

+ (instancetype)bytewiseComparator {
    return [[DVECLevelDBInternalComparator alloc] initWithComparator:leveldb::BytewiseComparator()
                                                        freeWhenDone:NO];
}

- (instancetype)initWithComparator:(const leveldb::Comparator *)comparator
                      freeWhenDone:(BOOL)freeWhenDone {
    if (self = [super init]) {
        _comparator = comparator;
        _freeWhenDone = freeWhenDone;
    }
    return self;
}

- (void)dealloc {
    if (self.freeWhenDone) {
        delete _comparator;
        _comparator = nil;
    }
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

- (NSData *)findShortSuccessor:(NSData *)key {
    std::string keyString;
    copyDataToString(key, keyString);

    self.comparator->FindShortSuccessor(&keyString);

    return createDataForString(keyString);
}

@end
