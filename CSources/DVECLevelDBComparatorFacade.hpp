// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#ifndef DVECLevelDBComparatorFacade_hpp
#define DVECLevelDBComparatorFacade_hpp

#import <Foundation/Foundation.h>
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
        NSString *lhs = [[NSString alloc] initWithBytesNoCopy:(void *)a.data() length:a.size() encoding:NSUTF8StringEncoding freeWhenDone:NO];
        NSString *rhs = [[NSString alloc] initWithBytesNoCopy:(void *)b.data() length:b.size() encoding:NSUTF8StringEncoding freeWhenDone:NO];
        return int([_comparator compareKey1:lhs withKey2:rhs]);
    }

    const char* Name() const override { return [_comparator.name UTF8String]; }
    void FindShortestSeparator(std::string*, const leveldb::Slice&) const override {}
    void FindShortSuccessor(std::string*) const override {}

private:
    __strong id<DVECLevelDBKeyComparator> _comparator;
};

#endif /* DVECLevelDBComparatorFacade_hpp */
