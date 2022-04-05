// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#ifndef DVECLevelDBComparatorFacade_hpp
#define DVECLevelDBComparatorFacade_hpp

#import <Foundation/Foundation.h>
#import "DVECLevelDB+Internal.h"
#import "DVECLevelDBKeyComparator.h"
#import "leveldb/leveldb/comparator.h"

class DVECLevelDBComparatorFacade final : public leveldb::Comparator {
public:
    explicit DVECLevelDBComparatorFacade(id<DVECLevelDBKeyComparator> comparator) : _comparator(comparator) {
    }

    ~DVECLevelDBComparatorFacade() override {
        _comparator = nil;
    }

    int Compare(const leveldb::Slice &a, const leveldb::Slice &b) const override {
        return int([_comparator compareKey1:dataForSlice(a) withKey2:dataForSlice(b)]);
    }

    const char* Name() const override { return [_comparator.name UTF8String]; }
    void FindShortestSeparator(std::string *start, const leveldb::Slice &limit) const override {
        if ([_comparator respondsToSelector:@selector(findShortestSeparator:limit:)]) {
            NSData *startData = dataForString(*start);
            NSData *limitData = dataForSlice(limit);
            NSData *newStartData = [_comparator findShortestSeparator:startData limit:limitData];
            copyDataToString(newStartData, *start);
        }
    }
    void FindShortSuccessor(std::string *key) const override {
        if ([_comparator respondsToSelector:@selector(findShortestSuccessor:)]) {
            NSData *keyData = dataForString(*key);
            NSData *newKeyData = [_comparator findShortestSuccessor:newKeyData];
            copyDataToString(newKeyData, *key);
        }
    }

private:
    __strong id<DVECLevelDBKeyComparator> _comparator;
};

#endif /* DVECLevelDBComparatorFacade_hpp */
