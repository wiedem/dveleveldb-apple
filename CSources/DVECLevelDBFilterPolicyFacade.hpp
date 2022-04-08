// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#ifndef DVECLevelDBFilterPolicyFacade_hpp
#define DVECLevelDBFilterPolicyFacade_hpp

#import <Foundation/Foundation.h>
#import "DVECLevelDB+Internal.h"
#import "leveldb/leveldb/filter_policy.h"

class DVECLevelDBFilterPolicyFacade final : public leveldb::FilterPolicy {
public:
    explicit DVECLevelDBFilterPolicyFacade(id<DVECLevelDBFilterPolicy> filterPolicy) : _filterPolicy(filterPolicy) {
    }

    ~DVECLevelDBFilterPolicyFacade() override {
        _filterPolicy = nil;
    }

    void CreateFilter(const leveldb::Slice *keys, int n, std::string *dst) const override {
        NSMutableArray<NSData *> *objcKeys = [[NSMutableArray alloc] initWithCapacity:n];
        for (int i=0; i<n; i++) {
            NSData *key = dataForSlice(keys[i]);
            [objcKeys addObject:key];
        }

        NSData *currentFilter = dataForString(*dst);
        NSData *newFilter = [_filterPolicy createFilterForKeys:objcKeys currentFilter:currentFilter];
        dst->append((const char *)newFilter.bytes, newFilter.length);
    }

    bool KeyMayMatch(const leveldb::Slice &key, const leveldb::Slice &filter) const override {
        NSData *keyData = dataForSlice(key);
        NSData *filterData = dataForSlice(filter);
        return [_filterPolicy keyMayMatch:keyData filter:filterData];
    }

    const char* Name() const override { return [_filterPolicy.name UTF8String]; }

private:
    __strong id<DVECLevelDBFilterPolicy> _filterPolicy;
};

#endif /* DVECLevelDBFilterPolicyFacade_hpp */
