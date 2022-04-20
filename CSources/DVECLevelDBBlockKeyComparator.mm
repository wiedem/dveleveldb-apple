// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBBlockKeyComparator.h"

@interface DVECLevelDBBlockKeyComparator()
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSStringEncoding stringEncoding;
@property (nonatomic, copy) DVECLevelDBKeyComparatorBlock comparator;
@property (nonatomic, copy) DVECLevelDBKeyFindShortestSeparatorBlock findShortestSeparator;
@property (nonatomic, copy) DVECLevelDBKeyFindShortestSuccessorBlock findShortestSuccessor;
@end

@implementation DVECLevelDBBlockKeyComparator

- (instancetype)initWithName:(NSString *)name
              stringEncoding:(NSStringEncoding)stringEncoding
                  comparator:(DVECLevelDBKeyComparatorBlock)comparator
       findShortestSeparator:(DVECLevelDBKeyFindShortestSeparatorBlock)findShortestSeparator
       findShortestSuccessor:(DVECLevelDBKeyFindShortestSuccessorBlock)findShortestSuccessor {
    if (self = [super init]) {
        _name = name;
        _stringEncoding = stringEncoding;
        _comparator = comparator;
        _findShortestSeparator = findShortestSeparator;
        _findShortestSuccessor = findShortestSuccessor;
    }
    return self;
}

- (NSComparisonResult)compareKey1:(NSData *)key1 withKey2:(NSData *)key2 {
    return _comparator(key1, key2);
}

- (NSData *)findShortestSeparator:(NSData *)start limit:(NSData *)limit {
    if (_findShortestSeparator == nil) {
        return nil;
    }
    return _findShortestSeparator(start, limit);
}

- (NSData *)findShortestSuccessor:(NSData *)key {
    if (_findShortestSuccessor == nil) {
        return nil;
    }
    return _findShortestSuccessor(key);
}

@end
